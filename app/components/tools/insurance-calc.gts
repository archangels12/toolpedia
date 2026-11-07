import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import { comma, won } from 'delphitools-v2/lib/krw/money';
import {
	insurance,
	PENSION_MAX,
	PENSION_MIN,
	RATES_AS_OF,
} from 'delphitools-v2/lib/krw/insurance';
import './krw/krw.css';

export default class InsuranceCalc extends Component {
	@tracked pay = 3000000;
	@tracked taxFree = 200000;

	get base() {
		return Math.max(0, this.pay - this.taxFree);
	}

	get result() {
		return insurance(this.base);
	}

	get lines(): ResultLine[] {
		const r = this.result;
		return [
			{ label: '근로자 부담 합계 (월)', value: won(r.total), main: true },
			{
				label: '국민연금 (4.75%)',
				value: won(r.pension),
				note:
					r.pensionBase === this.base
						? undefined
						: `기준소득월액 ${comma(r.pensionBase)}원으로 계산`,
			},
			{ label: '건강보험 (3.595%)', value: won(r.health) },
			{ label: '장기요양보험 (건강보험료 × 13.14%)', value: won(r.care) },
			{ label: '고용보험 (0.9%)', value: won(r.employment) },
			{
				label: '사업주 부담 (월)',
				value: won(r.employer),
				note: '150인 미만 기준, 산재보험 제외',
			},
		];
	}

	setPay = (value: number) => (this.pay = value);
	setTaxFree = (value: number) => (this.taxFree = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="월 급여" />
					<div class="krw-form">
						<MoneyField
							@label="월 급여 (세전)"
							@value={{this.pay}}
							@onChange={{this.setPay}}
						/>
						<MoneyField
							@label="비과세 금액"
							@value={{this.taxFree}}
							@hint="식대는 월 20만 원까지 비과세"
							@onChange={{this.setTaxFree}}
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
					<CanonHeading @text="4대보험 요율 ({{RATES_AS_OF}} 기준)" />
					<div class="krw-guide">
						<div class="krw-table-wrap">
							<table class="krw-table">
								<thead>
									<tr><th>보험</th><th>전체 요율</th><th>근로자</th><th>사업주</th></tr>
								</thead>
								<tbody>
									<tr><td>국민연금</td><td>9.5%</td><td>4.75%</td><td>4.75%</td></tr>
									<tr><td>건강보험</td><td>7.19%</td><td>3.595%</td><td>3.595%</td></tr>
									<tr><td>장기요양보험</td><td>건강보험료의 13.14%</td><td>절반</td><td>절반</td></tr>
									<tr><td>고용보험 (실업급여)</td><td>1.8%</td><td>0.9%</td><td>0.9%</td></tr>
									<tr><td>고용안정·직업능력개발</td><td>0.25~0.85%</td><td>없음</td><td>전액</td></tr>
									<tr><td>산재보험</td><td>업종별</td><td>없음</td><td>전액</td></tr>
								</tbody>
							</table>
						</div>
						<ul>
							<li>보험료는 비과세 금액(식대 등)을 뺀 월 보수로 계산합니다.</li>
							<li>
								국민연금은 기준소득월액 {{comma PENSION_MIN}}원~{{comma PENSION_MAX}}원
								범위에서 계산합니다(2026년 7월~2027년 6월). 이보다 많이 벌어도 상한액
								기준으로 냅니다.
							</li>
							<li>각 보험료의 10원 미만은 버립니다.</li>
						</ul>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>급여명세서 금액과 조금 달라요.</summary>
							<p>
								국민연금·건강보험은 실제 이번 달 급여가 아니라 공단에 신고한 보수(전년도
								소득 기준 등)로 매기기 때문에 차이가 날 수 있습니다. 연말·연초 정산으로
								차액이 조정되기도 합니다.
							</p>
						</details>
						<details>
							<summary>사업주는 얼마를 더 내나요?</summary>
							<p>
								근로자와 같은 금액에 고용안정·직업능력개발 보험료(150인 미만 0.25%)와
								업종별 산재보험료를 더 냅니다. 이 계산기의 사업주 부담에는 산재보험이
								빠져 있습니다.
							</p>
						</details>
						<details>
							<summary>요율은 언제 바뀌나요?</summary>
							<p>
								보통 1월에 건강보험·장기요양·국민연금 요율이, 7월에 국민연금 상·하한액이
								바뀝니다. 국민연금 요율은 2026년부터 매년 0.5%포인트씩 올라 13%까지
								오를 예정입니다.
							</p>
						</details>
						<p class="krw-source">
							근거: 보건복지부·국민연금공단(국민연금 요율·기준소득월액), 국민건강보험공단(건강·장기요양
							요율), 고용노동부(고용보험 요율). 참고용이며 실제 고지액은 각 공단에서
							확인하세요.
						</p>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
