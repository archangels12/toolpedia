import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import DateField from 'delphitools-v2/components/tools/krw/date-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import { comma } from 'delphitools-v2/lib/krw/money';
import {
	addDays,
	addYears,
	koDate,
	todayIso,
	toUtc,
} from 'delphitools-v2/lib/life/date';
import {
	ANNIVERSARY_DAYS,
	between,
	ddayLabel,
	nthDay,
} from 'delphitools-v2/lib/life/dday';
import './krw/krw.css';

const modes = ['D-day·날짜 사이', 'N일 뒤 날짜', '기념일'];
const countNames = ['시작일 빼고 세기', '시작일을 1일로 세기'];
const directions = ['뒤 (더하기)', '앞 (빼기)'];

const today = todayIso();

export default class DdayCalc extends Component {
	@tracked mode = 0;
	@tracked start = today;
	@tracked end = addDays(today, 100);
	@tracked count = 0;
	@tracked days = 100;
	@tracked direction = 0;

	get isBetween() {
		return this.mode === 0;
	}

	get isAdd() {
		return this.mode === 1;
	}

	get startLabel() {
		return this.mode === 2 ? '처음 만난 날·태어난 날' : '시작일';
	}

	get lines(): ResultLine[] {
		if (Number.isNaN(toUtc(this.start)))
			return [{ label: '날짜를 넣어 주세요', value: '—' }];
		if (this.mode === 0) {
			const days = between(
				this.start,
				this.end,
				this.count === 1,
			);
			if (Number.isNaN(days))
				return [
					{
						label: '날짜를 넣어 주세요',
						value: '—',
					},
				];
			const abs = Math.abs(days);
			return [
				{
					label: '두 날짜 사이',
					value: `${comma(days)}일`,
					main: true,
				},
				{
					label: '오늘 기준',
					value: ddayLabel(today, this.end),
					note: koDate(this.end),
				},
				{
					label: '주로 바꾸면',
					value: `${Math.floor(abs / 7)}주 ${abs % 7}일`,
				},
				{
					label: '시간으로 바꾸면',
					value: `${comma(abs * 24)}시간`,
				},
			];
		}
		if (this.mode === 1) {
			const signed =
				this.direction === 0 ? this.days : -this.days;
			const date = addDays(this.start, signed);
			return [
				{
					label: `${comma(this.days)}일 ${this.direction === 0 ? '뒤' : '앞'}`,
					value: koDate(date),
					main: true,
				},
				{
					label: '오늘 기준',
					value: ddayLabel(today, date),
				},
			];
		}
		return ANNIVERSARY_DAYS.map((n, i) => {
			// 주년은 일수가 아니라 같은 월·일 (윤년이 끼면 365일 배수와 하루 차이)
			const years = n % 365 === 0 ? n / 365 : 0;
			const date = years
				? addYears(this.start, years)
				: nthDay(this.start, n);
			return {
				label: years ? `${years}주년` : `${comma(n)}일`,
				value: koDate(date),
				note: ddayLabel(today, date),
				main: i === 0,
			};
		});
	}

	pickMode = (index: number) => (this.mode = index);
	pickCount = (index: number) => (this.count = index);
	pickDirection = (index: number) => (this.direction = index);
	setStart = (value: string) => (this.start = value);
	setEnd = (value: string) => (this.end = value);
	setDays = (value: number) => (this.days = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="입력" />
					<div class="krw-form">
						<CanonSegmented
							aria-label="계산 방식"
							@items={{modes}}
							@selected={{this.mode}}
							@onChange={{this.pickMode}}
						/>
						<DateField
							@label={{this.startLabel}}
							@value={{this.start}}
							@onChange={{this.setStart}}
						/>
						{{#if this.isBetween}}
							<DateField
								@label="종료일 (D-day 날짜)"
								@value={{this.end}}
								@onChange={{this.setEnd}}
							/>
							<div class="krw-choice">
								<span
									class="krw-field-label"
								>일수 세는 방법</span>
								<CanonSegmented
									aria-label="일수 세는 방법"
									@items={{countNames}}
									@selected={{this.count}}
									@onChange={{this.pickCount}}
								/>
							</div>
						{{else if this.isAdd}}
							<NumberField
								@label="며칠"
								@value={{this.days}}
								@unit="일"
								@onChange={{this.setDays}}
							/>
							<CanonSegmented
								aria-label="방향"
								@items={{directions}}
								@selected={{this.direction}}
								@onChange={{this.pickDirection}}
							/>
						{{/if}}
					</div>
				</CanonRows>
			</:sidebar>
			<:main>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="계산 결과" />
					<KrwResult @lines={{this.lines}} />
				</CanonRows>
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="날짜 계산 방법" />
					<div class="krw-guide">
						<p>
							시험일, 출국일,
							전역일까지 며칠
							남았는지, 두 날짜 사이가
							며칠인지, 오늘부터 100일
							뒤가 언제인지
							계산합니다. 윤년(2월
							29일)도 자동으로
							반영합니다.
						</p>
						<ul>
							<li>
								D-day·날짜 사이:
								종료일 − 시작일.
								오늘 기준으로
								남았으면 D-숫자,
								지났으면
								D+숫자로 보여
								줍니다.
							</li>
							<li>
								N일 뒤 날짜:
								시작일에 일수를
								더하거나 뺍니다.
								시작일 다음 날이
								1일 뒤입니다.
							</li>
							<li>
								기념일: 처음
								만난 날이나
								태어난 날을
								1일째로 세서
								100일·200일·1000일이
								되는 날짜를 보여
								줍니다.
								1주년·2주년처럼
								해가 바뀌는
								기념일은 같은
								날짜로
								계산합니다.
							</li>
						</ul>
						<p>
							예를 들어 2026년 11월
							19일에 처음 만났다면
							만난 날을 1일로 세므로
							100일은 99일 뒤인 2027년
							2월 26일입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>시작일을 1일로
								세는 것과 빼고
								세는 것은 무엇이
								다른가요?</summary>
							<p>
								보통 "며칠
								남았다", "며칠
								지났다"는
								시작일을 빼고
								셉니다. 반면
								연애 기념일,
								아기 백일, 군
								복무일,
								금연·다이어트
								며칠째처럼
								첫날을 1일로
								치는 경우는
								시작일을 포함해
								하루가 더
								많습니다.
							</p>
						</details>
						<details>
							<summary>아기 백일은
								어떻게
								계산하나요?</summary>
							<p>
								태어난 날을
								1일로 세는 것이
								일반적이라
								기념일 모드에
								생년월일을
								넣으면 됩니다.
								태어난 날로부터
								99일 뒤가
								백일입니다.
							</p>
						</details>
						<details>
							<summary>공휴일을 뺀
								영업일도
								계산되나요?</summary>
							<p>
								이 계산기는
								달력상 모든 날을
								셉니다.
								주말·공휴일을 뺀
								영업일은 따로
								세어야 합니다.
							</p>
						</details>
					</div>
				</CanonRows>
				<KrwRelated @current="dday-calc" />
			</:end>
		</CanonSplit>
	</template>
}
