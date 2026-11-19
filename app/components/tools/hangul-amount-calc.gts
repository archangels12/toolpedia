import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { service } from '@ember/service';
import CanonButton from 'delphicanon/components/canon-button';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import type CanonToastService from 'delphicanon/services/canon-toast';
import { IconSvg } from 'delphitools-v2/components/icon';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import { comma } from 'delphitools-v2/lib/krw/money';
import {
	formal,
	hanja,
	MAX,
	spoken,
} from 'delphitools-v2/lib/life/hangul-number';
import './krw/krw.css';

const CopyIcon = <template><IconSvg @name="copy" /></template>;

export default class HangulAmountCalc extends Component {
	@service('canon-toast') declare toast: CanonToastService;
	@tracked amount = 1234567;

	get tooBig() {
		return this.amount > MAX;
	}

	get rows() {
		const n = this.amount;
		return [
			{
				label: '계약서·영수증용',
				value: `금 ${formal(n)}원정 (₩${comma(n)})`,
			},
			{ label: '한글만', value: `${formal(n)}원` },
			{ label: '읽는 방식', value: `${spoken(n)} 원` },
			{ label: '한자 (갖은자)', value: `金${hanja(n)}圓整` },
		];
	}

	set = (value: number) => (this.amount = value);
	copy = (text: string) => void this.toast.copy(text);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="입력" />
					<div class="krw-form">
						<MoneyField
							@label="금액 (숫자)"
							@value={{this.amount}}
							@onChange={{this.set}}
						/>
					</div>
				</CanonRows>
			</:sidebar>
			<:main>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="변환 결과" />
					{{#if this.tooBig}}
						<dl class="krw-result">
							<div
								class="krw-result-line is-main"
							>
								<dt>9,999조
									원까지
									바꿀 수
									있어요</dt>
								<dd><span
										class="krw-result-value"
									>—</span></dd>
							</div>
						</dl>
					{{else}}
						<dl
							class="krw-result"
							aria-live="polite"
						>
							{{#each
								this.rows
								as |row|
							}}
								<div
									class="krw-amount-line"
								>
									<dt
									>{{row.label}}</dt>
									<dd>
										<span
										>{{row.value}}</span>
										<CanonButton
											@kind="cell"
											@icon={{CopyIcon}}
											@label="{{row.label}} 복사"
											@onClick={{fn
												this.copy
												row.value
											}}
										/>
									</dd>
								</div>
							{{/each}}
						</dl>
					{{/if}}
				</CanonRows>
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading
						@text="금액을 한글로 쓰는 방법"
					/>
					<div class="krw-guide">
						<p>
							계약서, 차용증, 영수증,
							견적서에는 금액을 숫자와
							함께 한글이나 한자로
							적는 경우가 많습니다.
							숫자 0 하나를 더하거나
							고쳐 쓰는 위조를 막기
							위해서입니다. 숫자를
							넣으면 바로 쓸 수 있는
							형태로 바꾸고, 오른쪽
							버튼으로 복사할 수
							있습니다.
						</p>
						<ul>
							<li>
								네 자리(만
								단위)씩 끊어
								만·억·조를
								붙입니다.
								1,234,567원은
								123만
								4567원이므로
								"백이십삼만
								사천오백육십칠"입니다.
							</li>
							<li>
								계약서에서는
								"일백",
								"일천"처럼 맨
								앞의 '일'을
								생략하지 않고,
								띄어 쓰지 않고
								붙여 씁니다.
								중간에 글자를
								끼워 넣지 못하게
								하려는 것입니다.
							</li>
							<li>
								금액 앞에는
								"금", 뒤에는
								"원정"을 붙여
								금액이 거기서
								끝난다는 것을
								나타냅니다.
							</li>
						</ul>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>"일금"과 "금"
								중 무엇을
								쓰나요?</summary>
							<p>
								둘 다 널리
								씁니다. 이
								계산기는
								"금"으로 보여
								주니, "일금"으로
								쓰는 양식이라면
								앞에 "일"을
								붙이세요.
							</p>
						</details>
						<details>
							<summary>갖은자는 언제
								쓰나요?</summary>
							<p>
								一·二·三처럼
								획이 적은 한자는
								한 획만 더해
								다른 숫자로 고칠
								수 있어서,
								금액을 적는
								문서에는
								壹·貳·參처럼
								획이 많은
								갖은자를 쓰기도
								합니다. 요즘은
								한글로 쓰는
								경우가
								대부분인데,
								한글도 '삼'을
								'사'로 고치는
								식의 변조가
								가능하니 숫자
								금액을 꼭 함께
								적으세요.
							</p>
						</details>
						<details>
							<summary>숫자와 한글
								금액이 다르면
								어느 쪽이
								맞나요?</summary>
							<p>
								어음법·수표법에는
								글자로 적은
								금액과 숫자로
								적은 금액이
								다르면 글자 쪽을
								따른다는 규정이
								있습니다. 다른
								계약서는 상황에
								따라 해석이
								달라질 수 있으니
								두 금액이 같은지
								꼭 확인하세요.
							</p>
						</details>
						<p class="krw-source">참고:
							어음법 제6조, 수표법
							제9조(문자와 숫자로 적은
							금액이 다른 경우)</p>
					</div>
				</CanonRows>
				<KrwRelated @current="hangul-amount-calc" />
			</:end>
		</CanonSplit>
	</template>
}
