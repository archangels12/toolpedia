// 매달 원천징수하는 근로소득세 (근로소득 간이세액표, 2026.3.1 시행)
import { floorTo } from './money.ts';
import { WAGE_TAX_AT_10M, WAGE_TAX_ROWS } from './wage-tax-table.ts';

export const WAGE_TAX_AS_OF = '2026년 3월 1일';

const TEN_MILLION = 10000000;

/** 가족 수 1~11명 칸의 세액 (원) */
function column(pay: number, family: number): number {
	const col = family + 1; // 행의 0·1번은 구간 경계
	if (pay < 770000) return 0;
	if (pay < TEN_MILLION) {
		const row = WAGE_TAX_ROWS.find(
			(r) => pay >= r[0]! * 1000 && pay < r[1]! * 1000,
		);
		return row ? row[col]! : 0;
	}
	const top = WAGE_TAX_AT_10M[family - 1]!;
	if (pay === TEN_MILLION) return top;
	// 1,000만 원 초과: 별표2 표 아래 계산식
	let extra: number;
	if (pay <= 14000000) extra = (pay - TEN_MILLION) * 0.98 * 0.35 + 25000;
	else if (pay <= 28000000)
		extra = 1397000 + (pay - 14000000) * 0.98 * 0.38;
	else if (pay <= 30000000)
		extra = 6610600 + (pay - 28000000) * 0.98 * 0.4;
	else if (pay <= 45000000) extra = 7394600 + (pay - 30000000) * 0.4;
	else if (pay <= 87000000) extra = 13394600 + (pay - 45000000) * 0.42;
	else extra = 31034600 + (pay - 87000000) * 0.45;
	return floorTo(top + extra, 10);
}

/** 8세 이상 20세 이하 자녀 수에 따른 공제액 (별표2 제3호) */
export function childCredit(children: number): number {
	if (children <= 0) return 0;
	if (children === 1) return 20830;
	return 45830 + Math.max(0, children - 2) * 33330;
}

/**
 * @param pay 비과세를 뺀 월급여 (원)
 * @param family 공제대상가족 수 (본인 포함, 1명 이상)
 * @param children 공제대상가족 중 8세 이상 20세 이하 자녀 수
 * @returns 소득세 (원). 지방소득세는 이 금액의 10%
 */
export function wageTax(pay: number, family: number, children = 0): number {
	const n = Math.max(1, Math.floor(family));
	let tax: number;
	if (n <= 11) tax = column(pay, n);
	else {
		// 별표2 제4호: 11명 세액 − (10명 세액 − 11명 세액) × 11명 초과 인원
		const t11 = column(pay, 11);
		const t10 = column(pay, 10);
		tax = t11 - (t10 - t11) * (n - 11);
	}
	return Math.max(0, tax - childCredit(children));
}

/** 지방소득세 = 소득세 × 10% (10원 미만 버림) */
export const localTax = (incomeTax: number): number =>
	floorTo(incomeTax * 0.1, 10);
