// 퍼센트 계산

/** A의 B% */
export const percentOf = (a: number, b: number): number => (a * b) / 100;

/** A는 B의 몇 % */
export const ratio = (a: number, b: number): number =>
	b === 0 ? NaN : (a / b) * 100;

/** A → B 로 바뀔 때 증감률(%) */
export const change = (from: number, to: number): number =>
	from === 0 ? NaN : ((to - from) / from) * 100;

/** 정가와 할인율로 할인 금액·판매가 (원 미만 버림) */
export function discount(price: number, rate: number) {
	const off = Math.floor((price * rate) / 100 + 1e-9);
	return { off, final: price - off };
}

/** 소수 둘째 자리까지, 뒤의 0은 뺀다: 12.50 → "12.5" */
export function num(value: number): string {
	if (!Number.isFinite(value)) return '—';
	return (Math.round(value * 100) / 100).toLocaleString('ko-KR', {
		maximumFractionDigits: 2,
	});
}
