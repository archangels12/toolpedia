// 중도상환수수료 = 상환 금액 × 수수료율 × 남은 기간 ÷ 수수료 부과 기간
// 부과 기간은 보통 대출 후 3년. 기간이 지나면 수수료가 없다. 기간 단위(일·개월)는 같기만 하면 된다.

export interface PrepaymentResult {
	fee: number;
	remaining: number; // 수수료 부과 기간 중 남은 기간
	ratio: number; // 남은 기간 비율 (0~1)
}

export function prepaymentFee(
	repayAmount: number,
	feeRatePercent: number,
	elapsed: number, // 대출받은 뒤 지난 기간
	period: number, // 수수료 부과 기간
): PrepaymentResult {
	const remaining = Math.max(period - elapsed, 0);
	const ratio = period > 0 ? remaining / period : 0;
	return {
		fee: Math.floor(repayAmount * (feeRatePercent / 100) * ratio),
		remaining,
		ratio,
	};
}
