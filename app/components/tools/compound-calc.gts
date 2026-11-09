import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult from 'delphitools-v2/components/tools/krw/result';
import { comma, won } from 'delphitools-v2/lib/krw/money';
import { compound } from 'delphitools-v2/lib/krw/compound';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import './krw/krw.css';

export default class CompoundCalc extends Component {
	@tracked initial = 10000000;
	@tracked monthly = 500000;
	@tracked rate = 7;
	@tracked years = 10;

	get result() {
		return compound(
			this.initial,
			this.monthly,
			this.rate,
			Math.min(this.years, 60),
		);
	}

	get lines() {
		const r = this.result;
		return [
			{ label: '최종 금액', value: won(r.value), main: true },
			{ label: '넣은 돈 합계', value: won(r.paid) },
			{ label: '수익', value: won(r.gain) },
		];
	}

	get rows() {
		return this.result.years.map((row) => ({
			year: row.year,
			paid: comma(row.paid),
			value: comma(row.value),
			gain: comma(row.value - row.paid),
		}));
	}

	setInitial = (value: number) => (this.initial = value);
	setMonthly = (value: number) => (this.monthly = value);
	setRate = (value: number) => (this.rate = Math.min(value, 100));
	setYears = (value: number) => (this.years = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="투자 조건" />
					<div class="krw-form">
						<MoneyField
							@label="처음 넣는 돈"
							@value={{this.initial}}
							@onChange={{this.setInitial}}
						/>
						<MoneyField
							@label="매달 넣는 돈"
							@value={{this.monthly}}
							@onChange={{this.setMonthly}}
						/>
						<NumberField
							@label="연 수익률"
							@value={{this.rate}}
							@unit="%"
							@decimal={{true}}
							@onChange={{this.setRate}}
						/>
						<NumberField
							@label="기간"
							@value={{this.years}}
							@unit="년"
							@hint="최대 60년"
							@onChange={{this.setYears}}
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
					<CanonHeading @text="연도별 금액" />
					<div class="krw-table-wrap">
						<table class="krw-table">
							<thead>
								<tr>
									<th
									>연차</th>
									<th>넣은
										돈</th>
									<th
									>평가금액</th>
									<th
									>수익</th>
								</tr>
							</thead>
							<tbody>
								{{#each
									this.rows
									key="year"
									as |row|
								}}
									<tr>
										<td
										>{{row.year}}년</td>
										<td
										>{{row.paid}}</td>
										<td
										>{{row.value}}</td>
										<td
										>{{row.gain}}</td>
									</tr>
								{{/each}}
							</tbody>
						</table>
					</div>
				</CanonRows>
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="복리 계산 방법" />
					<div class="krw-guide">
						<p>
							복리는 원금뿐 아니라
							그동안 붙은 수익에도
							다시 수익이 붙는
							방식입니다. 1,000만 원을
							연 7%로 10년 두면
							1,000만 원 × 1.07<sup
							>10</sup>
							= 약 1,967만 원이
							됩니다. 단리였다면
							1,700만 원이므로, 기간이
							길수록 차이가 커집니다.
						</p>
						<p>
							이 계산기는 매달 넣는
							돈을 월초에 넣고, 연
							수익률을 월 수익률로
							바꿔(1년 뒤 정확히 연
							수익률이 되도록) 매달
							불려 계산합니다.
						</p>
						<h3>72의 법칙</h3>
						<p>
							72를 연 수익률로 나누면
							돈이 두 배가 되는 데
							걸리는 햇수를 대략 알 수
							있습니다. 연 6%면 약
							12년, 연 8%면 약
							9년입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>세금과 수수료도
								반영되나요?</summary>
							<p>
								아니요.
								세전·수수료 전
								금액입니다. 예금
								이자에는 15.4%,
								펀드·ETF는
								상품에 따라 다른
								세금이 붙고,
								운용 보수도
								빠집니다.
							</p>
						</details>
						<details>
							<summary>연 수익률은
								얼마로 넣어야
								하나요?</summary>
							<p>
								미래 수익률은
								아무도 알 수
								없습니다. 예금은
								현재 금리를,
								주식·ETF는
								보수적으로 낮은
								값부터 여러
								경우를 넣어
								비교해 보세요.
								과거 수익률이
								미래 수익을
								보장하지
								않습니다.
							</p>
						</details>
					</div>
				</CanonRows>
				<KrwRelated @current="compound-calc" />
			</:end>
		</CanonSplit>
	</template>
}
