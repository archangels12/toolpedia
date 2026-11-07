import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import { won } from 'delphitools-v2/lib/krw/money';
import { fromSupply, fromTotal } from 'delphitools-v2/lib/krw/vat';
import './krw/krw.css';

const modes = ['공급가액으로 계산', '합계금액으로 계산'];

export default class VatCalc extends Component {
	@tracked mode = 0;
	@tracked amount = 1000000;

	get result() {
		return this.mode === 0
			? fromSupply(this.amount)
			: fromTotal(this.amount);
	}

	get label() {
		return this.mode === 0
			? '공급가액 (부가세 빼고)'
			: '합계금액 (부가세 포함)';
	}

	get lines() {
		const r = this.result;
		const lines: ResultLine[] = [
			{ label: '공급가액', value: won(r.supply) },
			{ label: '부가세 (10%)', value: won(r.vat) },
			{ label: '합계금액', value: won(r.total) },
		];
		const main = this.mode === 0 ? 2 : 1;
		lines[main] = { ...lines[main]!, main: true };
		return lines;
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
						@text="부가세 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							부가가치세(부가세)는
							물건값이나 서비스 대가에
							붙는 세금으로, 세율은
							10%입니다.
						</p>
						<ul>
							<li>공급가액에서 계산:
								부가세 =
								공급가액 × 10%,
								합계 = 공급가액
								+ 부가세</li>
							<li>
								합계금액에서
								계산: 공급가액 =
								합계금액 ÷ 1.1,
								부가세 =
								합계금액 −
								공급가액
							</li>
						</ul>
						<p>
							예를 들어 합계 110만
							원이면 공급가액 100만
							원, 부가세 10만
							원입니다. 나눠서 생기는
							원 단위 미만은
							공급가액에서 올림해
							부가세와 합계가 정확히
							맞도록 했습니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>공급가액과
								공급대가는
								어떻게 다른가요?</summary>
							<p>
								공급가액은
								부가세를 뺀
								금액, 공급대가는
								부가세를 포함한
								금액입니다.
								세금계산서에는
								공급가액과
								세액을 따로
								적습니다.
							</p>
						</details>
						<details>
							<summary>간이과세자도
								10%로
								계산하나요?</summary>
							<p>
								간이과세자는
								업종별
								부가가치율을
								곱해 세액을
								계산하므로 이
								계산기와
								다릅니다. 이
								계산기는
								일반과세자의
								거래 금액
								기준입니다.
							</p>
						</details>
						<details>
							<summary>계산 결과를
								신고에 그대로
								써도 되나요?</summary>
							<p>
								참고용입니다.
								실제 신고는
								홈택스나 세무
								전문가를 통해
								확인하세요.
							</p>
						</details>
						<p class="krw-source">근거:
							부가가치세법 제30조(세율
							10%)</p>
					</div>
				</CanonRows>
			</:end>
		</CanonSplit>
	</template>
}
