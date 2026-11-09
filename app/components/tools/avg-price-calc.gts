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
import { averagePrice } from 'delphitools-v2/lib/krw/invest';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import './krw/krw.css';

export default class AvgPriceCalc extends Component {
	@tracked price = 70000;
	@tracked quantity = 10;
	@tracked addPrice = 60000;
	@tracked addQuantity = 10;
	@tracked current = 0;

	get result() {
		return averagePrice([
			{ price: this.price, quantity: this.quantity },
			{ price: this.addPrice, quantity: this.addQuantity },
		]);
	}

	get lines() {
		const r = this.result;
		const lines: ResultLine[] = [
			{
				label: '새 평균단가',
				value: won(r.average),
				main: true,
				note:
					this.price > 0
						? `기존보다 ${(((r.average - this.price) / this.price) * 100).toFixed(2)}%`
						: undefined,
			},
			{
				label: '총 보유 수량',
				value: `${comma(r.quantity)}주`,
			},
			{ label: '총 매수 금액', value: won(r.cost) },
			{
				label: '추가 매수 금액',
				value: won(this.addPrice * this.addQuantity),
			},
		];
		if (this.current > 0 && r.quantity > 0) {
			const value = this.current * r.quantity;
			lines.push({
				label: '현재가 기준 손익',
				value: won(value - r.cost),
				note: `${(((value - r.cost) / r.cost) * 100).toFixed(2)}%`,
			});
		}
		return lines;
	}

	setPrice = (value: number) => (this.price = value);
	setQuantity = (value: number) => (this.quantity = value);
	setAddPrice = (value: number) => (this.addPrice = value);
	setAddQuantity = (value: number) => (this.addQuantity = value);
	setCurrent = (value: number) => (this.current = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="지금 가진 주식" />
					<div class="krw-form">
						<MoneyField
							@label="평균단가"
							@value={{this.price}}
							@hangul={{false}}
							@onChange={{this.setPrice}}
						/>
						<NumberField
							@label="보유 수량"
							@value={{this.quantity}}
							@unit="주"
							@onChange={{this.setQuantity}}
						/>
					</div>
				</CanonRows>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="추가 매수" />
					<div class="krw-form">
						<MoneyField
							@label="매수 가격"
							@value={{this.addPrice}}
							@hangul={{false}}
							@onChange={{this.setAddPrice}}
						/>
						<NumberField
							@label="매수 수량"
							@value={{this.addQuantity}}
							@unit="주"
							@onChange={{this.setAddQuantity}}
						/>
						<MoneyField
							@label="현재가 (선택)"
							@value={{this.current}}
							@hangul={{false}}
							@hint="넣으면 손익도 계산해요"
							@onChange={{this.setCurrent}}
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
						@text="평균단가 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							평균단가 = (기존
							평균단가 × 보유 수량 +
							추가 매수 가격 × 매수
							수량) ÷ 전체 수량. 7만
							원에 10주를 가진
							상태에서 6만 원에 10주를
							더 사면 (70만 원 + 60만
							원) ÷ 20주 =
							65,000원입니다.
						</p>
						<p>
							떨어진 가격에 더 사서
							평균단가를 낮추는 것을
							흔히 "물타기", 오른
							가격에 더 사는 것을
							"불타기"라고 부릅니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>증권사 앱
								평균단가와
								달라요.</summary>
							<p>
								증권사에 따라
								매수 수수료를
								평균단가에
								포함하기도
								합니다. 이
								계산기는
								수수료와 세금을
								빼고 계산합니다.
							</p>
						</details>
						<details>
							<summary>코인이나
								해외주식에도 쓸
								수 있나요?</summary>
							<p>
								네. 계산 방식은
								같습니다.
								해외주식은 같은
								통화(달러 등)로
								가격을 넣으면
								되고, 표시되는
								"원"은
								무시하세요.
								수량은 정수만
								입력할 수
								있습니다.
							</p>
						</details>
					</div>
				</CanonRows>
				<KrwRelated @current="avg-price-calc" />
			</:end>
		</CanonSplit>
	</template>
}
