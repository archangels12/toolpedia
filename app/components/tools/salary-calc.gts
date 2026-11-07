import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import { comma, won } from 'delphitools-v2/lib/krw/money';
import { salary } from 'delphitools-v2/lib/krw/salary';
import { WAGE_TAX_AS_OF } from 'delphitools-v2/lib/krw/wage-tax';
import { RATES_AS_OF } from 'delphitools-v2/lib/krw/insurance';
import './krw/krw.css';

// 자주 찾는 연봉 (만원)
const presets = [3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000, 10000];

export default class SalaryCalc extends Component {
	@tracked annual = 50000000;
	@tracked taxFree = 200000;
	@tracked family = 1;
	@tracked children = 0;

	get result() {
		return salary({
			annual: this.annual,
			taxFreeMonthly: this.taxFree,
			family: this.family || 1,
			children: Math.min(this.children, Math.max(0, (this.family || 1) - 1)),
		});
	}

	get lines(): ResultLine[] {
		const r = this.result;
		return [
			{
				label: '월 실수령액',
				value: won(r.net),
				main: true,
				note: `연 ${comma(r.netAnnual)}원`,
			},
			{ label: '월 급여 (세전)', value: won(r.monthly) },
			{ label: '공제 합계', value: won(r.deductions) },
			{ label: '국민연금', value: won(r.insurance.pension) },
			{ label: '건강보험', value: won(r.insurance.health) },
			{ label: '장기요양보험', value: won(r.insurance.care) },
			{ label: '고용보험', value: won(r.insurance.employment) },
			{ label: '근로소득세', value: won(r.incomeTax) },
			{ label: '지방소득세', value: won(r.localTax) },
		];
	}

	get table() {
		return presets.map((man) => {
			const r = salary({
				annual: man * 10000,
				taxFreeMonthly: this.taxFree,
				family: this.family || 1,
				children: Math.min(this.children, Math.max(0, (this.family || 1) - 1)),
			});
			return {
				annual: `${comma(man)}만 원`,
				net: comma(r.net),
				deductions: comma(r.deductions),
			};
		});
	}

	setAnnual = (value: number) => (this.annual = value);
	setTaxFree = (value: number) => (this.taxFree = value);
	setFamily = (value: number) => (this.family = Math.min(value, 20));
	setChildren = (value: number) => (this.children = Math.min(value, 19));

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="연봉 정보" />
					<div class="krw-form">
						<MoneyField
							@label="연봉 (세전, 퇴직금 제외)"
							@value={{this.annual}}
							@onChange={{this.setAnnual}}
						/>
						<MoneyField
							@label="월 비과세액"
							@value={{this.taxFree}}
							@hint="식대는 월 20만 원까지 비과세"
							@onChange={{this.setTaxFree}}
						/>
						<NumberField
							@label="부양가족 수 (본인 포함)"
							@value={{this.family}}
							@unit="명"
							@hint="본인과 배우자도 각각 1명"
							@onChange={{this.setFamily}}
						/>
						<NumberField
							@label="8세 이상 20세 이하 자녀 수"
							@value={{this.children}}
							@unit="명"
							@onChange={{this.setChildren}}
						/>
					</div>
				</CanonRows>
			</:sidebar>
			<:main>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="계산 결과 (월 기준)" />
					<KrwResult @lines={{this.lines}} />
				</CanonRows>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="연봉별 월 실수령액" />
					<div class="krw-table-wrap">
						<table class="krw-table">
							<thead>
								<tr><th>연봉</th><th>월 실수령액</th><th>월 공제액</th></tr>
							</thead>
							<tbody>
								{{#each this.table as |row|}}
									<tr>
										<td>{{row.annual}}</td>
										<td>{{row.net}}원</td>
										<td>{{row.deductions}}원</td>
									</tr>
								{{/each}}
							</tbody>
						</table>
					</div>
				</CanonRows>
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="실수령액 계산 방법" />
					<div class="krw-guide">
						<p>
							월 실수령액 = 월 급여 − 4대보험(근로자 부담) − 근로소득세 − 지방소득세
						</p>
						<ul>
							<li>월 급여는 연봉 ÷ 12로 계산합니다.</li>
							<li>
								4대보험과 소득세는 비과세 금액(식대 등)을 뺀 금액에 매깁니다. 4대보험 요율은
								{{RATES_AS_OF}} 기준입니다.
							</li>
							<li>
								근로소득세는 국세청 근로소득 간이세액표({{WAGE_TAX_AS_OF}} 시행)대로, 월급여와
								부양가족 수에 맞는 금액을 찾아 계산합니다. 8세 이상 20세 이하 자녀가 있으면
								자녀 수만큼 세액을 더 뺍니다.
							</li>
							<li>지방소득세는 근로소득세의 10%입니다.</li>
						</ul>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>급여명세서 금액과 다른 이유는요?</summary>
							<p>
								회사마다 비과세 항목, 상여금 지급 방식, 4대보험 신고 보수가 달라 차이가 날 수
								있습니다. 또 회사가 간이세액표의 80%나 120%로 원천징수하도록 선택한 경우에도
								달라집니다. 이 계산기는 100% 기준입니다.
							</p>
						</details>
						<details>
							<summary>연말정산을 하면 금액이 바뀌나요?</summary>
							<p>
								매달 떼는 소득세는 미리 내는 세금입니다. 연말정산에서 실제 공제(카드 사용액,
								보험료, 의료비 등)를 반영해 더 낸 세금은 돌려받고, 덜 낸 세금은 추가로
								냅니다.
							</p>
						</details>
						<details>
							<summary>부양가족 수는 어떻게 세나요?</summary>
							<p>
								본인을 포함해 기본공제 대상인 가족 수입니다. 배우자와 소득 요건을 갖춘
								자녀·부모 등이 들어가며, 본인과 배우자도 각각 1명으로 셉니다.
							</p>
						</details>
						<p class="krw-source">
							근거: 소득세법 시행령 별표2 근로소득 간이세액표({{WAGE_TAX_AS_OF}} 시행, 국세청 배포
							파일), 4대보험 요율은 4대보험 계산기와 같습니다. 참고용 추정치입니다.
						</p>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
