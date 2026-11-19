// 수면 주기 계산: 잠든 뒤 약 90분 단위로 얕은 잠·깊은 잠·렘수면이 한 번씩 돈다.
// 주기가 끝날 무렵 깨면 개운하다는 경험칙을 따른다.

export const CYCLE_MIN = 90;

/** "07:00" → 420 (분) */
export function toMin(hhmm: string): number {
	const [h, m] = hhmm.split(':').map(Number);
	return h !== undefined && m !== undefined && !Number.isNaN(h + m)
		? h * 60 + m
		: NaN;
}

/** 분 → "오전 7:00" (하루를 넘으면 돌려 쓴다) */
export function clock(min: number): string {
	const m = ((Math.round(min) % 1440) + 1440) % 1440;
	const h = Math.floor(m / 60);
	const ampm = h < 12 ? '오전' : '오후';
	const h12 = h % 12 === 0 ? 12 : h % 12;
	return `${ampm} ${h12}:${String(m % 60).padStart(2, '0')}`;
}

export interface SleepOption {
	cycles: number;
	/** 눕는 시각 또는 일어나는 시각 (분) */
	time: number;
	/** 실제로 자는 시간 (분) */
	sleep: number;
}

/** 일어날 시각에 맞춰 누울 시각 (긴 수면부터) */
export function bedtimes(wake: number, fallAsleep: number): SleepOption[] {
	return [6, 5, 4, 3].map((c) => ({
		cycles: c,
		time: wake - c * CYCLE_MIN - fallAsleep,
		sleep: c * CYCLE_MIN,
	}));
}

/** 누울 시각에 맞춰 일어날 시각 */
export function wakeTimes(bed: number, fallAsleep: number): SleepOption[] {
	return [6, 5, 4, 3].map((c) => ({
		cycles: c,
		time: bed + fallAsleep + c * CYCLE_MIN,
		sleep: c * CYCLE_MIN,
	}));
}

/** 450 → "7시간 30분" */
export function duration(min: number): string {
	const h = Math.floor(min / 60);
	const m = min % 60;
	return m ? `${h}시간 ${m}분` : `${h}시간`;
}
