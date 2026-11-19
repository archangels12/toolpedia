// 생리 주기·배란일 (달력법). 배란은 다음 생리 예정일 약 14일 전,
// 가임기는 배란일 5일 전부터 배란 다음 날까지로 본다 (정자 생존 약 5일, 난자 약 1일).
// 출산예정일: 네겔레 법칙 = 마지막 생리 시작일 + 280일, 주기가 28일과 다르면 그 차이만큼 더하거나 뺀다.
import { addDays, daysBetween, toUtc } from './date.ts';

export interface Cycle {
	start: string;
	ovulation: string;
	fertileStart: string;
	fertileEnd: string;
}

/** 마지막 생리 시작일과 주기로 앞으로 n번의 주기 */
export function cycles(lastPeriod: string, length: number, n: number): Cycle[] {
	if (Number.isNaN(toUtc(lastPeriod)) || !(length >= 20 && length <= 45))
		return [];
	return Array.from({ length: n }, (_, i) => {
		const start = addDays(lastPeriod, length * (i + 1));
		const ovulation = addDays(start, -14);
		return {
			start,
			ovulation,
			fertileStart: addDays(ovulation, -5),
			fertileEnd: addDays(ovulation, 1),
		};
	});
}

export interface Pregnancy {
	valid: boolean;
	dueDate: string;
	/** 기준일 현재 임신 주수·일 (주기 보정 반영) */
	weeks: number;
	days: number;
	/** 출산예정일까지 남은 일수 */
	daysLeft: number;
	trimester: number;
}

export function pregnancy(
	lastPeriod: string,
	cycleLength: number,
	today: string,
): Pregnancy {
	if (
		Number.isNaN(toUtc(lastPeriod)) ||
		!(cycleLength >= 20 && cycleLength <= 45)
	)
		return {
			valid: false,
			dueDate: '',
			weeks: 0,
			days: 0,
			daysLeft: 0,
			trimester: 0,
		};
	// 주기가 길면 배란이 늦으므로 임신 시작 기준일을 그만큼 뒤로 민다
	const base = addDays(lastPeriod, cycleLength - 28);
	const elapsed = daysBetween(base, today);
	const weeks = Math.floor(elapsed / 7);
	return {
		valid: elapsed >= 0,
		dueDate: addDays(base, 280),
		weeks,
		days: elapsed - weeks * 7,
		daysLeft: 280 - elapsed,
		trimester: weeks < 14 ? 1 : weeks < 28 ? 2 : 3,
	};
}
