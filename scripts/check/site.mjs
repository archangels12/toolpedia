// 한국어 사이트 점검: npm run check (먼저 build:static 으로 dist 를 만든다)
// 빌드된 dist 를 직접 띄워 사이트맵의 모든 페이지를 데스크톱·모바일 너비로 연다.
//
// 확인하는 것
//  1. 미리 그린 HTML: 제목·설명·대표 주소·공유 이미지, 구조화 데이터(JSON-LD) 형식, 본문, 내부 링크
//  2. 브라우저: 페이지 오류 없음, 화면 제목이 페이지 이름과 같음, 도구 화면과 사용법이 보임
//  3. 글자 잘림: 버튼·제목·계산 결과가 '…'로 잘리지 않음 (데스크톱 1440px, 모바일 390px)
// 옛 영어판 기준 점검은 scripts/verify-legacy/ 에 보관 (한국어화 이후 맞지 않음)

import { readFileSync, existsSync, statSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer-core';
import { serve } from '../static-server.mjs';

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const dist = join(root, 'dist');
const PORT = 4398;
const ORIGIN = 'https://toolpedia.app';

function findChrome() {
	if (process.env.CHROME_PATH) return process.env.CHROME_PATH;
	const base = join(root, '.chrome', 'chrome-headless-shell');
	if (existsSync(base))
		for (const v of readdirSync(base, { withFileTypes: true }))
			if (v.isDirectory())
				for (const d of readdirSync(
					join(base, v.name),
					{
						withFileTypes: true,
					},
				)) {
					const exe = join(
						base,
						v.name,
						d.name,
						'chrome-headless-shell',
					);
					if (existsSync(exe)) return exe;
				}
	return '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
}

const problems = [];
const fail = (url, what) => problems.push(`${url}  ${what}`);

const pagePath = (url) =>
	join(dist, url === '/' ? '' : url.slice(1), 'index.html');
const exists = (url) => {
	const p = join(dist, url.slice(1));
	return (
		(existsSync(p) && statSync(p).isFile()) ||
		existsSync(join(p, 'index.html'))
	);
};

const sitemap = readFileSync(join(dist, 'sitemap.xml'), 'utf8');
const urls = [
	...sitemap.matchAll(/<loc>https:\/\/toolpedia\.app([^<]*)<\/loc>/g),
].map((m) => m[1] || '/');
if (urls.length < 100) fail('sitemap', `페이지가 ${urls.length}개뿐`);

// 1. 미리 그린 HTML
for (const url of urls) {
	const file = pagePath(url);
	if (!existsSync(file)) {
		fail(url, 'index.html 없음');
		continue;
	}
	const html = readFileSync(file, 'utf8');
	const title = html.match(/<title>([^<]*)<\/title>/)?.[1] ?? '';
	if (!title.includes('툴피디아'))
		fail(url, `제목에 툴피디아 없음: ${title}`);
	if (!/<meta name="description" content="[^"]{20,}"/.test(html))
		fail(url, '설명(meta description) 없음·짧음');
	const canonical = html.match(
		/<link rel="canonical" href="([^"]+)"/,
	)?.[1];
	if (
		canonical !== `${ORIGIN}${url === '/' ? '' : url}` &&
		canonical !== `${ORIGIN}/`
	)
		fail(url, `대표 주소가 다름: ${canonical}`);
	const og = html.match(
		/<meta property="og:image" content="https:\/\/toolpedia\.app([^"]+)"/,
	)?.[1];
	if (!og || !exists(og)) fail(url, `공유 이미지 파일 없음: ${og}`);
	for (const [, json] of html.matchAll(
		/<script type="application\/ld\+json">(.*?)<\/script>/g,
	)) {
		try {
			JSON.parse(json);
		} catch {
			fail(url, '구조화 데이터 JSON 형식 오류');
		}
	}
	const body =
		html.match(/<div id="dt-prerender">([\s\S]*)<\/div>/)?.[1] ??
		'';
	const text = body
		.replace(/<[^>]+>/g, ' ')
		.replace(/\s+/g, ' ')
		.trim();
	if (text.length < 40)
		fail(url, `미리 그린 본문이 거의 없음 (${text.length}자)`);
	// 본문 속 내부 링크 (코드 예시 안의 주소는 제외)
	const links = body
		.replace(/<pre[\s\S]*?<\/pre>|<code[\s\S]*?<\/code>/g, '')
		.matchAll(/<a [^>]*href="(\/[^"#?]*)"/g);
	for (const [, href] of links)
		if (!exists(href.replace(/\/$/, '') || '/') && href !== '/')
			fail(url, `깨진 내부 링크: ${href}`);
}

// 2·3. 브라우저
const server = await serve(dist, PORT);
const browser = await puppeteer.launch({
	executablePath: findChrome(),
	headless: true,
});
let errors = [];
let page;
const freshPage = async () => {
	await page?.close().catch(() => {});
	page = await browser.newPage();
	// 광고 스크립트는 막는다: 자동 광고가 미리 그린 본문에 섞이거나 빌드 방문이 광고 노출로 잡히지 않게
	await page.setRequestInterception(true);
	page.on('request', (r) =>
		/googlesyndication|doubleclick|adservice\.google/.test(r.url())
			? r.abort()
			: r.continue(),
	);
	page.on('pageerror', (e) => errors.push(e.message));
};
await freshPage();

// 탭이 망가지면(프레임 분리 등) 새 탭으로 한 번 더 연다
const open = async (url, width) => {
	for (let attempt = 0; ; attempt++) {
		try {
			await page.setViewport({ width, height: 900 });
			await page.goto(`http://localhost:${PORT}${url}`, {
				waitUntil: 'networkidle2',
				timeout: 60000,
			});
			return;
		} catch (error) {
			if (attempt >= 1) throw error;
			await freshPage();
		}
	}
};

const checkPage = async (url, width) => {
	errors = [];
	try {
		await open(url, width);
	} catch (error) {
		fail(
			`${url} (${width}px)`,
			`페이지 열기 실패: ${error.message}`,
		);
		await freshPage();
		return {};
	}
	await new Promise((r) => setTimeout(r, 400));
	const seen = await page.evaluate(() => {
		const clipped = [];
		for (const el of document.querySelectorAll(
			'.canon-button-title, h1, h2, h3, .canon-heading, .krw-result-value, .dt-bar-title, .tp-guide summary',
		)) {
			if (el.closest('.dt-sr-only, #dt-drawer')) continue;
			const cs = getComputedStyle(el);
			if (cs.display === 'none' || el.clientWidth < 3)
				continue;
			if (
				el.scrollWidth > el.clientWidth &&
				cs.textOverflow === 'ellipsis'
			)
				clipped.push(
					el.textContent.trim().slice(0, 30),
				);
		}
		return {
			prerenderLeft:
				!!document.getElementById('dt-prerender'),
			barTitle: document
				.querySelector('.dt-bar-title')
				?.textContent.trim(),
			tool: !!document.querySelector('.dt-canon-tool'),
			toolEmpty:
				(document
					.querySelector('.dt-canon-tool')
					?.textContent.trim().length ?? 1) === 0,
			guide: !!document.querySelector(
				'.tp-guide, .krw-guide',
			),
			clipped,
		};
	});
	for (const e of errors)
		fail(`${url} (${width}px)`, `페이지 오류: ${e.slice(0, 120)}`);
	if (seen.prerenderLeft)
		fail(url, '미리 그린 본문이 앱 시작 후에도 남아 있음');
	for (const c of seen.clipped)
		fail(`${url} (${width}px)`, `글자 잘림: ${c}`);
	return seen;
};

let done = 0;
for (const url of urls) {
	const html = readFileSync(pagePath(url), 'utf8');
	const name = html.match(/<title>([^<]*?) [-|—]/)?.[1]?.trim();
	const desktop = await checkPage(url, 1440);
	if (url.startsWith('/tools/')) {
		if (!desktop.tool || desktop.toolEmpty)
			fail(url, '도구 화면이 비어 있음');
		if (!desktop.guide) fail(url, '사용법·설명이 없음');
		if (name && desktop.barTitle !== name)
			fail(
				url,
				`화면 제목이 다름: ${desktop.barTitle} ≠ ${name}`,
			);
	}
	await checkPage(url, 390);
	if (++done % 20 === 0) console.log(`  ${done}/${urls.length}`);
}

await browser.close();
server.close?.();

if (problems.length) {
	console.log(`\n문제 ${problems.length}건`);
	for (const p of problems) console.log(`  ✗ ${p}`);
	process.exitCode = 1;
} else console.log(`\n${urls.length}개 페이지 모두 통과`);
