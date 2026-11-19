import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import { bmi } from 'delphitools-v2/lib/life/bmi';
import './krw/krw.css';

export default class BmiCalc extends Component {
	@tracked height = 170;
	@tracked weight = 65;

	get lines(): ResultLine[] {
		const r = bmi(this.height, this.weight);
		if (!r.valid)
			return [
				{
					label: '키와 몸무게를 넣어 주세요',
					value: '—',
				},
			];
		return [
			{
				label: '체질량지수 (BMI)',
				value: r.value.toFixed(1),
				main: true,
			},
			{ label: '판정 (대한비만학회 기준)', value: r.label },
			{
				label: '정상 체중 범위',
				value: `${r.min}~${r.max}kg`,
				note: 'BMI 18.5 이상 23 미만',
			},
		];
	}

	setHeight = (value: number) => (this.height = value);
	setWeight = (value: number) => (this.weight = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="입력" />
					<div class="krw-form">
						<NumberField
							@label="키"
							@value={{this.height}}
							@unit="cm"
							@decimal={{true}}
							@onChange={{this.setHeight}}
						/>
						<NumberField
							@label="몸무게"
							@value={{this.weight}}
							@unit="kg"
							@decimal={{true}}
							@onChange={{this.setWeight}}
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
					<CanonHeading @text="BMI 계산 방법" />
					<div class="krw-guide">
						<p>
							체질량지수(BMI)는
							몸무게(kg)를 키(m)의
							제곱으로 나눈 값으로,
							키에 비해 몸무게가 어느
							정도인지 보는 가장
							간단한 지표입니다. 예를
							들어 키 170cm, 몸무게
							65kg이면 65 ÷ (1.7 ×
							1.7) = 22.5입니다.
						</p>
						<p>
							아시아인은 서양인보다
							낮은 BMI에서도
							당뇨병·고혈압 같은 질환
							위험이 높아지는 경향이
							있어, 대한비만학회는
							세계보건기구 (WHO)
							서양인 기준(25 과체중,
							30 비만)보다 낮은 기준을
							씁니다.
						</p>
						<ul>
							<li>18.5 미만: 저체중</li>
							<li>18.5 이상 23 미만:
								정상</li>
							<li>23 이상 25 미만:
								비만 전
								단계(과체중)</li>
							<li>25 이상 30 미만:
								1단계 비만</li>
							<li>30 이상 35 미만:
								2단계 비만</li>
							<li>35 이상: 3단계
								비만(고도 비만)</li>
						</ul>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>BMI가 정상이면
								건강한 건가요?</summary>
							<p>
								BMI는 근육과
								지방을 구분하지
								못합니다. 근육이
								많은 운동선수는
								비만으로 나올 수
								있고, 마른
								체형이라도
								뱃살(복부
								지방)이 많을 수
								있습니다.
								대한비만학회는
								허리둘레도 함께
								보도록 하며,
								남자 90cm, 여자
								85cm 이상을
								복부비만으로
								봅니다.
							</p>
						</details>
						<details>
							<summary>어린이·청소년도
								이 기준으로
								보나요?</summary>
							<p>
								아닙니다.
								성장기에는
								나이·성별에 따라
								정상 범위가 달라
								소아청소년
								성장도표의
								백분위로
								판단합니다. 이
								계산기는 성인
								기준입니다.
							</p>
						</details>
						<details>
							<summary>임신 중에도 쓸
								수 있나요?</summary>
							<p>
								임신 중에는
								몸무게가
								늘어나는 것이
								정상이라 BMI
								판정이 맞지
								않습니다. 임신
								전 몸무게로
								계산한 BMI를
								참고하세요.
							</p>
						</details>
						<p class="krw-source">
							기준: 대한비만학회 비만
							진료지침. 이 계산기는
							의학적 진단을 대신하지
							않습니다.
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="bmi-calc" />
			</:end>
		</CanonSplit>
	</template>
}
