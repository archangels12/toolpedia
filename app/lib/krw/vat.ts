// 부가가치세 계산 (세율 10%, 부가가치세법 제30조)
export const VAT_RATE = 0.1;

export interface VatResult {
	supply: number; // 공급가액
	vat: number; // 부가세
	total: number; // 합계(공급대가)
}

/** 공급가액에서: 부가세 = 공급가액 × 10% (원 미만 버림) */
export function fromSupply(supply: number): VatResult {
	const vat = Math.floor(supply * VAT_RATE);
	return { supply, vat, total: supply + vat };
}

/** 합계금액에서: 공급가액 = 합계 × 10/11 (원 미만 올림), 부가세 = 합계 − 공급가액 */
export function fromTotal(total: number): VatResult {
	// 1.1 로 나누면 소수 오차로 1원이 틀어질 수 있어 정수로 계산한다
	const supply = Math.ceil((total * 10) / 11);
	return { supply, vat: total - supply, total };
}
