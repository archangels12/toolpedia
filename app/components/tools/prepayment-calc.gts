import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult from 'delphitools-v2/components/tools/krw/result';
import { won } from 'delphitools-v2/lib/krw/money';
import { prepaymentFee } from 'delphitools-v2/lib/krw/prepayment';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import './krw/krw.css';

export default class PrepaymentCalc extends Component {
	@tracked amount = 50000000;
	@tracked rate = 0.6;
	@tracked elapsed = 12;
	@tracked period = 36;

	get result() {
		return prepaymentFee(
			this.amount,
			this.rate,
			this.elapsed,
			this.period,
		);
	}

	get lines() {
		const r = this.result;
		return [
			{
				label: '중도상환수수료',
				value: won(r.fee),
				main: true,
				note:
					r.remaining === 0
						? '수수료 부과 기간이 지나 수수료가 없어요'
						: undefined,
			},
			{
				label: '남은 부과 기간',
				value: `${r.remaining}개월`,
			},
			{
				label: '적용 비율',
				value: `${(r.ratio * 100).toFixed(1)}%`,
			},
		];
	}

	setAmount = (value: number) => (this.amount = value);
	setRate = (value: number) => (this.rate = Math.min(value, 10));
	setElapsed = (value: number) => (this.elapsed = value);
	setPeriod = (value: number) => (this.period = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="상환 조건" />
					<div class="krw-form">
						<MoneyField
							@label="미리 갚을 금액"
							@value={{this.amount}}
							@onChange={{this.setAmount}}
						/>
						<NumberField
							@label="중도상환수수료율"
							@value={{this.rate}}
							@unit="%"
							@decimal={{true}}
							@hint="대출 약정서에 적혀 있어요"
							@onChange={{this.setRate}}
						/>
						<NumberField
							@label="대출받은 뒤 지난 기간"
							@value={{this.elapsed}}
							@unit="개월"
							@onChange={{this.setElapsed}}
						/>
						<NumberField
							@label="수수료 부과 기간"
							@value={{this.period}}
							@unit="개월"
							@hint="보통 3년(36개월)"
							@onChange={{this.setPeriod}}
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
						@text="중도상환수수료 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							중도상환수수료 = 미리
							갚을 금액 × 수수료율 ×
							(남은 부과 기간 ÷ 전체
							부과 기간). 대출받은 지
							오래될수록 수수료가
							줄어들고, 부과 기간(보통
							3년)이 지나면 수수료
							없이 갚을 수 있습니다.
						</p>
						<p>
							예를 들어 5,000만 원을
							수수료율 0.6%, 3년 중
							1년이 지난 시점에 갚으면
							5,000만 원 × 0.6% × 24 ÷
							36 = 20만 원입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>수수료율은
								어디서
								확인하나요?</summary>
							<p>
								대출 약정서나
								은행 앱의 대출
								상세 화면에 적혀
								있습니다. 2025년
								1월부터는
								금융회사가 실제
								드는 비용만큼만
								수수료를 받도록
								제도가 바뀌어,
								그 이후 받은
								대출은 예전보다
								수수료율이 낮은
								경우가 많습니다.
							</p>
						</details>
						<details>
							<summary>은행 계산과
								조금 달라요.</summary>
							<p>
								은행은 개월이
								아니라 실제
								일수로 남은
								기간을
								계산합니다.
								정확한 금액은
								상환 전에 은행에
								확인하세요.
							</p>
						</details>
						<details>
							<summary>수수료를 내도
								미리 갚는 게
								이득인가요?</summary>
							<p>
								미리 갚으면 남은
								기간의 이자를
								아낄 수
								있습니다. 아끼는
								이자가
								중도상환수수료보다
								크면 미리 갚는
								편이 유리합니다.
								대출이자
								계산기로 남은
								이자를 계산해
								비교해 보세요.
							</p>
						</details>
						<p class="krw-source">
							근거: 금융소비자보호법
							제20조(중도상환수수료
							부과 제한), 같은 법
							감독규정(실비용 내 부과,
							2025년 1월 13일 이후
							계약부터)
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="prepayment-calc" />
			</:end>
		</CanonSplit>
	</template>
}
