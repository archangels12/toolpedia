export interface TextStats {
	words: number;
	characters: number;
	charactersNoSpaces: number;
	bytesUtf8: number;
	bytesEucKr: number;
	sentences: number;
	paragraphs: number;
	lines: number;
	readingTime: string;
	speakingTime: string;
}

const READING_WPM = 200;
const SPEAKING_WPM = 150;

// < 1 min reads as seconds
function pace(words: number, wordsPerMinute: number): string {
	const minutes = words / wordsPerMinute;
	return minutes < 1
		? `${Math.ceil(minutes * 60)} sec`
		: `${Math.ceil(minutes)} min`;
}

// 한글 사이트·문자 메시지가 쓰는 EUC-KR(CP949): 영문·숫자·공백 1바이트, 그 밖의 글자 2바이트
function eucKrBytes(text: string): number {
	let bytes = 0;
	for (const ch of text) bytes += ch.codePointAt(0)! < 0x80 ? 1 : 2;
	return bytes;
}

export function countText(text: string): TextStats {
	const trimmed = text.trim();

	const words = trimmed ? trimmed.split(/\s+/).filter(Boolean).length : 0;
	const sentences = trimmed
		? trimmed.split(/[.!?]+/).filter((s) => s.trim().length > 0)
				.length
		: 0;
	const paragraphs = trimmed
		? trimmed.split(/\n\s*\n/).filter((p) => p.trim().length > 0)
				.length
		: 0;

	return {
		words,
		characters: text.length,
		charactersNoSpaces: text.replace(/\s/g, '').length,
		bytesUtf8: new TextEncoder().encode(text).length,
		bytesEucKr: eucKrBytes(text),
		sentences,
		paragraphs,
		// empty text = 0 lines
		lines: text ? text.split(/\n/).length : 0,
		readingTime: pace(words, READING_WPM),
		speakingTime: pace(words, SPEAKING_WPM),
	};
}

export function statsReport(stats: TextStats): string {
	return `Words: ${stats.words}
Characters: ${stats.characters}
Characters (no spaces): ${stats.charactersNoSpaces}
Bytes (UTF-8): ${stats.bytesUtf8}
Bytes (EUC-KR): ${stats.bytesEucKr}
Sentences: ${stats.sentences}
Paragraphs: ${stats.paragraphs}
Lines: ${stats.lines}
Reading time: ${stats.readingTime}
Speaking time: ${stats.speakingTime}`;
}

/** Characters per word, no spaces, to one decimal; 0 with no words. */
export function averageWordLength(stats: TextStats): number {
	if (!stats.words) return 0;
	return Math.round((stats.charactersNoSpaces / stats.words) * 10) / 10;
}

const edgePunctuation = /^\p{P}+|\p{P}+$/gu;

/** WordCounterViewModel.topWords: case-insensitive, 3+ characters, ties alphabetical. */
export function topWords(
	text: string,
	limit: number,
): { word: string; count: number }[] {
	const counts = new Map<string, number>();
	for (const raw of text.toLowerCase().split(/\s+/)) {
		const word = raw.replace(edgePunctuation, '');
		if ([...word].length < 3) continue;
		counts.set(word, (counts.get(word) ?? 0) + 1);
	}
	return [...counts]
		.sort(([a, x], [b, y]) => y - x || (a < b ? -1 : a > b ? 1 : 0))
		.slice(0, limit)
		.map(([word, count]) => ({ word, count }));
}
