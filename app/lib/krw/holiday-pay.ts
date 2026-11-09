// 주휴수당 (근로기준법 제55조, 시행령 제30조): 1주 소정근로시간 15시간 이상이고 결근이 없으면 지급
// 주휴수당 = (1주 소정근로시간 ÷ 40) × 8 × 시급. 40시간이 넘어도 8시간분까지만.

// 최저임금 (고용노동부 고시). 해가 바뀌면 고친다.
export const MIN_WAGE = 10320;
export const MIN_WAGE_YEAR = 2026;

export interface HolidayPayResult {
	eligible: boolean;
	hours: number; // 주휴 시간
	holidayPay: number; // 주 주휴수당
	weeklyPay: number; // 주급 (근무 + 주휴)
	monthlyHours: number; // 월 환산 시간 (주 40시간이면 209시간)
	monthlyPay: number;
}

export function holidayPay(
	hourly: number,
	weeklyHours: number,
): HolidayPayResult {
	const eligible = weeklyHours >= 15;
	const hours = eligible ? (Math.min(weeklyHours, 40) / 40) * 8 : 0;
	const holiday = Math.round(hours * hourly);
	const weekly = Math.round(weeklyHours * hourly) + holiday;
	// 한 달 평균 주 수 = 365 ÷ 7 ÷ 12 ≈ 4.345. 고용노동부처럼 시간을 반올림한다 (48시간 → 209시간)
	const monthlyHours = Math.round((weeklyHours + hours) * (365 / 7 / 12));
	return {
		eligible,
		hours,
		holidayPay: holiday,
		weeklyPay: weekly,
		monthlyHours,
		monthlyPay: Math.round(monthlyHours * hourly),
	};
}
