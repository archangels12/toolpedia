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
	savings,
	type InterestKind,
	type SavingsKind,
	type TaxKind,
} from 'delphitools-v2/lib/krw/savings';
import './krw/krw.css';

const kinds: SavingsKind[] = ['deposit', 'installment'];
const kindNames = ['예금 (한 번에)', '적금 (매달)'];
const interestKinds: InterestKind[] = ['simple', 'compound'];
const interestNames = ['단리', '월복리'];
const taxKinds: TaxKind[] = ['normal', 'free', 'mutual'];
const taxNames = ['15.4%', '비과세', '1.4%'];

export default class SavingsCalc extends Component {
	@tracked kind = 0;
	@tracked amount = 10000000;
	@tracked rate = 3;
	@tracked months = 12;
	@tracked interest = 0;
	@tracked tax = 0;

	get result() {
		return savings(
			kinds[this.kind]!,
			this.amount,
			this.rate,
			Math.min(this.months, 600),
			interestKinds[this.interest]!,
			taxKinds[this.tax]!,
		);
	}

	get amountLabel() {
		return this.kind === 0 ? '예금액' : '월 납입액';
	}

	get lines() {
		const r = this.result;
		return [
			{
				label: '세후 만기 수령액',
				value: won(r.total),
				main: true,
			},
			{ label: '원금 합계', value: won(r.principal) },
			{ label: '세전 이자', value: won(r.interest) },
			{ label: '이자 과세', value: `−${won(r.tax)}` },
			{ label: '세후 이자', value: won(r.afterTaxInterest) },
		];
	}

	pickKind = (index: number) => (this.kind = index);
	pickInterest = (index: number) => (this.interest = index);
	pickTax = (index: number) => (this.tax = index);
	setAmount = (value: number) => (this.amount = value);
	setRate = (value: number) => (this.rate = Math.min(value, 100));
	setMonths = (value: number) => (this.months = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="저축 조건" />
					<div class="krw-form">
						<CanonSegmented
							aria-label="저축 종류"
							@items={{kindNames}}
							@selected={{this.kind}}
							@onChange={{this.pickKind}}
						/>
						<MoneyField
							@label={{this.amountLabel}}
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
							@label="기간"
							@value={{this.months}}
							@unit="개월"
							@onChange={{this.setMonths}}
						/>
						<div class="krw-choice">
							<span
								class="krw-field-label"
							>이자 방식</span>
							<CanonSegmented
								aria-label="이자 방식"
								@items={{interestNames}}
								@selected={{this.interest}}
								@onChange={{this.pickInterest}}
							/>
						</div>
						<div class="krw-choice">
							<span
								class="krw-field-label"
							>과세 방식</span>
							<CanonSegmented
								aria-label="과세 방식"
								@items={{taxNames}}
								@selected={{this.tax}}
								@onChange={{this.pickTax}}
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
						@text="예금·적금 이자 계산 방법"
					/>
					<div class="krw-guide">
						<h3>예금 이자</h3>
						<p>
							단리 이자 = 예금액 × 연
							이자율 × 개월 수 ÷ 12.
							예를 들어 1,000만 원을
							연 3%로 1년 맡기면 세전
							이자는 30만 원, 세금
							46,200원을 떼고
							253,800원을 받습니다.
						</p>
						<h3>적금 이자</h3>
						<p>
							적금은 첫 달에 넣은 돈만
							기간 내내 이자가 붙고,
							마지막 달에 넣은 돈은 한
							달 치 이자만 붙습니다.
							그래서 같은 연
							이자율이라도 적금 이자는
							예금의 절반 정도입니다.
							단리 이자 = 월 납입액 ×
							연 이자율 ÷ 12 × 개월 수
							× (개월 수 + 1) ÷ 2.
						</p>
						<h3>이자에 붙는 세금</h3>
						<ul>
							<li>
								일반과세 15.4%:
								이자소득세 14%와
								지방소득세 1.4%.
								대부분의 은행
								예적금이 여기에
								해당합니다.
							</li>
							<li>
								비과세:
								비과세종합저축(만
								65세 이상·장애인
								등, 1인 5,000만
								원 한도) 같은
								상품은 세금이
								없습니다.
							</li>
							<li>
								저율과세 1.4%:
								농협·수협·신협·새마을금고
								등 조합
								예탁금(1인
								3,000만 원
								한도)은
								농어촌특별세
								1.4%만 냅니다.
								조합원 자격과
								소득 기준에 따라
								세율이 달라질 수
								있으니 가입하는
								조합에
								확인하세요.
							</li>
						</ul>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>은행 앱 금액과
								조금 달라요.</summary>
							<p>
								이 계산기는 월
								단위로 이자를
								계산합니다.
								은행은 실제 예치
								일수(÷365)로
								계산하거나 원
								미만 처리 방식이
								달라 몇 원~몇백
								원 차이가 날 수
								있습니다.
							</p>
						</details>
						<details>
							<summary>단리와 월복리
								중 무엇을
								고르나요?</summary>
							<p>
								상품 설명서에
								"복리"라고 적혀
								있지 않으면
								단리입니다.
								대부분의
								정기예금·정기적금은
								단리이고, 일부
								저축은행 상품이
								월복리를
								제공합니다.
							</p>
						</details>
						<details>
							<summary>중도에 해지하면
								어떻게 되나요?</summary>
							<p>
								만기 전에
								해지하면 약정
								이자율보다 훨씬
								낮은 중도해지
								이율이
								적용됩니다.
								중도해지 이율은
								상품마다 다르니
								가입한 은행에서
								확인하세요.
							</p>
						</details>
						<p class="krw-source">
							근거: 소득세법
							제129조(이자소득
							원천징수 세율 14%),
							지방세법(지방소득세 =
							소득세의 10%),
							조세특례제한법
							제88조의2·제89조의3
						</p>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
