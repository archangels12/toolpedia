// 4대보험 월 보험료 (직장가입자, 2026년 요율)
// 매년 바뀌므로 아래 값과 RATES_AS_OF 를 함께 고친다.
import { floorTo } from './money.ts';

export const RATES_AS_OF = '2026년 7월';

/** 국민연금 9.5% (근로자·사업주 각 4.75%), 2026년 1월부터 */
export const PENSION_RATE = 0.0475;
/** 국민연금 기준소득월액 상·하한 (2026.7 ~ 2027.6) */
export const PENSION_MIN = 410000;
export const PENSION_MAX = 6590000;
/** 건강보험 7.19% (각 3.595%), 2026년 */
export const HEALTH_RATE = 0.03595;
/** 장기요양보험 = 건강보험료 × 13.14% (소득 대비 0.9448%), 2026년 */
export const CARE_RATIO = 0.1314;
/** 고용보험 실업급여 1.8% (각 0.9%) */
export const EMPLOYMENT_RATE = 0.009;
/** 사업주만 내는 고용안정·직업능력개발 (150인 미만 기업 0.25%) */
export const EMPLOYER_STABILITY_RATE = 0.0025;

export interface InsuranceResult {
	pension: number;
	health: number;
	care: number;
	employment: number;
	/** 근로자 부담 합계 */
	total: number;
	/** 사업주 부담 (산재보험 제외) */
	employer: number;
	/** 국민연금 계산에 쓴 기준소득월액 */
	pensionBase: number;
}

/**
 * @param monthlyPay 비과세를 뺀 월 보수 (원)
 * 보험료는 10원 미만 버림. 국민연금 기준소득월액은 천원 미만 버림.
 */
export function insurance(monthlyPay: number): InsuranceResult {
	const pay = Math.max(0, monthlyPay);
	const pensionBase = floorTo(
		Math.min(Math.max(pay, PENSION_MIN), PENSION_MAX),
		1000,
	);
	const pension = pay ? floorTo(pensionBase * PENSION_RATE, 10) : 0;
	const health = floorTo(pay * HEALTH_RATE, 10);
	const care = floorTo(health * CARE_RATIO, 10);
	const employment = floorTo(pay * EMPLOYMENT_RATE, 10);
	const total = pension + health + care + employment;
	const employer =
		total + floorTo(pay * EMPLOYER_STABILITY_RATE, 10);
	return { pension, health, care, employment, total, employer, pensionBase };
}
