// 기초대사량(BMR): Mifflin-St Jeor 공식 (1990)
//   남 = 10×몸무게(kg) + 6.25×키(cm) − 5×나이 + 5
//   여 = 10×몸무게(kg) + 6.25×키(cm) − 5×나이 − 161
// 하루 소비 칼로리(TDEE) = BMR × 활동 계수

export const ACTIVITY = [
	{
		label: '거의 안 움직임',
		note: '앉아서 일하고 운동 안 함',
		factor: 1.2,
	},
	{ label: '가벼운 활동', note: '주 1~3회 가벼운 운동', factor: 1.375 },
	{ label: '보통 활동', note: '주 3~5회 운동', factor: 1.55 },
	{ label: '많은 활동', note: '주 6~7회 운동', factor: 1.725 },
	{
		label: '매우 많은 활동',
		note: '하루 2번 운동, 육체노동',
		factor: 1.9,
	},
];

export function bmr(
	male: boolean,
	age: number,
	heightCm: number,
	weightKg: number,
): number {
	if (!(age > 0 && heightCm > 0 && weightKg > 0)) return 0;
	return Math.round(
		10 * weightKg + 6.25 * heightCm - 5 * age + (male ? 5 : -161),
	);
}

export const tdee = (base: number, activity: number): number =>
	Math.round(base * (ACTIVITY[activity]?.factor ?? 1.2));
