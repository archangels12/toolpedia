// 숫자 금액을 한글·한자로 쓴다 (계약서·영수증·차용증용)

const DIGIT = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
const SMALL = ['', '십', '백', '천'];
const BIG = ['', '만', '억', '조'];
// 갖은자: 고쳐 쓰기 어렵게 획이 많은 한자
const HANJA = ['', '壹', '貳', '參', '肆', '伍', '陸', '柒', '捌', '玖'];
const HANJA_SMALL = ['', '拾', '佰', '仟'];
const HANJA_BIG = ['', '萬', '億', '兆'];

/** 다룰 수 있는 가장 큰 금액 (9,999조 9,999억 …) */
export const MAX = 1e16 - 1;

interface Style {
	digit: string[];
	small: string[];
	big: string[];
	/** 십·백·천 앞의 '일'을 쓸지 (계약서는 씀: 일백, 일천) */
	one: boolean;
	/** 만 단위 사이 띄어쓰기 */
	gap: string;
}

function write(n: number, s: Style): string {
	if (n === 0) return s.digit === HANJA ? '零' : '영';
	const groups: string[] = [];
	for (let i = 0; n > 0; i++, n = Math.floor(n / 10000)) {
		const chunk = n % 10000;
		if (!chunk) continue;
		let text = '';
		for (let p = 3; p >= 0; p--) {
			const d = Math.floor(chunk / 10 ** p) % 10;
			if (!d) continue;
			text +=
				(d === 1 && p > 0 && !s.one
					? ''
					: s.digit[d]!) + s.small[p]!;
		}
		// 읽는 방식에서 '일만'은 '만'으로 읽는다 (일억·일조는 그대로)
		if (!s.one && i === 1 && chunk === 1) text = '';
		groups.unshift(text + s.big[i]!);
	}
	return groups.join(s.gap);
}

/** 1234567 → "일백이십삼만사천오백육십칠" (계약서용, 띄어쓰지 않음) */
export const formal = (n: number) =>
	write(n, { digit: DIGIT, small: SMALL, big: BIG, one: true, gap: '' });

/** 1234567 → "백이십삼만 사천오백육십칠" (읽는 방식) */
export const spoken = (n: number) =>
	write(n, {
		digit: DIGIT,
		small: SMALL,
		big: BIG,
		one: false,
		gap: ' ',
	});

/** 1234567 → "壹佰貳拾參萬肆仟伍佰陸拾柒" (갖은자) */
export const hanja = (n: number) =>
	write(n, {
		digit: HANJA,
		small: HANJA_SMALL,
		big: HANJA_BIG,
		one: true,
		gap: '',
	});
