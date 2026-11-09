import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult from 'delphitools-v2/components/tools/krw/result';
import { comma, won } from 'delphitools-v2/lib/krw/money';
import {
	holidayPay,
	MIN_WAGE,
	MIN_WAGE_YEAR,
} from 'delphitools-v2/lib/krw/holiday-pay';
import './krw/krw.css';

export default class HolidayPayCalc extends Component {
	@tracked hourly = MIN_WAGE;
	@tracked hours = 20;

	get lines() {
		const r = holidayPay(this.hourly, Math.min(this.hours, 52));
		return [
			{
				label: '주휴수당 (1주)',
				value: won(r.holidayPay),
				main: true,
				note: r.eligible
					? `주휴 ${Number(r.hours.toFixed(2))}시간분`
					: '주 15시간 미만이라 주휴수당이 없어요',
			},
			{
				label: '주급 (근무 + 주휴)',
				value: won(r.weeklyPay),
			},
			{
				label: '월급 환산',
				value: won(r.monthlyPay),
				note: `월 ${r.monthlyHours}시간 기준`,
			},
			{
				label: '시급 확인',
				value:
					this.hourly < MIN_WAGE
						? `최저임금(${comma(MIN_WAGE)}원)보다 낮아요`
						: '최저임금 이상',
			},
		];
	}

	setHourly = (value: number) => (this.hourly = value);
	setHours = (value: number) => (this.hours = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="근무 조건" />
					<div class="krw-form">
						<MoneyField
							@label="시급"
							@value={{this.hourly}}
							@hangul={{false}}
							@hint="{{MIN_WAGE_YEAR}}년 최저임금 {{comma
								MIN_WAGE
							}}원"
							@onChange={{this.setHourly}}
						/>
						<NumberField
							@label="1주 근무시간"
							@value={{this.hours}}
							@unit="시간"
							@decimal={{true}}
							@hint="계약서에 정한 시간 (연장근무 제외)"
							@onChange={{this.setHours}}
						/>
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
					<CanonHeading
						@text="주휴수당 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							1주에 15시간 이상
							일하기로 하고 그 주에
							빠짐없이 일했다면,
							일하지 않는 하루치
							임금을 주휴수당으로
							받습니다. 주휴수당 =
							(1주 근무시간 ÷ 40) × 8
							× 시급. 40시간을 넘게
							일해도 8시간분까지만
							받습니다.
						</p>
						<p>
							{{MIN_WAGE_YEAR}}년
							최저임금
							{{comma MIN_WAGE}}원으로
							주 40시간 일하면
							주휴수당은 8시간분인
							82,560원이고, 월급으로는
							209시간분인
							2,156,880원입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>알바도
								주휴수당을
								받나요?</summary>
							<p>
								네.
								아르바이트·단시간
								근로자도 1주
								15시간 이상
								일하기로 했고
								결근이 없으면
								받습니다. 상시
								4명 이하인 작은
								가게도 똑같이
								적용됩니다.
							</p>
						</details>
						<details>
							<summary>지각하거나
								조퇴하면 못
								받나요?</summary>
							<p>
								지각·조퇴는
								결근이 아니므로
								주휴수당을 받을
								수 있습니다.
								정해진 날에 아예
								나오지 않은
								결근이 있으면 그
								주 주휴수당이
								없습니다.
							</p>
						</details>
						<details>
							<summary>월급 환산은
								어떻게 하나요?</summary>
							<p>
								1년은 52주보다
								조금 길어 한 달
								평균 약
								4.345주입니다.
								(1주 근무시간 +
								주휴시간) ×
								4.345를 반올림한
								시간에 시급을
								곱합니다. 주
								40시간이면
								209시간입니다.
							</p>
						</details>
						<p class="krw-source">
							근거: 근로기준법 제55조,
							같은 법 시행령 제30조,
							제18조 제3항(주 15시간
							미만 제외),
							{{MIN_WAGE_YEAR}}년 적용
							최저임금 고시
						</p>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
