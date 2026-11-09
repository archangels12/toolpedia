import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import KrwResult from 'delphitools-v2/components/tools/krw/result';
import { won } from 'delphitools-v2/lib/krw/money';
import { freelanceTax, grossFromNet } from 'delphitools-v2/lib/krw/freelance';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import './krw/krw.css';

const modes = ['세전 금액으로', '실수령액으로'];

export default class FreelanceTaxCalc extends Component {
	@tracked mode = 0;
	@tracked amount = 1000000;

	get label() {
		return this.mode === 0 ? '세전 지급액' : '받고 싶은 실수령액';
	}

	get lines() {
		const r =
			this.mode === 0
				? freelanceTax(this.amount)
				: grossFromNet(this.amount);
		return [
			this.mode === 0
				? {
						label: '실수령액',
						value: won(r.net),
						main: true,
					}
				: {
						label: '세전 지급액',
						value: won(r.gross),
						main: true,
						note: '이 금액으로 계약하면 돼요',
					},
			this.mode === 0
				? { label: '세전 지급액', value: won(r.gross) }
				: { label: '실수령액', value: won(r.net) },
			{ label: '소득세 (3%)', value: `−${won(r.incomeTax)}` },
			{
				label: '지방소득세 (0.3%)',
				value: `−${won(r.localTax)}`,
			},
		];
	}

	pick = (index: number) => (this.mode = index);
	set = (value: number) => (this.amount = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="입력" />
					<div class="krw-form">
						<CanonSegmented
							aria-label="계산 방식"
							@items={{modes}}
							@selected={{this.mode}}
							@onChange={{this.pick}}
						/>
						<MoneyField
							@label={{this.label}}
							@value={{this.amount}}
							@onChange={{this.set}}
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
						@text="3.3% 원천징수 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							프리랜서·강사·크리에이터처럼
							고용되지 않고 일한
							대가(사업소득)를 받을
							때, 주는 쪽이 소득세
							3%와 지방소득세
							0.3%(소득세의 10%)를
							미리 떼고 지급합니다.
							100만 원이면 소득세
							30,000원과 지방소득세
							3,000원을 떼고
							967,000원을 받습니다.
						</p>
						<p>
							각 세금은 10원 미만을
							버립니다. 소득세가
							1,000원 미만(지급액 약
							33,333원 이하)이면
							세금을 떼지
							않습니다(소액부징수).
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>뗀 3.3%는
								돌려받을 수
								있나요?</summary>
							<p>
								다음 해 5월
								종합소득세 신고
								때 1년 소득과
								경비를
								정산합니다. 낸
								세금(3.3%)이
								실제 내야 할
								세금보다 많으면
								차액을 돌려받고,
								적으면 더
								냅니다.
							</p>
						</details>
						<details>
							<summary>실수령액으로
								계산하면 왜 딱
								떨어지지 않나요?</summary>
							<p>
								세금을 10원
								단위로 버리기
								때문에 몇 원
								차이 나는 여러
								세전 금액이 같은
								실수령액이
								됩니다. 이
								계산기는 그중
								가장 작은 세전
								금액을
								보여줍니다.
							</p>
						</details>
						<details>
							<summary>4대보험도
								빠지나요?</summary>
							<p>
								3.3%를 떼는
								사업소득은
								회사가 4대보험을
								떼지 않습니다.
								대신
								지역가입자로
								건강보험료·국민연금을
								직접 낼 수
								있습니다.
							</p>
						</details>
						<p class="krw-source">
							근거: 소득세법 제129조
							제1항(사업소득 원천징수
							3%), 제86조(소액부징수),
							지방세법(지방소득세 =
							소득세의 10%)
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="freelance-tax-calc" />
			</:end>
		</CanonSplit>
	</template>
}
