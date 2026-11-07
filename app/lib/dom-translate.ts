// 한국어판(/ko/) 화면 번역기.
// 도구 화면 코드를 하나하나 고치지 않고, 화면에 나타나는 영어 문구가
// i18n/ko.ts 사전에 있으면 그 자리에서 한국어로 바꾼다.
// 사용자가 입력한 내용(입력칸·편집기·코드)은 건드리지 않는다.
import ko, { koPatterns } from './i18n/ko';

const ATTRS = ['aria-label', 'placeholder', 'title'];

const SKIP =
	'script, style, textarea, input, code, pre, [contenteditable], [translate="no"], .cm-editor, .ProseMirror';

function lookup(text: string): string | undefined {
	// 템플릿 줄바꿈·들여쓰기로 생긴 공백은 한 칸으로 본다
	const key = text.replace(/\s+/g, ' ').trim();
	if (!key) return undefined;
	if (ko[key]) return ko[key];
	for (const [pattern, korean] of koPatterns)
		if (pattern.test(key)) return key.replace(pattern, korean);
	return undefined;
}

// 페이지가 번역한 글자를 계속 영어로 되돌리면 무한 반복이 된다.
// 같은 자리를 너무 많이 바꾸면 그 자리는 영어로 둔다.
const MAX_REWRITES = 30;
const rewrites = new WeakMap<Node, number>();

function tooMany(node: Node): boolean {
	const count = (rewrites.get(node) ?? 0) + 1;
	rewrites.set(node, count);
	return count > MAX_REWRITES;
}

function translateText(node: Text) {
	const value = node.nodeValue ?? '';
	const ko = lookup(value);
	if (!ko || ko === value.trim()) return;
	if (node.parentElement?.closest(SKIP)) return;
	if (tooMany(node)) return;
	const [, lead, trail] = /^(\s*)[\s\S]*?(\s*)$/.exec(value)!;
	node.nodeValue = lead + ko + trail;
}

function translateAttrs(el: Element) {
	for (const name of ATTRS) {
		const value = el.getAttribute(name);
		if (!value) continue;
		const ko = lookup(value);
		if (ko && ko !== value && !tooMany(el))
			el.setAttribute(name, ko);
	}
}

function translateTree(root: Node) {
	if (root.nodeType === Node.TEXT_NODE) {
		translateText(root as Text);
		return;
	}
	if (root.nodeType !== Node.ELEMENT_NODE) return;
	const el = root as Element;
	// 입력칸·편집기는 안내 문구(placeholder 등)만 번역하고 내용은 건너뛴다
	translateAttrs(el);
	if (el.matches(SKIP)) return;
	const walker = document.createTreeWalker(
		el,
		NodeFilter.SHOW_ELEMENT | NodeFilter.SHOW_TEXT,
		{
			acceptNode: (node) => {
				if (
					node.nodeType === Node.ELEMENT_NODE &&
					(node as Element).matches(SKIP)
				) {
					translateAttrs(node as Element);
					return NodeFilter.FILTER_REJECT;
				}
				return NodeFilter.FILTER_ACCEPT;
			},
		},
	);
	for (let node = walker.nextNode(); node; node = walker.nextNode()) {
		if (node.nodeType === Node.TEXT_NODE)
			translateText(node as Text);
		else translateAttrs(node as Element);
	}
}

export function startDomTranslate() {
	translateTree(document.body);
	// MutationObserver 는 화면을 그리기 전에 실행돼 영어가 깜빡이지 않는다
	new MutationObserver((records) => {
		for (const record of records) {
			if (record.type === 'childList')
				record.addedNodes.forEach(translateTree);
			else if (record.type === 'characterData')
				translateText(record.target as Text);
			else translateAttrs(record.target as Element);
		}
	}).observe(document.body, {
		childList: true,
		subtree: true,
		characterData: true,
		attributes: true,
		attributeFilter: ATTRS,
	});
}
