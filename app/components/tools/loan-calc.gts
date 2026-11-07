import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult from 'delphitools-v2/components/tools/krw/result';
import { comma, won } from 'delphitools-v2/lib/krw/money';
import { loanSchedule, type LoanMethod } from 'delphitools-v2/lib/krw/loan';
import './krw/krw.css';

const methods: LoanMethod[] = ['equal-payment', 'equal-principal', 'bullet'];
const methodNames = ['원리금균등', '원금균등', '만기일시'];

export default class LoanCalc extends Component {
	@tracked amount = 100000000;
	@tracked rate = 4.5;
	@tracked years = 30;
	@tracked method = 0;

	get months() {
		return Math.min(Math.round(this.years * 12), 600);
	}

	get result() {
		return loanSchedule(
			this.amount,
			this.rate,
			this.months,
			methods[this.method]!,
		);
	}

	get lines() {
		const r = this.result;
		const first =
			this.method === 0
				? { label: '매달 상환금', value: won(r.firstPayment), main: true }
				: this.method === 1
					? {
							label: '첫 달 상환금',
							value: won(r.firstPayment),
							main: true,
							note: '매달 조금씩 줄어요',
						}
					: {
							label: '매달 이자',
							value: won(r.firstPayment),
							main: true,
							note: '마지막 달에 원금을 한꺼번에 갚아요',
						};
		return [
			first,
			{ label: '총 이자', value: won(r.totalInterest) },
			{ label: '총 상환금액', value: won(r.totalPayment) },
			{ label: '상환 기간', value: `${this.months}개월` },
		];
	}

	get rows() {
		return this.result.rows.map((row) => ({
			month: row.month,
			payment: comma(row.payment),
			principal: comma(row.principal),
			interest: comma(row.interest),
			balance: comma(row.balance),
		}));
	}

	setAmount = (value: number) => (this.amount = value);
	setRate = (value: number) => (this.rate = Math.min(value, 100));
	setYears = (value: number) => (this.years = value);
	pick = (index: number) => (this.method = index);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="대출 조건" />
					<div class="krw-form">
						<MoneyField
							@label="대출금액"
							@value={{this.amount}}
							@onChange={{this.setAmount}}
						/>
						<NumberField
							@label="연 이자율"
							@value={{this.rate}}
							@unit="%"
							@decimal={{true}}
							@onChange={{this.setRate}}
						/>
						<NumberField
							@label="대출 기간"
							@value={{this.years}}
							@unit="년"
							@decimal={{true}}
							@hint="최대 50년"
							@onChange={{this.setYears}}
						/>
						<div class="krw-choice">
							<span class="krw-field-label">상환 방식</span>
							<CanonSegmented
								aria-label="상환 방식"
								@items={{methodNames}}
								@selected={{this.method}}
								@onChange={{this.pick}}
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
				<CanonRows @framed={{true}}>
					<CanonHeading @text="월별 상환표" />
					<div class="krw-table-wrap">
						<table class="krw-table">
							<thead>
								<tr>
									<th>회차</th>
									<th>상환금</th>
									<th>원금</th>
									<th>이자</th>
									<th>남은 원금</th>
								</tr>
							</thead>
							<tbody>
								{{#each this.rows key="month" as |row|}}
									<tr>
										<td>{{row.month}}</td>
										<td>{{row.payment}}</td>
										<td>{{row.principal}}</td>
										<td>{{row.interest}}</td>
										<td>{{row.balance}}</td>
									</tr>
								{{/each}}
							</tbody>
						</table>
					</div>
				</CanonRows>
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="상환 방식별 계산 방법" />
					<div class="krw-guide">
						<h3>원리금균등 상환</h3>
						<p>
							원금과 이자를 합친 금액을 매달 똑같이 갚습니다. 초반에는 이자 비중이
							크고 갈수록 원금 비중이 커집니다. 매달 상환금 = 대출금 × 월이율 ×
							(1+월이율)<sup>개월수</sup> ÷ ((1+월이율)<sup>개월수</sup> − 1)
						</p>
						<h3>원금균등 상환</h3>
						<p>
							원금을 개월 수로 똑같이 나눠 갚고, 이자는 남은 원금에만 붙습니다. 첫
							달 부담이 가장 크지만 총 이자는 원리금균등보다 적습니다.
						</p>
						<h3>만기일시 상환</h3>
						<p>
							기간 동안 이자만 내고 원금은 마지막 달에 한꺼번에 갚습니다. 매달 부담은
							가장 작지만 총 이자는 가장 많습니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>은행 상환 스케줄과 몇 원 차이가 나요.</summary>
							<p>
								이 계산기는 월이율(연이율 ÷ 12)로 매달 이자를 계산하고 원 미만을
								반올림합니다. 은행은 실제 일수(일할 계산)나 다른 끝수 처리를 쓰는
								경우가 있어 몇 원~몇십 원 차이가 날 수 있습니다.
							</p>
						</details>
						<details>
							<summary>중도상환수수료나 거치기간도 반영되나요?</summary>
							<p>
								아니요. 이 계산기는 고정금리에 거치기간 없이 상환하는 경우만 계산합니다.
								변동금리, 거치기간, 중도상환수수료는 대출 상품 안내를 확인하세요.
							</p>
						</details>
						<details>
							<summary>어떤 상환 방식이 유리한가요?</summary>
							<p>
								총 이자는 원금균등이 가장 적고, 만기일시가 가장 많습니다. 다만 매달
								부담할 수 있는 금액에 따라 맞는 방식이 다르니, 위 표로 비교해 보세요.
							</p>
						</details>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
