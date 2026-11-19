import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import { won } from 'delphitools-v2/lib/krw/money';
import {
	change,
	discount,
	num,
	percentOf,
	ratio,
} from 'delphitools-v2/lib/life/percent';
import './krw/krw.css';

const modes = ['A의 B%는?', 'A는 B의 몇 %?', '증감률', '할인가'];

// 모드마다 두 입력칸의 이름·단위
const fields = [
	['전체 값 (A)', '', '퍼센트 (B)', '%'],
	['부분 값 (A)', '', '전체 값 (B)', ''],
	['처음 값', '', '바뀐 값', ''],
	['정가', '원', '할인율', '%'],
] as const;

export default class PercentCalc extends Component {
	@tracked mode = 0;
	@tracked a = 50000;
	@tracked b = 15;
	@tracked price = 39900;
	@tracked rate = 30;

	get labels() {
		return fields[this.mode]!;
	}

	get isDiscount() {
		return this.mode === 3;
	}

	get lines(): ResultLine[] {
		const { a, b } = this;
		if (this.mode === 0)
			return [
				{
					label: `${num(a)}의 ${num(b)}%`,
					value: num(percentOf(a, b)),
					main: true,
				},
				{
					label: `${num(b)}% 더하면`,
					value: num(a + percentOf(a, b)),
				},
				{
					label: `${num(b)}% 빼면`,
					value: num(a - percentOf(a, b)),
				},
			];
		if (this.mode === 1)
			return [
				{
					label: `${num(a)}는 ${num(b)}의`,
					value: `${num(ratio(a, b))}%`,
					main: true,
				},
			];
		if (this.mode === 2) {
			const pct = change(a, b);
			return [
				{
					label: pct < 0 ? '감소율' : '증가율',
					value: `${num(Math.abs(pct))}%`,
					main: true,
				},
				{ label: '차이', value: num(b - a) },
				{
					label: '배수',
					value: a ? `${num(b / a)}배` : '—',
				},
			];
		}
		const r = discount(this.price, this.rate);
		return [
			{
				label: '할인가 (내는 돈)',
				value: won(r.final),
				main: true,
			},
			{ label: '할인 금액', value: won(r.off) },
		];
	}

	pick = (index: number) => (this.mode = index);
	setA = (value: number) => (this.a = value);
	setB = (value: number) => (this.b = value);
	setPrice = (value: number) => (this.price = value);
	setRate = (value: number) => (this.rate = value);

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
							@columns={{2}}
							@onChange={{this.pick}}
						/>
						{{#if this.isDiscount}}
							<MoneyField
								@label="정가"
								@value={{this.price}}
								@onChange={{this.setPrice}}
							/>
							<NumberField
								@label="할인율"
								@value={{this.rate}}
								@unit="%"
								@decimal={{true}}
								@onChange={{this.setRate}}
							/>
						{{else}}
							<NumberField
								@label={{this.labels.[0]}}
								@value={{this.a}}
								@unit={{this.labels.[1]}}
								@decimal={{true}}
								@onChange={{this.setA}}
							/>
							<NumberField
								@label={{this.labels.[2]}}
								@value={{this.b}}
								@unit={{this.labels.[3]}}
								@decimal={{true}}
								@onChange={{this.setB}}
							/>
						{{/if}}
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
						@text="퍼센트 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							퍼센트(%)는 전체를
							100으로 봤을 때의
							비율입니다. 자주 쓰는 네
							가지 계산을 공식과 함께
							정리했습니다.
						</p>
						<ul>
							<li>A의 B% = A × B ÷
								100. 예: 5만
								원의 15%는
								7,500원</li>
							<li>A는 B의 몇 % = A ÷ B
								× 100. 예:
								120문제 중
								30문제를
								맞혔다면 25%</li>
							<li>
								증감률 = (바뀐
								값 − 처음 값) ÷
								처음 값 × 100.
								예: 매출이
								80에서 100이
								되면 25% 증가
							</li>
							<li>
								할인가 = 정가 −
								정가 × 할인율 ÷
								100. 예:
								39,900원에서 30%
								할인하면
								27,930원
							</li>
						</ul>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>퍼센트와
								퍼센트포인트(%p)는
								어떻게 다른가요?</summary>
							<p>
								금리가 2%에서
								3%로 오르면
								차이는
								1퍼센트포인트(%p)이고,
								증가율은
								50%입니다. %p는
								두 비율의 단순한
								차이, %는 처음
								값 대비 얼마나
								변했는지입니다.
								증감률 모드에
								2와 3을 넣으면
								50%가 나옵니다.
							</p>
						</details>
						<details>
							<summary>20% 할인 후
								다시 10%
								할인하면 30%
								할인인가요?</summary>
							<p>
								아닙니다. 1만
								원을 20%
								할인하면
								8,000원, 다시
								10% 할인하면
								7,200원이라 전체
								할인율은
								28%입니다. 두
								번째 할인은 이미
								깎인 가격에
								적용되기
								때문입니다.
							</p>
						</details>
						<details>
							<summary>50% 떨어진 뒤
								50% 오르면
								원래대로
								돌아오나요?</summary>
							<p>
								아닙니다. 100이
								50% 떨어지면 50,
								다시 50% 오르면
								75입니다. 원래
								값 100으로
								돌아가려면
								50에서 100%
								올라야 합니다.
							</p>
						</details>
						<p class="krw-source">할인
							금액의 원 단위 미만은
							버립니다.</p>
					</div>
				</CanonRows>
				<KrwRelated @current="percent-calc" />
			</:end>
		</CanonSplit>
	</template>
}
