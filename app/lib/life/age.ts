// 나이 계산: 만 나이(민법 제158조, 2023.6.28 시행 '만 나이 통일법'), 연 나이, 세는 나이
import { daysBetween, toUtc } from './date.ts';

const ZODIAC = [
	'쥐',
	'소',
	'호랑이',
	'토끼',
	'용',
	'뱀',
	'말',
	'양',
	'원숭이',
	'닭',
	'개',
	'돼지',
];

export interface AgeResult {
	valid: boolean;
	/** 만 나이: 생일이 지나야 한 살 더한다 */
	man: number;
	/** 연 나이: 기준 연도 − 출생 연도 (병역법·청소년보호법 등) */
	year: number;
	/** 세는 나이: 연 나이 + 1 */
	counting: number;
	/** 띠 (양력 출생 연도 기준) */
	zodiac: string;
	/** 태어난 날부터 기준일까지 일수 (태어난 날 = 0일) */
	daysLived: number;
	/** 다음 생일까지 남은 일수 (오늘이 생일이면 0) */
	daysToBirthday: number;
}

export function age(birth: string, ref: string): AgeResult {
	const b = toUtc(birth);
	const r = toUtc(ref);
	const empty = {
		valid: false,
		man: 0,
		year: 0,
		counting: 0,
		zodiac: '',
		daysLived: 0,
		daysToBirthday: 0,
	};
	if (Number.isNaN(b) || Number.isNaN(r) || r < b) return empty;
	const [by, bm, bd] = birth.split('-').map(Number) as [
		number,
		number,
		number,
	];
	const [ry, rm, rd] = ref.split('-').map(Number) as [
		number,
		number,
		number,
	];
	// 생일(월·일)이 아직 안 왔으면 한 살 뺀다. 2월 29일생은 평년엔 3월 1일에 나이가 든다
	const passed = rm > bm || (rm === bm && rd >= bd);
	const man = ry - by - (passed ? 0 : 1);
	const yearAge = ry - by;
	// 다음 생일: 올해 생일이 지났으면 내년. 2월 29일이 없는 해는 3월 1일로 본다
	const birthdayIn = (y: number) => {
		const ms = Date.UTC(y, bm - 1, bd);
		return new Date(ms).getUTCMonth() === bm - 1
			? ms
			: Date.UTC(y, 2, 1);
	};
	let next = birthdayIn(ry);
	if (next < r) next = birthdayIn(ry + 1);
	return {
		valid: true,
		man,
		year: yearAge,
		counting: yearAge + 1,
		zodiac: ZODIAC[(((by - 4) % 12) + 12) % 12]!,
		daysLived: daysBetween(birth, ref),
		daysToBirthday: Math.round((next - r) / 86400000),
	};
}
