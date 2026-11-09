import {
	readFileSync,
	writeFileSync,
	mkdirSync,
	existsSync,
	readdirSync,
} from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer-core';
import { serve } from './static-server.mjs';
import { renderPng, toolCard, siteCard } from './og.mjs';

// 빌드 전용 브라우저: npx @puppeteer/browsers install chrome-headless-shell@stable --path .chrome
function localHeadlessShell() {
	const base = join(root, '.chrome', 'chrome-headless-shell');
	if (!existsSync(base)) return undefined;
	const dirs = (p) =>
		readdirSync(p, { withFileTypes: true })
			.filter((d) => d.isDirectory())
			.map((d) => d.name);
	for (const version of dirs(base)) {
		for (const dir of dirs(join(base, version))) {
			const exe = join(
				base,
				version,
				dir,
				'chrome-headless-shell',
			);
			if (existsSync(exe)) return exe;
		}
	}
	return undefined;
}
const ORIGIN = 'https://toolpedia.app';
const SITE = '툴피디아';
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const CHROME =
	process.env.CHROME_PATH ??
	localHeadlessShell() ??
	'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const dist = process.argv[2] ?? join(root, 'dist');

// node strips typescript
// 한국어 전용 사이트라 allTools 는 한국어판 도구(이름·설명 한국어)만 담고 있다
const { allTools, toolCategories } = await import('../app/lib/tools.ts');
const { categoryPages } = await import('../app/lib/category-pages.ts');

const toolRoutes = allTools.filter(
	(t) => !t.external && t.href.startsWith('/tools/'),
);

const esc = (s) =>
	s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;');

// 구조화 데이터(JSON-LD): 검색결과의 사이트 이름·경로 표시용
function ldScript(data) {
	const json = JSON.stringify({
		'@context': 'https://schema.org',
		...data,
	});
	return `<script type="application/ld+json">${json.replace(/</g, '\\u003c')}</script>`;
}

// 홈 > (카테고리) > 현재 페이지
function breadcrumb(items) {
	return ldScript({
		'@type': 'BreadcrumbList',
		itemListElement: [{ name: SITE, url: '/' }, ...items].map(
			(item, i) => ({
				'@type': 'ListItem',
				position: i + 1,
				name: item.name,
				item: `${ORIGIN}${item.url}`,
			}),
		),
	});
}

function toolBreadcrumb(tool) {
	const category = toolCategories.find((c) =>
		c.tools.some((t) => t.id === tool.id),
	);
	const page = category && categoryPages[category.id];
	return breadcrumb([
		...(page
			? [
					{
						name: page.heading,
						url: `/category/${category.id}`,
					},
				]
			: []),
		{ name: tool.name, url: tool.href },
	]);
}

function headFor({ title, description, url, image, imageAlt, ld }) {
	return [
		`<title>${esc(title)}</title>`,
		`<meta name="description" content="${esc(description)}">`,
		`<link rel="canonical" href="${ORIGIN}${url}">`,
		`<meta property="og:type" content="website">`,
		`<meta property="og:site_name" content="${SITE}">`,
		`<meta property="og:locale" content="ko_KR">`,
		`<meta property="og:title" content="${esc(title)}">`,
		`<meta property="og:description" content="${esc(description)}">`,
		`<meta property="og:url" content="${ORIGIN}${url}">`,
		`<meta property="og:image" content="${ORIGIN}${image}">`,
		`<meta property="og:image:width" content="1200">`,
		`<meta property="og:image:height" content="630">`,
		`<meta property="og:image:alt" content="${esc(imageAlt)}">`,
		`<meta name="twitter:card" content="summary_large_image">`,
		`<meta name="twitter:title" content="${esc(title)}">`,
		`<meta name="twitter:description" content="${esc(description)}">`,
		`<meta name="twitter:image" content="${ORIGIN}${image}">`,
		`<meta name="twitter:image:alt" content="${esc(imageAlt)}">`,
		`<meta name="twitter:image:width" content="1200">`,
		`<meta name="twitter:image:height" content="630">`,
		...(ld ? [ld] : []),
	].join('\n    ');
}

// JS를 실행하지 않는 검색엔진·AI 수집기도 본문(설명·FAQ)을 읽도록 그려진 본문을 넣어 둔다.
// 앱이 시작되면 index.html 의 스크립트가 이 블록을 지우고 앱 화면으로 바꾼다.
function withBody(html, main) {
	if (!main) return html;
	const clean = main.replace(/ id="ember\d+"/g, '');
	return html.replace(
		/<body([^>]*)>/,
		`<body$1>\n    <div id="dt-prerender">${clean}</div>`,
	);
}

function withHead(shell, head) {
	return shell
		.replace(/<title>[\s\S]*?<\/title>/, '@@HEAD@@')
		.replace(
			/\n\s*(?:<meta (?:name="description"|property="og:|name="twitter:)[^>]*>|<link rel="canonical"[^>]*>)/g,
			'',
		)
		.replace('@@HEAD@@', head);
}

console.log(`registry: ${toolRoutes.length} tool routes`);

const shell = readFileSync(join(dist, 'index.html'), 'utf8');
const port = 4321;
const server = await serve(dist, port);
// the deploy image has no chrome
const browser = existsSync(CHROME)
	? await puppeteer.launch({ executablePath: CHROME, headless: 'new' })
	: null;
if (!browser) console.warn('chrome not found, skipping boot checks');

// evaluate runs in browser context
async function boot(url, evaluate) {
	if (!browser) return null;
	const page = await browser.newPage();
	// 광고 스크립트는 막는다: 자동 광고가 미리 그린 본문에 섞이거나 빌드 방문이 광고 노출로 잡히지 않게
	await page.setRequestInterception(true);
	page.on('request', (r) =>
		/googlesyndication|doubleclick|adservice\.google/.test(r.url())
			? r.abort()
			: r.continue(),
	);
	const errors = [];
	page.on('pageerror', (e) => errors.push(e.message));
	await page.goto(`http://localhost:${port}${url}`, {
		waitUntil: 'networkidle2',
	});
	const result = await page.evaluate(evaluate);
	await page.close();
	if (errors.length) {
		console.error(`  ${url}: ${errors[0]}`);
		process.exitCode = 1;
	}
	return result;
}

const suiteDescription = (id) =>
	allTools.find((t) => t.id === id)?.description ?? '';

const routes = [
	{
		url: '/',
		title: `${SITE} — 세상의 모든 도구 | 무료 온라인 도구 모음`,
		description:
			'이미지 용량 줄이기, PDF 합치기, QR코드 만들기, 글자수 세기까지. 가입·설치 없이 쓰는 무료 온라인 도구 모음. 파일은 내 기기 밖으로 나가지 않아요.',
		image: '/og.png',
		imageAlt: `${SITE} — 세상의 모든 도구`,
		card: siteCard(),
		ld: ldScript({
			'@type': 'WebSite',
			name: SITE,
			alternateName: 'Toolpedia',
			url: `${ORIGIN}/`,
			inLanguage: 'ko',
		}),
	},
	...toolRoutes.map((t) => ({
		url: `/tools/${t.id}`,
		title: `${t.name} - 무료 온라인 도구 | ${SITE}`,
		description: `${t.description}. 가입·설치 없이 브라우저에서 바로, 무료로 쓸 수 있어요.`,
		image: `/tools/${t.id}/og.png`,
		imageAlt: `${t.name} — ${SITE}`,
		card: toolCard(t.name),
		ld: toolBreadcrumb(t),
	})),
	...Object.entries(categoryPages).map(([id, page]) => ({
		url: `/category/${id}`,
		title: `${page.title} | ${SITE}`,
		description: page.description,
		image: `/category/${id}/og.png`,
		imageAlt: `${page.heading} — ${SITE}`,
		card: toolCard(page.heading),
		ld: breadcrumb([
			{ name: page.heading, url: `/category/${id}` },
		]),
	})),
	{
		url: '/editor',
		title: `이미지 편집기 - 무료 온라인 도구 | ${SITE}`,
		description: suiteDescription('substrata'),
		image: '/editor/og.png',
		imageAlt: `이미지 편집기 — ${SITE}`,
		card: toolCard('이미지 편집기'),
		ld: toolBreadcrumb(allTools.find((t) => t.id === 'substrata')),
	},
	{
		url: '/errata',
		title: `PDF 편집기 - 무료 온라인 도구 | ${SITE}`,
		description: suiteDescription('errata'),
		image: '/errata/og.png',
		imageAlt: `PDF 편집기 — ${SITE}`,
		card: toolCard('PDF 편집기'),
		ld: toolBreadcrumb(allTools.find((t) => t.id === 'errata')),
	},
	{
		url: '/about',
		title: `툴피디아 소개 | ${SITE}`,
		description: `${SITE}는 이미지·PDF·영상·글·계산기 등 100여 가지 무료 온라인 도구 모음입니다. 파일은 브라우저 안에서 처리되어 서버로 올라가지 않아요.`,
		image: '/about/og.png',
		imageAlt: `툴피디아 소개 — ${SITE}`,
		card: toolCard('툴피디아 소개'),
	},
	{
		url: '/contact',
		title: `문의하기 | ${SITE}`,
		description: `${SITE} 오류 제보, 도구 제안, 계산기 정정, 광고·제휴 문의 안내.`,
		image: '/contact/og.png',
		imageAlt: `문의하기 — ${SITE}`,
		card: toolCard('문의하기'),
	},
	{
		url: '/privacy',
		title: `개인정보처리방침 | ${SITE}`,
		description: `${SITE} 개인정보처리방침. 수집하는 정보, 광고 쿠키, 문의처를 안내합니다.`,
		image: '/privacy/og.png',
		imageAlt: `개인정보처리방침 — ${SITE}`,
		card: toolCard('개인정보처리방침'),
	},
];

let written = 0;
for (const route of routes) {
	const dir = route.url === '/' ? dist : join(dist, route.url);
	mkdirSync(dir, { recursive: true });

	writeFileSync(join(dir, 'og.png'), await renderPng(route.card));

	const rendered = await boot(route.url, () => ({
		title:
			document
				.querySelector('.dt-bar-title')
				?.textContent?.trim() ?? '',
		main: document.querySelector('#main-content')?.innerHTML ?? '',
	}));

	writeFileSync(
		join(dir, 'index.html'),
		withBody(withHead(shell, headFor(route)), rendered?.main ?? ''),
	);
	written += 1;
	if (written % 10 === 0 || written === routes.length) {
		console.log(
			`  ${written}/${routes.length} (last: ${route.url} -> "${rendered?.title ?? ''}")`,
		);
	}
}

// cloudflare serves root 404
{
	const sceneRendered = await boot(
		'/no-such-page',
		() => document.querySelector('.tp-404') !== null,
	);
	if (browser && !sceneRendered) {
		console.error('  /no-such-page: 404 page missing (.tp-404)');
		process.exitCode = 1;
	}
	writeFileSync(
		join(dist, '404.html'),
		withHead(
			shell,
			headFor({
				title: `페이지를 찾을 수 없어요 | ${SITE}`,
				description:
					'찾는 페이지가 없어요. 툴피디아 홈에서 도구를 검색해 보세요.',
				url: '/404',
				image: '/og.png',
				imageAlt: `${SITE} — 세상의 모든 도구`,
			}),
		),
	);
	console.log('  404.html written');
}

// 검색엔진용 사이트맵 (네이버 서치어드바이저·구글 서치콘솔에 제출)
{
	const today = new Date().toISOString().slice(0, 10);
	const urls = routes
		.map(
			(route) =>
				`  <url><loc>${ORIGIN}${route.url}</loc><lastmod>${today}</lastmod></url>`,
		)
		.join('\n');
	writeFileSync(
		join(dist, 'sitemap.xml'),
		`<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls}\n</urlset>\n`,
	);
	console.log(`  sitemap.xml written (${routes.length} urls)`);
}

await browser?.close();
server.close();
console.log(`wrote ${written} routes with per-route head tags and og.png`);
