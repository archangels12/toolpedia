// SNS 공유 이미지(OG 카드, 1200×630) — 툴피디아 디자인
// 종이·잉크 색 + 오른쪽 색인 탭, Pretendard 글꼴(한글 지원).
import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import satori from 'satori';
import { Resvg } from '@resvg/resvg-js';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const fonts = join(root, 'node_modules/pretendard/dist/public/static');
const read = (f) => readFileSync(join(fonts, f));

export const OG_SIZE = { width: 1200, height: 630 };

// app/styles/toolpedia.css 와 같은 색
const PAPER = '#f5f6f8';
const INK = '#1a1c2b';
const INK_SOFT = '#5b5f73';
const MARKER = '#ffe347';
const TABS = [
	'#4c6fff',
	'#ff5a4e',
	'#9b5cff',
	'#17b890',
	'#ffa41b',
	'#2cb5e8',
	'#ff5fa2',
];

export const ogFonts = [
	{
		name: 'Pretendard',
		data: read('Pretendard-Bold.otf'),
		weight: 700,
		style: 'normal',
	},
	{
		name: 'Pretendard',
		data: read('Pretendard-Black.otf'),
		weight: 900,
		style: 'normal',
	},
];

const h = (type, props = {}, children) => ({
	type,
	props: children === undefined ? props : { ...props, children },
});

// 오른쪽 가장자리의 색인 탭 (사전 옆면)
const IndexTabs = () =>
	h(
		'div',
		{
			style: {
				position: 'absolute',
				top: 40,
				right: 0,
				display: 'flex',
				flexDirection: 'column',
				gap: 8,
			},
		},
		TABS.map((color) =>
			h('div', {
				style: {
					width: 34,
					height: 70,
					borderRadius: '12px 0 0 12px',
					backgroundColor: color,
				},
			}),
		),
	);

// 로고: 색인 탭 세 줄 + 워드마크
const Brand = () =>
	h(
		'div',
		{ style: { display: 'flex', alignItems: 'center', gap: 16 } },
		[
			h(
				'div',
				{
					style: {
						display: 'flex',
						flexDirection: 'column',
						gap: 6,
					},
				},
				[
					[34, TABS[0]],
					[46, TABS[1]],
					[26, TABS[3]],
				].map(([width, color]) =>
					h('div', {
						style: {
							width,
							height: 12,
							borderRadius:
								'0 6px 6px 0',
							backgroundColor: color,
						},
					}),
				),
			),
			h(
				'div',
				{
					style: {
						display: 'flex',
						fontSize: 44,
						fontWeight: 900,
						color: INK,
						letterSpacing: -1,
					},
				},
				'툴피디아',
			),
		],
	);

const Title = (text) => {
	const size =
		text.length <= 8
			? 120
			: text.length <= 12
				? 100
				: text.length <= 18
					? 80
					: 64;
	return h(
		'div',
		{ style: { display: 'flex', marginTop: 'auto' } },
		h(
			'div',
			{
				style: {
					display: 'flex',
					fontSize: size,
					fontWeight: 900,
					color: INK,
					lineHeight: 1.1,
					letterSpacing: -3,
					// 형광펜 밑줄
					backgroundImage: `linear-gradient(to bottom, transparent 62%, ${MARKER} 62%, ${MARKER} 92%, transparent 92%)`,
				},
			},
			text,
		),
	);
};

const Subtitle = (text) =>
	h(
		'div',
		{
			style: {
				display: 'flex',
				marginTop: 24,
				fontSize: 36,
				fontWeight: 700,
				color: INK_SOFT,
			},
		},
		text,
	);

const SiteUrl = () =>
	h(
		'div',
		{
			style: {
				display: 'flex',
				marginTop: 40,
				fontSize: 30,
				fontWeight: 700,
				color: INK,
			},
		},
		'toolpedia.app',
	);

const Frame = (children) =>
	h(
		'div',
		{
			style: {
				position: 'relative',
				display: 'flex',
				flexDirection: 'column',
				width: '100%',
				height: '100%',
				padding: '56px 120px 56px 72px',
				backgroundColor: PAPER,
				borderBottom: `14px solid ${INK}`,
				fontFamily: 'Pretendard',
			},
		},
		[IndexTabs(), ...children],
	);

export const toolCard = (name) =>
	Frame([
		Brand(),
		Title(name),
		Subtitle('가입·설치 없이 쓰는 무료 온라인 도구'),
		SiteUrl(),
	]);

export const siteCard = () =>
	Frame([
		Brand(),
		Title('세상의 모든 도구'),
		Subtitle(
			'이미지·PDF·동영상·텍스트 도구를 무료로, 내 기기 안에서',
		),
		SiteUrl(),
	]);

export async function renderPng(element) {
	const svg = await satori(element, { ...OG_SIZE, fonts: ogFonts });
	return new Resvg(svg, {
		fitTo: { mode: 'width', value: OG_SIZE.width },
	})
		.render()
		.asPng();
}

// 미리보기: node scripts/og.mjs [출력 폴더]
if (import.meta.url === `file://${process.argv[1]}`) {
	const outDir = process.argv[2] ?? join(root, 'tmp/og');
	mkdirSync(outDir, { recursive: true });
	writeFileSync(
		join(outDir, 'tool.png'),
		await renderPng(toolCard('이미지 용량 줄이기')),
	);
	writeFileSync(join(outDir, 'site.png'), await renderPng(siteCard()));
	console.log(`wrote ${outDir}`);
}
