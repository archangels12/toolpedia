// 체질량지수(BMI) = 몸무게(kg) ÷ 키(m)²
// 판정은 대한비만학회 성인 기준 (아시아인 기준, WHO 서양 기준 25·30과 다르다)

export const BMI_LEVELS = [
	{ max: 18.5, label: '저체중' },
	{ max: 23, label: '정상' },
	{ max: 25, label: '비만 전 단계 (과체중)' },
	{ max: 30, label: '1단계 비만' },
	{ max: 35, label: '2단계 비만' },
	{ max: Infinity, label: '3단계 비만 (고도 비만)' },
];

export function bmi(heightCm: number, weightKg: number) {
	const m = heightCm / 100;
	if (!(m > 0) || !(weightKg > 0))
		return { valid: false, value: 0, label: '', min: 0, max: 0 };
	const value = weightKg / (m * m);
	// 판정은 소수 첫째 자리로 반올림한 값으로 한다 (22.96 → 23.0 → 비만 전 단계)
	const shown = Math.round(value * 10) / 10;
	const label = BMI_LEVELS.find((l) => shown < l.max)!.label;
	return {
		valid: true,
		value: shown,
		label,
		// 정상 범위(18.5 이상 23 미만)에 해당하는 몸무게
		min: Math.round(18.5 * m * m * 10) / 10,
		max: Math.round(22.9 * m * m * 10) / 10,
	};
}
