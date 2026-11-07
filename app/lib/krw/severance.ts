// 퇴직금 계산 (근로자퇴직급여 보장법 제8조, 근로기준법 제2조 평균임금)
// 퇴직금 = 1일 평균임금 × 30일 × (재직일수 ÷ 365)
// 1일 평균임금 = 퇴직 전 3개월 임금 총액 ÷ 그 3개월의 총일수
//   (연간 상여금·연차수당은 3/12 만큼 넣는다)

const DAY = 86400000;

/** "2026-11-07" → UTC 자정 시각(ms). 잘못된 값이면 NaN */
const toUtc = (iso: string): number => {
	const [y, m, d] = iso.split('-').map(Number);
	return y && m && d ? Date.UTC(y, m - 1, d) : NaN;
};

export interface SeveranceInput {
	/** 입사일 (YYYY-MM-DD) */
	start: string;
	/** 퇴직일 = 마지막 근무일의 다음 날 (YYYY-MM-DD) */
	end: string;
	/** 퇴직 전 3개월 동안 받은 임금 총액 (세전) */
	threeMonthPay: number;
	/** 퇴직 전 1년 동안 받은 상여금 총액 */
	yearlyBonus: number;
	/** 퇴직 전 1년 동안 받은 연차수당 */
	yearlyLeavePay: number;
}

export interface SeveranceResult {
	/** 재직일수 */
	days: number;
	/** 평균임금 산정 기간 일수 (89~92일) */
	periodDays: number;
	/** 1일 평균임금 (원 미만 포함) */
	dailyWage: number;
	/** 퇴직금 (원 미만 버림) */
	severance: number;
	/** 1년 이상 근무해 받을 자격이 있는지 */
	eligible: boolean;
	/** 날짜가 올바른지 */
	valid: boolean;
}

export function severancePay(input: SeveranceInput): SeveranceResult {
	const start = toUtc(input.start);
	const end = toUtc(input.end);
	const valid =
		Number.isFinite(start) && Number.isFinite(end) && end > start;
	if (!valid)
		return {
			days: 0,
			periodDays: 0,
			dailyWage: 0,
			severance: 0,
			eligible: false,
			valid,
		};

	const days = Math.round((end - start) / DAY);
	// 산정 기간: 퇴직일 3개월 전 같은 날부터 퇴직일 전날까지
	// (그 달에 같은 날이 없으면 그 달 말일, 예: 5월 31일 → 2월 28일)
	const endDate = new Date(end);
	const year = endDate.getUTCFullYear();
	const month = endDate.getUTCMonth() - 3;
	const lastDay = new Date(Date.UTC(year, month + 1, 0)).getUTCDate();
	const periodStart = Date.UTC(
		year,
		month,
		Math.min(endDate.getUTCDate(), lastDay),
	);
	const periodDays = Math.round((end - periodStart) / DAY);

	const wages =
		input.threeMonthPay +
		(input.yearlyBonus * 3) / 12 +
		(input.yearlyLeavePay * 3) / 12;
	const dailyWage = wages / periodDays;
	const severance = Math.floor((dailyWage * 30 * days) / 365);

	return {
		days,
		periodDays,
		dailyWage,
		severance,
		eligible: days >= 365,
		valid,
	};
}
