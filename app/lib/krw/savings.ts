// 예금·적금 이자 계산 (세전 이자 → 이자소득세 → 세후 수령액)
// 예금: 원금을 한 번에 맡긴다. 적금: 매달 같은 금액을 넣는다 (정기적금).
// 단리 = 원금 × 연이율 × 개월/12. 월복리 = 원금 × ((1 + 연이율/12)^개월 − 1).
// 적금 단리 이자 = 월납입 × 연이율/12 × n(n+1)/2 (첫 달 넣은 돈은 n개월, 마지막 달은 1개월 이자)

import { floorTo } from './money.ts';

export type SavingsKind = 'deposit' | 'installment';
export type InterestKind = 'simple' | 'compound';

// 이자소득세율 (지방소득세 포함). 일반 15.4% = 소득세 14% + 지방소득세 1.4%.
// 상호금융 저율과세 1.4%는 농어촌특별세만 내는 조합 예탁금 (3천만 원 한도, 조건은 조합에 확인)
export const TAX_RATES = { normal: 0.154, free: 0, mutual: 0.014 } as const;
export type TaxKind = keyof typeof TAX_RATES;

export interface SavingsResult {
	principal: number; // 넣은 돈 합계
	interest: number; // 세전 이자
	tax: number;
	afterTaxInterest: number;
	total: number; // 세후 만기 수령액
}

export function savings(
	kind: SavingsKind,
	amount: number, // 예금: 맡긴 돈, 적금: 월 납입액
	annualRatePercent: number,
	months: number,
	interestKind: InterestKind,
	taxKind: TaxKind,
): SavingsResult {
	const r = annualRatePercent / 100;
	const i = r / 12;
	let principal: number;
	let interest: number;

	if (kind === 'deposit') {
		principal = amount;
		interest =
			interestKind === 'simple'
				? (amount * r * months) / 12
				: amount * ((1 + i) ** months - 1);
	} else {
		principal = amount * months;
		interest =
			interestKind === 'simple'
				? (amount * i * months * (months + 1)) / 2
				: // 매달 넣은 돈이 남은 개월만큼 월복리로 불어난다
					Array.from(
						{ length: months },
						(_, k) =>
							amount *
							((1 + i) **
								(months - k) -
								1),
					).reduce((a, b) => a + b, 0);
	}

	interest = Math.floor(interest);
	// 국세·지방세 각각 10원 미만 절사 (일반과세: 소득세 14% + 지방소득세 = 소득세의 10%)
	let tax: number;
	if (taxKind === 'normal') {
		const income = floorTo(interest * 0.14, 10);
		tax = income + floorTo(income * 0.1, 10);
	} else tax = floorTo(interest * TAX_RATES[taxKind], 10);

	return {
		principal,
		interest,
		tax,
		afterTaxInterest: interest - tax,
		total: principal + interest - tax,
	};
}
