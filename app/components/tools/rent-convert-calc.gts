import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult from 'delphitools-v2/components/tools/krw/result';
import { won } from 'delphitools-v2/lib/krw/money';
import {
	BASE_RATE,
	BASE_RATE_DATE,
	depositToRent,
	legalCap,
	rentToDeposit,
} from 'delphitools-v2/lib/krw/rent-convert';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import './krw/krw.css';

const modes = ['보증금 → 월세', '월세 → 보증금'];
const cap = legalCap();

export default class RentConvertCalc extends Component {
	@tracked mode = 0;
	@tracked amount = 100000000;
	@tracked rate = cap;

	get amountLabel() {
		return this.mode === 0
			? '월세로 돌릴 보증금'
			: '보증금으로 돌릴 월세';
	}

	get lines() {
		const over = this.rate > cap;
		const note = over
			? `법정 상한 ${cap}%를 넘어요. 넘는 부분은 무효예요`
			: undefined;
		return this.mode === 0
			? [
					{
						label: '늘어나는 월세',
						value: won(
							depositToRent(
								this.amount,
								this.rate,
							),
						),
						main: true,
						note,
					},
					{
						label: '법정 상한으로 계산하면',
						value: won(
							depositToRent(
								this.amount,
								cap,
							),
						),
					},
				]
			: [
					{
						label: '늘어나는 보증금',
						value: won(
							rentToDeposit(
								this.amount,
								this.rate,
							),
						),
						main: true,
						note,
					},
				];
	}

	pick = (index: number) => {
		this.mode = index;
		this.amount = index === 0 ? 100000000 : 500000;
	};
	setAmount = (value: number) => (this.amount = value);
	setRate = (value: number) => (this.rate = Math.min(value, 100));

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="전환 조건" />
					<div class="krw-form">
						<CanonSegmented
							aria-label="전환 방향"
							@items={{modes}}
							@selected={{this.mode}}
							@onChange={{this.pick}}
						/>
						<MoneyField
							@label={{this.amountLabel}}
							@value={{this.amount}}
							@onChange={{this.setAmount}}
						/>
						<NumberField
							@label="전월세 전환율"
							@value={{this.rate}}
							@unit="%"
							@decimal={{true}}
							@hint="법정 상한 {{cap}}% (기준금리 {{BASE_RATE}}% + 2%)"
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
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading
						@text="전월세 전환 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							월세 = 전환할 보증금 ×
							전환율 ÷ 12. 보증금 1억
							원을 전환율 5%로 월세로
							돌리면 1억 원 × 5% ÷ 12
							= 월 416,667원입니다.
							반대로 월세를 보증금으로
							돌릴 때는 월세 × 12 ÷
							전환율입니다.
						</p>
						<h3>법정 전환율 상한</h3>
						<p>
							살고 있는 집의 계약 기간
							중이나 계약을 갱신하면서
							보증금을 월세로 돌릴 때,
							집주인은 "연 10%"와
							"한국은행 기준금리 + 연
							2%" 중 낮은 비율을 넘겨
							월세를 받을 수 없습니다.
							기준금리가 연
							{{BASE_RATE}}%({{BASE_RATE_DATE}}
							기준)이므로 상한은 연
							{{cap}}%입니다. 상한을
							넘는 월세는 무효이고,
							이미 냈다면 돌려받을 수
							있습니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>새로 계약할
								때도 상한이
								적용되나요?</summary>
							<p>
								아니요. 상한은
								기존 계약
								중이거나 갱신할
								때 보증금을
								월세로 돌리는
								경우에
								적용됩니다. 새
								집과 처음 계약할
								때는 집주인과
								자유롭게
								정합니다.
							</p>
						</details>
						<details>
							<summary>월세를
								보증금으로 돌릴
								때도 상한이
								있나요?</summary>
							<p>
								법정 상한은
								보증금을 월세로
								돌릴 때 세입자를
								보호하려는
								규정입니다.
								월세를
								보증금으로 돌릴
								때는 정해진
								비율이 없어
								집주인과 합의해
								정합니다.
							</p>
						</details>
						<details>
							<summary>지역 평균
								전환율은 어디서
								보나요?</summary>
							<p>
								한국부동산원
								부동산통계정보(R-ONE)에서
								지역별 전월세
								전환율을 매달
								발표합니다.
							</p>
						</details>
						<p class="krw-source">
							근거: 주택임대차보호법
							제7조의2, 같은 법 시행령
							제9조
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="rent-convert-calc" />
			</:end>
		</CanonSplit>
	</template>
}
