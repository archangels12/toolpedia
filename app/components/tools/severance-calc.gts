import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import { comma, won } from 'delphitools-v2/lib/krw/money';
import { severancePay } from 'delphitools-v2/lib/krw/severance';
import './krw/krw.css';

const iso = (date: Date) =>
	`${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;

const today = new Date();
const threeYearsAgo = new Date(
	today.getFullYear() - 3,
	today.getMonth(),
	today.getDate(),
);

export default class SeveranceCalc extends Component {
	@tracked start = iso(threeYearsAgo);
	@tracked end = iso(today);
	@tracked monthlyPay = 3000000;
	@tracked yearlyBonus = 0;
	@tracked yearlyLeavePay = 0;

	get result() {
		return severancePay({
			start: this.start,
			end: this.end,
			threeMonthPay: this.monthlyPay * 3,
			yearlyBonus: this.yearlyBonus,
			yearlyLeavePay: this.yearlyLeavePay,
		});
	}

	get lines(): ResultLine[] {
		const r = this.result;
		if (!r.valid)
			return [
				{
					label: '날짜를 확인하세요',
					value: '—',
					note: '퇴직일이 입사일보다 뒤여야 해요',
				},
			];
		const years = Math.floor(r.days / 365);
		return [
			{
				label: '예상 퇴직금 (세전)',
				value: won(r.severance),
				main: true,
				note: r.eligible
					? undefined
					: '1년 미만 근무는 법정 퇴직금 대상이 아니에요',
			},
			{
				label: '재직일수',
				value: `${comma(r.days)}일`,
				note: `약 ${years}년 ${Math.floor((r.days % 365) / 30)}개월`,
			},
			{ label: '1일 평균임금', value: won(r.dailyWage) },
			{
				label: '평균임금 산정 기간',
				value: `${r.periodDays}일`,
			},
		];
	}

	setStart = (event: Event) =>
		(this.start = (event.target as HTMLInputElement).value);
	setEnd = (event: Event) =>
		(this.end = (event.target as HTMLInputElement).value);
	setPay = (value: number) => (this.monthlyPay = value);
	setBonus = (value: number) => (this.yearlyBonus = value);
	setLeave = (value: number) => (this.yearlyLeavePay = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="근무 정보" />
					<div class="krw-form">
						<label class="krw-field">
							<span
								class="krw-field-label"
							>입사일</span>
							<span
								class="krw-field-box"
							>
								<input
									type="date"
									value={{this.start}}
									{{on
										"change"
										this.setStart
									}}
								/>
							</span>
						</label>
						<label class="krw-field">
							<span
								class="krw-field-label"
							>퇴직일</span>
							<span
								class="krw-field-box"
							>
								<input
									type="date"
									value={{this.end}}
									{{on
										"change"
										this.setEnd
									}}
								/>
							</span>
							<span
								class="krw-field-note"
							>마지막 근무일의 다음 날</span>
						</label>
						<MoneyField
							@label="월 급여 (세전, 퇴직 전 3개월 평균)"
							@value={{this.monthlyPay}}
							@onChange={{this.setPay}}
						/>
						<MoneyField
							@label="연간 상여금 (선택)"
							@value={{this.yearlyBonus}}
							@hint="퇴직 전 1년 동안 받은 상여금 총액"
							@onChange={{this.setBonus}}
						/>
						<MoneyField
							@label="연차수당 (선택)"
							@value={{this.yearlyLeavePay}}
							@hint="퇴직 전 1년 동안 받은 연차수당"
							@onChange={{this.setLeave}}
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
						@text="퇴직금 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							퇴직금 = 1일 평균임금 ×
							30일 × (재직일수 ÷ 365).
							즉 1년 일할 때마다
							30일분 평균임금을
							받습니다.
						</p>
						<ul>
							<li>
								1일 평균임금 =
								퇴직 전 3개월
								동안 받은 임금
								총액 ÷ 그
								3개월의
								총일수(89~92일)
							</li>
							<li>
								상여금과
								연차수당은 퇴직
								전 1년 동안 받은
								금액의 3/12을
								3개월 임금에
								더합니다.
							</li>
							<li>
								이 계산기는 월
								급여 × 3을 3개월
								임금 총액으로
								봅니다. 달마다
								급여가 다르면 세
								달 평균을
								넣으세요.
							</li>
						</ul>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>퇴직금은 누가
								받을 수 있나요?</summary>
							<p>
								같은 회사에서
								1년 이상 일했고,
								4주 평균 1주
								근무시간이
								15시간 이상인
								근로자가
								받습니다.
								정규직·계약직·아르바이트
								구분 없이
								적용됩니다.
							</p>
						</details>
						<details>
							<summary>퇴직일은 언제로
								넣어야 하나요?</summary>
							<p>
								마지막으로 일한
								날의 다음
								날입니다. 10월
								31일까지
								일했다면
								퇴직일은 11월
								1일입니다.
							</p>
						</details>
						<details>
							<summary>실제로 받는
								금액과 다른
								이유는요?</summary>
							<p>
								결과는 세금을
								떼기 전
								금액입니다.
								퇴직소득세와
								지방소득세가
								빠지고,
								평균임금이
								통상임금보다
								적으면
								통상임금으로
								계산하는 등
								예외가 있어 실제
								금액은 회사
								정산을
								확인하세요.
							</p>
						</details>
						<details>
							<summary>퇴직금은
								언제까지 받아야
								하나요?</summary>
							<p>
								퇴직한 날부터
								14일 안에
								지급하는 것이
								원칙입니다.
								당사자끼리
								합의하면 기일을
								연장할 수
								있습니다.
							</p>
						</details>
						<p class="krw-source">
							근거: 근로자퇴직급여
							보장법
							제4조·제8조·제9조,
							근로기준법
							제2조(평균임금)
						</p>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
