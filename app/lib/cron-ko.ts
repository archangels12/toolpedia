// 크론 표현식을 한국어 문장으로 설명한다 (cron.ts 의 describeCron 은 영어, 테스트용으로 그대로 둔다)
// 어순: 월 → 날짜/요일 → 시각. 예) "30 9 * * 1-5" → "평일 09:30에"
import type { FieldParse } from './cron.ts';

const DOW = [
	'일요일',
	'월요일',
	'화요일',
	'수요일',
	'목요일',
	'금요일',
	'토요일',
];

/** [1,2,3] → "1~3", [1,3,5] → "1, 3, 5" */
function join(values: number[]): string {
	const contiguous =
		values.length >= 3 &&
		values.every((v, i) => i === 0 || v === values[i - 1]! + 1);
	if (contiguous) return `${values[0]}~${values[values.length - 1]}`;
	return values.join(', ');
}

const pad = (n: number) => String(n).padStart(2, '0');

function hourText(field: FieldParse): string {
	if (!field.ok || field.any) return '';
	const s = field.shape;
	if (s.kind === 'single') return `${s.value}시`;
	if (s.kind === 'step') return `${s.step}시간마다`;
	if (s.kind === 'range' && s.step > 1)
		return `${s.lo}~${s.hi}시 사이 ${s.step}시간마다`;
	if (s.kind === 'range') return `${s.lo}~${s.hi}시`;
	return `${join(field.values)}시`;
}

function timeText(minute: FieldParse, hour: FieldParse): string {
	if (!minute.ok) return '';
	const hourOk = hour.ok && !hour.any;
	const h = hourText(hour);
	const at = (text: string) => (hourOk ? `${h} ${text}` : `매시 ${text}`);
	const m = minute.shape;
	if (m.kind === 'star' || (m.kind === 'step' && m.step === 1))
		return hourOk ? `${h} 동안 매분` : '매분';
	if (m.kind === 'step')
		return hourOk ? `${h} 동안 ${m.step}분마다` : `${m.step}분마다`;
	if (m.kind === 'single') {
		if (hour.ok && hour.shape.kind === 'single')
			return `${pad(hour.shape.value)}:${pad(m.value)}에`;
		return `${at(m.value === 0 ? '정각' : `${m.value}분`)}에`;
	}
	if (m.kind === 'range')
		return at(
			m.step > 1
				? `${m.lo}~${m.hi}분 사이 ${m.step}분마다`
				: `${m.lo}~${m.hi}분 동안 매분`,
		);
	return `${at(`${join(minute.values)}분`)}에`;
}

function domText(dom: FieldParse, monthSet: boolean): string {
	if (!dom.ok || dom.any) return '';
	return `${monthSet ? '' : '매월 '}${join(dom.values)}일`;
}

function dowText(dow: FieldParse): string {
	if (!dow.ok || dow.any) return '';
	const v = dow.values;
	if (v.length === 5 && v.every((d, i) => d === i + 1)) return '평일';
	if (v.length === 2 && v[0] === 0 && v[1] === 6) return '주말';
	return v.map((d) => DOW[d]!).join('·');
}

function monthText(month: FieldParse): string {
	if (!month.ok || month.any) return '';
	return `${join(month.values)}월`;
}

export function describeCronKo(fields: FieldParse[]): string {
	const [minute, hour, dom, month, dow] = fields as [
		FieldParse,
		FieldParse,
		FieldParse,
		FieldParse,
		FieldParse,
	];
	const monthPart = monthText(month);
	const day = [domText(dom, !!monthPart), dowText(dow)]
		.filter(Boolean)
		.join(' 또는 ');
	return [monthPart, day, timeText(minute, hour)]
		.filter(Boolean)
		.join(' ');
}
