import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
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
	STABILITY_RATES,
} from 'delphitools-v2/lib/krw/insurance';
import './krw/krw.css';

const sizeNames = STABILITY_RATES.map((size) => size.label);

export default class InsuranceCalc extends Component {
	@tracked pay = 3000000;
	@tracked taxFree = 200000;
	@tracked size = 0;

	get base() {
		return Math.max(0, this.pay - this.taxFree);
	}

	get result() {
		return insurance(this.base, STABILITY_RATES[this.size]!.rate);
	}

	get lines(): ResultLine[] {
		const r = this.result;
		return [
			{
				label: '근로자 부담 합계 (월)',
				value: won(r.total),
				main: true,
			},
			{
				label: '계산 기준 월 보수',
				value: won(this.base),
				note: this.taxFree
					? `월 급여 − 비과세 ${comma(this.taxFree)}원`
					: undefined,
			},
			{
				label: '국민연금 (4.75%)',
				value: won(r.pension),
				note:
					r.pensionBase === this.base
						? undefined
						: `기준소득월액 ${comma(r.pensionBase)}원으로 계산`,
			},
			{ label: '건강보험 (3.595%)', value: won(r.health) },
			{
				label: '장기요양보험',
				value: won(r.care),
				note: '건강보험료 × 0.9448% ÷ 7.19%',
			},
			{ label: '고용보험 (0.9%)', value: won(r.employment) },
			{
				label: '사업주 부담 (월)',
				value: won(r.employer),
				note: `고용안정 ${won(r.stability)} 포함, 산재보험 제외`,
			},
		];
	}

	setPay = (value: number) => (this.pay = value);
	setTaxFree = (value: number) => (this.taxFree = value);
	pickSize = (index: number) => (this.size = index);

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
							@hint="식대는 월 20만 원까지 비과세. 없으면 0"
							@onChange={{this.setTaxFree}}
						/>
						<div class="krw-choice">
							<span
								class="krw-field-label"
							>회사 규모 (사업주 부담
								계산용)</span>
							<CanonSegmented
								aria-label="회사 규모"
								@items={{sizeNames}}
								@selected={{this.size}}
								@columns={{2}}
								@onChange={{this.pickSize}}
							/>
						</div>
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
						@text="4대보험 요율 ({{RATES_AS_OF}} 기준)"
					/>
					<div class="krw-guide">
						<div class="krw-table-wrap">
							<table
								class="krw-table"
							>
								<thead>
									<tr><th
										>보험</th><th
										>전체
											요율</th><th
										>근로자</th><th
										>사업주</th></tr>
								</thead>
								<tbody>
									<tr><td
										>국민연금</td><td
										>9.5%</td><td
										>4.75%</td><td
										>4.75%</td></tr>
									<tr><td
										>건강보험</td><td
										>7.19%</td><td
										>3.595%</td><td
										>3.595%</td></tr>
									<tr><td
										>장기요양보험</td><td
										>건강보험료의
											13.14%</td><td
										>절반</td><td
										>절반</td></tr>
									<tr><td
										>고용보험
											(실업급여)</td><td
										>1.8%</td><td
										>0.9%</td><td
										>0.9%</td></tr>
									<tr><td
										>고용안정·직업능력개발</td><td
										>0.25~0.85%</td><td
										>없음</td><td
										>전액</td></tr>
									<tr><td
										>산재보험</td><td
										>업종별</td><td
										>없음</td><td
										>전액</td></tr>
								</tbody>
							</table>
						</div>
						<ul>
							<li>보험료는 비과세
								금액(식대 등)을
								뺀 월 보수로
								계산합니다.</li>
							<li>
								국민연금은
								기준소득월액
								{{comma
									PENSION_MIN
								}}원~{{comma
									PENSION_MAX
								}}원 범위에서
								계산합니다(2026년
								7월~2027년 6월).
								이보다 많이
								벌어도 상한액
								기준으로 냅니다.
							</li>
							<li>
								장기요양보험료는
								건강보험료 ×
								(0.9448% ÷
								7.19%)로
								계산합니다.
								건강보험료
								근로자 부담은 월
								최고
								4,591,740원,
								최저
								10,080원입니다.
							</li>
							<li>
								각 보험료의 10원
								미만은 버립니다.
								공식 예시(보수
								200만 원 →
								건강보험
								71,900원,
								장기요양
								9,440원)와 같은
								결과가 나옵니다.
							</li>
						</ul>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>다른 계산기와
								금액이 조금
								달라요. 어느
								쪽이 맞나요?</summary>
							<p>
								주로 세 가지
								때문입니다. ①
								비과세 금액: 이
								계산기는 식대
								20만 원을 빼고
								계산합니다.
								비과세가 없다면
								0으로 바꾸세요.
								② 요율 기준
								시점: 2025년
								요율(국민연금
								9%, 건강보험
								7.09%)이나 이전
								국민연금
								상한(637만 원)을
								그대로 쓰는
								계산기가
								있습니다. ③ 끝수
								처리: 원 단위로
								버리는지, 10원
								단위로
								버리는지에 따라
								몇 원~몇십 원
								차이가 납니다.
								이 계산기는
								4대사회보험
								정보연계센터의
								2026년 공식
								모의계산 기준을
								따릅니다.
							</p>
						</details>
						<details>
							<summary>급여명세서
								금액과 조금
								달라요.</summary>
							<p>
								국민연금·건강보험은
								실제 이번 달
								급여가 아니라
								공단에 신고한
								보수(전년도 소득
								기준 등)로
								매기기 때문에
								차이가 날 수
								있습니다.
								연말·연초
								정산으로 차액이
								조정되기도
								합니다.
							</p>
						</details>
						<details>
							<summary>사업주는 얼마를
								더 내나요?</summary>
							<p>
								근로자와 같은
								금액에
								고용안정·직업능력개발
								보험료(150인
								미만 0.25%)와
								업종별
								산재보험료를 더
								냅니다. 이
								계산기의 사업주
								부담에는
								산재보험이 빠져
								있습니다.
							</p>
						</details>
						<details>
							<summary>요율은 언제
								바뀌나요?</summary>
							<p>
								보통 1월에
								건강보험·장기요양·국민연금
								요율이, 7월에
								국민연금
								상·하한액이
								바뀝니다.
								국민연금 요율은
								2026년부터 매년
								0.5%포인트씩
								올라 13%까지
								오를 예정입니다.
							</p>
						</details>
						<p class="krw-source">
							근거: 4대사회보험
							정보연계센터 보험료
							모의계산(4insure.or.kr),
							보건복지부 2026년
							건강보험료율·장기요양보험료율
							발표, 국민연금공단
							연금보험료 안내.
							참고용이며 실제 고지액은
							각 공단에서 확인하세요.
						</p>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
