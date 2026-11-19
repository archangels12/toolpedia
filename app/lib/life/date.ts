// 생활 계산기 공용 날짜 함수. 날짜는 "YYYY-MM-DD" 문자열로 다루고,
// 시차·서머타임 영향을 받지 않게 UTC 자정 기준으로 계산한다.

export const DAY = 86400000;

/** "2026-11-19" → UTC 자정(ms). 잘못된 값이면 NaN */
export function toUtc(iso: string): number {
	const [y, m, d] = iso.split('-').map(Number);
	return y && m && d ? Date.UTC(y, m - 1, d) : NaN;
}

/** UTC ms → "2026-11-19" */
export function fromUtc(ms: number): string {
	return new Date(ms).toISOString().slice(0, 10);
}

/** 오늘 날짜 (사용자 기기 시간대 기준) */
export function todayIso(): string {
	const t = new Date();
	return `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, '0')}-${String(t.getDate()).padStart(2, '0')}`;
}

/** b − a 일수 */
export const daysBetween = (a: string, b: string): number =>
	Math.round((toUtc(b) - toUtc(a)) / DAY);

export const addDays = (iso: string, days: number): string =>
	fromUtc(toUtc(iso) + days * DAY);

/** 같은 월·일로 n년 뒤 (2월 29일 → 평년엔 3월 1일) */
export function addYears(iso: string, years: number): string {
	const [y, m, d] = iso.split('-').map(Number) as [
		number,
		number,
		number,
	];
	return fromUtc(Date.UTC(y + years, m - 1, d));
}

const WEEK = ['일', '월', '화', '수', '목', '금', '토'];

/** "2026-11-19" → "2026년 11월 19일 (목)" */
export function koDate(iso: string): string {
	const ms = toUtc(iso);
	if (Number.isNaN(ms)) return '—';
	const d = new Date(ms);
	return `${d.getUTCFullYear()}년 ${d.getUTCMonth() + 1}월 ${d.getUTCDate()}일 (${WEEK[d.getUTCDay()]})`;
}
