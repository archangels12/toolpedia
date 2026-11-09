// 복리·적립식 투자: 처음 넣는 돈 + 매달 넣는 돈이 연 수익률로 불어난 결과 (세금·수수료 제외)
// 월 수익률 = (1 + 연 수익률)^(1/12) − 1 (연 수익률을 1년 뒤 정확히 맞추는 월 환산)
// 매달 넣는 돈은 월초에 넣는다고 본다.

export interface CompoundYear {
	year: number;
	paid: number; // 그해 말까지 넣은 돈 합계
	value: number; // 그해 말 평가금액
}

export interface CompoundResult {
	paid: number;
	value: number;
	gain: number;
	years: CompoundYear[];
}

export function compound(
	initial: number,
	monthly: number,
	annualRatePercent: number,
	years: number,
): CompoundResult {
	const m = (1 + annualRatePercent / 100) ** (1 / 12) - 1;
	const months = Math.round(years * 12);
	let value = initial;
	let paid = initial;
	const rows: CompoundYear[] = [];
	for (let month = 1; month <= months; month++) {
		value = (value + monthly) * (1 + m);
		paid += monthly;
		if (month % 12 === 0 || month === months)
			rows.push({
				year: Math.ceil(month / 12),
				paid,
				value: Math.round(value),
			});
	}
	value = Math.round(value);
	return { paid, value, gain: value - paid, years: rows };
}
