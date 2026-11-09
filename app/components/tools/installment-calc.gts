import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult from 'delphitools-v2/components/tools/krw/result';
import { comma, won } from 'delphitools-v2/lib/krw/money';
import { installment } from 'delphitools-v2/lib/krw/installment';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import './krw/krw.css';

export default class InstallmentCalc extends Component {
	@tracked amount = 1200000;
	@tracked rate = 15;
	@tracked months = 6;

	get result() {
		return installment(
			this.amount,
			this.rate,
			Math.min(this.months, 60),
		);
	}

	get lines() {
		const r = this.result;
		const first = r.rows[0];
		return [
			{
				label: '첫 달 결제금액',
				value: won(first?.payment ?? 0),
				main: true,
				note: '수수료가 줄어 매달 조금씩 적어져요',
			},
			{ label: '총 할부 수수료', value: won(r.totalFee) },
			{ label: '총 결제금액', value: won(r.totalPayment) },
		];
	}

	get rows() {
		return this.result.rows.map((row) => ({
			month: row.month,
			principal: comma(row.principal),
			fee: comma(row.fee),
			payment: comma(row.payment),
			balance: comma(row.balance),
		}));
	}

	setAmount = (value: number) => (this.amount = value);
	setRate = (value: number) => (this.rate = Math.min(value, 30));
	setMonths = (value: number) => (this.months = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="할부 조건" />
					<div class="krw-form">
						<MoneyField
							@label="결제 금액"
							@value={{this.amount}}
							@onChange={{this.setAmount}}
						/>
						<NumberField
							@label="할부 개월"
							@value={{this.months}}
							@unit="개월"
							@onChange={{this.setMonths}}
						/>
						<NumberField
							@label="연 할부 수수료율"
							@value={{this.rate}}
							@unit="%"
							@decimal={{true}}
							@hint="카드사 앱·홈페이지에서 확인"
							@onChange={{this.setRate}}
						/>
					</div>
				</CanonRows>
			</:sidebar>
			<:main>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="계산 결과" />
					<KrwResult @lines={{this.lines}} />
				</CanonRows>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="회차별 결제금액" />
					<div class="krw-table-wrap">
						<table class="krw-table">
							<thead>
								<tr>
									<th
									>회차</th>
									<th
									>원금</th>
									<th
									>수수료</th>
									<th
									>결제금액</th>
									<th>남은
										원금</th>
								</tr>
							</thead>
							<tbody>
								{{#each
									this.rows
									key="month"
									as |row|
								}}
									<tr>
										<td
										>{{row.month}}</td>
										<td
										>{{row.principal}}</td>
										<td
										>{{row.fee}}</td>
										<td
										>{{row.payment}}</td>
										<td
										>{{row.balance}}</td>
									</tr>
								{{/each}}
							</tbody>
						</table>
					</div>
				</CanonRows>
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading
						@text="카드 할부 수수료 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							카드 할부는 결제 금액을
							개월 수로 똑같이 나눠
							갚고, 수수료는 아직 갚지
							않은 할부 잔액에
							붙습니다. 회차 수수료 =
							남은 할부 잔액 × 연
							수수료율 ÷ 12. 그래서 첫
							달 수수료가 가장 크고
							갈수록 줄어듭니다.
						</p>
						<p>
							120만 원을 연 12%로
							3개월 할부하면 수수료는
							1회차 12,000원, 2회차
							8,000원, 3회차
							4,000원으로 모두
							24,000원입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>카드사 청구서와
								금액이 조금
								달라요.</summary>
							<p>
								카드사는
								결제일부터
								청구일까지 실제
								일수(÷365)로
								수수료를
								계산하는 경우가
								많아, 이
								계산기와 몇십 원
								차이가 날 수
								있습니다.
							</p>
						</details>
						<details>
							<summary>무이자 할부는
								어떻게
								계산하나요?</summary>
							<p>
								수수료율에 0을
								넣으면 됩니다.
								일부 개월만
								무이자인 "부분
								무이자"는
								카드사마다
								방식이 달라
								카드사 안내를
								확인하세요.
							</p>
						</details>
						<details>
							<summary>할부 수수료율은
								어디서 보나요?</summary>
							<p>
								카드사 앱의 이용
								내역 또는
								홈페이지의
								수수료율 안내에
								있습니다. 같은
								카드사라도 회원
								등급과 할부
								개월에 따라
								다릅니다.
								여신금융협회
								홈페이지에서
								카드사별
								수수료율을
								비교할 수
								있습니다.
							</p>
						</details>
					</div>
				</CanonRows>
				<KrwRelated @current="installment-calc" />
			</:end>
		</CanonSplit>
	</template>
}
