import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult from 'delphitools-v2/components/tools/krw/result';
import { won } from 'delphitools-v2/lib/krw/money';
import { investReturn } from 'delphitools-v2/lib/krw/invest';
import './krw/krw.css';

const percent = (value: number) => `${value.toFixed(2)}%`;

export default class ReturnCalc extends Component {
	@tracked cost = 10000000;
	@tracked value = 15000000;
	@tracked years = 3;

	get lines() {
		const r = investReturn(this.cost, this.value, this.years);
		return [
			{
				label: '총 수익률',
				value: percent(r.ratePercent),
				main: true,
			},
			{ label: '수익금', value: won(r.gain) },
			{
				label: '연평균 수익률 (CAGR)',
				value:
					this.years > 0
						? percent(r.cagrPercent)
						: '-',
				note: '매년 같은 비율로 불었다고 볼 때의 연 수익률',
			},
		];
	}

	setCost = (value: number) => (this.cost = value);
	setValue = (value: number) => (this.value = value);
	setYears = (value: number) => (this.years = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="투자 내역" />
					<div class="krw-form">
						<MoneyField
							@label="투자 원금"
							@value={{this.cost}}
							@onChange={{this.setCost}}
						/>
						<MoneyField
							@label="현재 평가금액"
							@value={{this.value}}
							@onChange={{this.setValue}}
						/>
						<NumberField
							@label="보유 기간"
							@value={{this.years}}
							@unit="년"
							@decimal={{true}}
							@hint="6개월이면 0.5"
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
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading
						@text="수익률 계산 방법"
					/>
					<div class="krw-guide">
						<h3>총 수익률</h3>
						<p>
							총 수익률 = (평가금액 −
							원금) ÷ 원금 × 100.
							1,000만 원이 1,500만
							원이 되면 수익률은
							50%입니다.
						</p>
						<h3>연평균 수익률 (CAGR)</h3>
						<p>
							CAGR = (평가금액 ÷ 원금)<sup
							>1 ÷ 보유 연수</sup>
							− 1. 3년 동안 50%가
							올랐다면 1년에 16.7%가
							아니라, 매년 약 14.47%씩
							복리로 불어난 것과
							같습니다. 기간이 다른
							투자를 비교할 때 씁니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>중간에 돈을 더
								넣었으면 어떻게
								하나요?</summary>
							<p>
								이 계산기는
								처음에 한 번
								넣은 돈만
								계산합니다.
								중간에 돈을 더
								넣었다면 투자
								원금에 넣은 돈을
								모두 더하면 총
								수익률은 맞지만,
								연평균 수익률은
								실제와 다를 수
								있습니다.
							</p>
						</details>
						<details>
							<summary>세금과 수수료가
								반영되나요?</summary>
							<p>
								아니요.
								평가금액에
								세금·수수료를 뺀
								금액을 넣으면
								세후 수익률이
								됩니다.
							</p>
						</details>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
