// 4대보험 월 보험료 (직장가입자, 2026년 요율)
// 기준: 4대사회보험 정보연계센터 보험료 모의계산 (4insure.or.kr), 보건복지부 보도자료
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
/** 건강보험료 근로자 부담 상·하한 (2026년, 전체 9,183,480원·20,160원의 절반) */
export const HEALTH_MAX = 4591740;
export const HEALTH_MIN = 10080;
/** 장기요양보험 = 건강보험료 × (0.9448% ÷ 7.19%), 2026년 */
export const CARE_RATIO = 0.9448 / 7.19;
/** 고용보험 실업급여 1.8% (각 0.9%) */
export const EMPLOYMENT_RATE = 0.009;
/** 사업주만 내는 고용안정·직업능력개발 (기업 규모별) */
export const STABILITY_RATES = [
	{ label: '150인 미만', rate: 0.0025 },
	{ label: '150인 이상 우선지원대상', rate: 0.0045 },
	{ label: '150인 이상 1,000인 미만', rate: 0.0065 },
	{ label: '1,000인 이상·국가기관', rate: 0.0085 },
];

export interface InsuranceResult {
	pension: number;
	health: number;
	care: number;
	employment: number;
	/** 근로자 부담 합계 */
	total: number;
	/** 사업주 부담 고용안정·직업능력개발 */
	stability: number;
	/** 사업주 부담 합계 (산재보험 제외) */
	employer: number;
	/** 국민연금 계산에 쓴 기준소득월액 */
	pensionBase: number;
}

/**
 * @param monthlyPay 비과세를 뺀 월 보수 (원)
 * @param stabilityRate 사업주 고용안정·직업능력개발 요율 (기본 150인 미만 0.25%)
 * 각 보험료는 10원 미만 버림 (공식 예시: 보수 200만 원 → 건강 71,900원, 장기요양 9,440원).
 * 국민연금 기준소득월액은 천원 미만 버림.
 */
export function insurance(
	monthlyPay: number,
	stabilityRate = STABILITY_RATES[0]!.rate,
): InsuranceResult {
	const pay = Math.max(0, monthlyPay);
	const pensionBase = floorTo(
		Math.min(Math.max(pay, PENSION_MIN), PENSION_MAX),
		1000,
	);
	const pension = pay ? floorTo(pensionBase * PENSION_RATE, 10) : 0;
	const health = pay
		? Math.min(
				Math.max(floorTo(pay * HEALTH_RATE, 10), HEALTH_MIN),
				HEALTH_MAX,
			)
		: 0;
	const care = floorTo(health * CARE_RATIO, 10);
	const employment = floorTo(pay * EMPLOYMENT_RATE, 10);
	const total = pension + health + care + employment;
	const stability = floorTo(pay * stabilityRate, 10);
	return {
		pension,
		health,
		care,
		employment,
		total,
		stability,
		employer: total + stability,
		pensionBase,
	};
}
