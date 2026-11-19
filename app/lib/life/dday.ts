// D-day·날짜 계산
import { addDays, daysBetween, toUtc } from './date.ts';

/** 두 날짜 사이 일수. includeStart 면 시작일을 1일째로 센다 (기념일·복무일 세는 방식) */
export function between(
	start: string,
	end: string,
	includeStart: boolean,
): number {
	if (Number.isNaN(toUtc(start)) || Number.isNaN(toUtc(end))) return NaN;
	const days = daysBetween(start, end);
	return includeStart ? days + (days >= 0 ? 1 : -1) : days;
}

/** "D-3" "D-Day" "D+5" (오늘 기준 목표일) */
export function ddayLabel(today: string, target: string): string {
	const d = daysBetween(today, target);
	if (Number.isNaN(d)) return '—';
	if (d === 0) return 'D-Day';
	return d > 0 ? `D-${d}` : `D+${-d}`;
}

export const ANNIVERSARY_DAYS = [
	100, 200, 300, 365, 500, 730, 1000, 1095, 2000, 3000,
];

/** 시작일을 1일째로 셀 때 N일째 되는 날 = 시작일 + (N − 1) */
export const nthDay = (start: string, n: number): string =>
	addDays(start, n - 1);
