// 원화 금액 입력·표시 (한국형 계산기 공용)

/** "1,234,000원" "1234000" 같은 입력에서 숫자만 읽는다. 비어 있으면 0. */
export function parseWon(text: string): number {
	const digits = text.replace(/[^\d]/g, '');
	return digits ? Number(digits) : 0;
}

/** 1234567 → "1,234,567" */
export function comma(value: number): string {
	return Math.round(value).toLocaleString('ko-KR');
}

/** 1234567 → "1,234,567원" */
export function won(value: number): string {
	return `${comma(value)}원`;
}

/** 123456789 → "1억 2,345만 6,789원" (입력칸 아래 읽기 쉬운 표시) */
export function hangulWon(value: number): string {
	const n = Math.round(value);
	if (n === 0) return '0원';
	const jo = Math.floor(n / 1e12);
	const eok = Math.floor((n % 1e12) / 1e8);
	const man = Math.floor((n % 1e8) / 1e4);
	const rest = n % 1e4;
	const parts = [];
	if (jo) parts.push(`${comma(jo)}조`);
	if (eok) parts.push(`${comma(eok)}억`);
	if (man) parts.push(`${comma(man)}만`);
	if (rest) parts.push(comma(rest));
	return `${parts.join(' ')}원`;
}

/** 원 단위 아래를 버린다 (세금·보험료는 보통 원 미만 절사, 10원 미만 절사) */
// 3,000,000 × 0.009 = 26999.999… 같은 소수 오차로 10원이 덜 나오지 않게 아주 작은 값을 더한다
export const floorTo = (value: number, unit: number): number =>
	Math.floor(value / unit + 1e-9) * unit;
