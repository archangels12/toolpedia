// 주식 평균단가(물타기)와 투자 수익률 (세금·수수료 제외)

export interface Lot {
	price: number;
	quantity: number;
}

export interface AverageResult {
	quantity: number;
	cost: number; // 매수 금액 합계
	average: number; // 평균단가
}

export function averagePrice(lots: Lot[]): AverageResult {
	const quantity = lots.reduce((s, l) => s + l.quantity, 0);
	const cost = lots.reduce((s, l) => s + l.price * l.quantity, 0);
	return {
		quantity,
		cost,
		average: quantity > 0 ? cost / quantity : 0,
	};
}

export interface ReturnResult {
	gain: number;
	ratePercent: number; // 총 수익률
	cagrPercent: number; // 연평균 수익률 (CAGR)
}

/** 원금과 평가금액, 보유 기간(년)으로 수익률과 연평균 수익률을 낸다 */
export function investReturn(
	cost: number,
	value: number,
	years: number,
): ReturnResult {
	if (cost <= 0) return { gain: 0, ratePercent: 0, cagrPercent: 0 };
	const ratio = value / cost;
	return {
		gain: value - cost,
		ratePercent: (ratio - 1) * 100,
		// CAGR = (평가금액 ÷ 원금)^(1/년) − 1
		cagrPercent: years > 0 ? (ratio ** (1 / years) - 1) * 100 : 0,
	};
}
