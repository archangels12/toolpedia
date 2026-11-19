import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import { comma } from 'delphitools-v2/lib/krw/money';
import { ACTIVITY, bmr, tdee } from 'delphitools-v2/lib/life/bmr';
import './krw/krw.css';

const sexNames = ['남자', '여자'];
const activityNames = ACTIVITY.map((a) => a.label);

export default class BmrCalc extends Component {
	@tracked sex = 0;
	@tracked age = 30;
	@tracked height = 170;
	@tracked weight = 65;
	@tracked activity = 1;

	get activityNote() {
		return ACTIVITY[this.activity]?.note ?? '';
	}

	get lines(): ResultLine[] {
		const base = bmr(
			this.sex === 0,
			this.age,
			this.height,
			this.weight,
		);
		if (!base)
			return [
				{
					label: '나이·키·몸무게를 넣어 주세요',
					value: '—',
				},
			];
		const daily = tdee(base, this.activity);
		return [
			{
				label: '기초대사량',
				value: `${comma(base)}kcal`,
				main: true,
			},
			{
				label: '하루 소비 칼로리',
				value: `${comma(daily)}kcal`,
				note: '이만큼 먹으면 체중 유지',
			},
			{
				label: '감량할 때',
				value: `${comma(Math.max(daily - 500, base))}kcal`,
				note: '하루 500kcal 덜 먹기 (기초대사량 아래로는 안 내림)',
			},
			{
				label: '증량할 때',
				value: `${comma(daily + 300)}kcal`,
				note: '하루 300kcal 더 먹기',
			},
		];
	}

	pickSex = (index: number) => (this.sex = index);
	pickActivity = (index: number) => (this.activity = index);
	setAge = (value: number) => (this.age = value);
	setHeight = (value: number) => (this.height = value);
	setWeight = (value: number) => (this.weight = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="입력" />
					<div class="krw-form">
						<CanonSegmented
							aria-label="성별"
							@items={{sexNames}}
							@selected={{this.sex}}
							@onChange={{this.pickSex}}
						/>
						<NumberField
							@label="나이 (만)"
							@value={{this.age}}
							@unit="세"
							@onChange={{this.setAge}}
						/>
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
						<div class="krw-choice">
							<span
								class="krw-field-label"
							>평소 활동량</span>
							<CanonSegmented
								aria-label="평소 활동량"
								@items={{activityNames}}
								@selected={{this.activity}}
								@columns={{1}}
								@onChange={{this.pickActivity}}
							/>
							<span
								class="krw-field-note"
							>{{this.activityNote}}</span>
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
						@text="기초대사량 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							기초대사량은 하루 종일
							누워만 있어도 숨쉬기,
							심장 박동, 체온 유지에
							쓰이는 최소한의
							에너지입니다. 여기에
							걷고 일하고 운동하는 데
							드는 에너지를 더한 것이
							하루 소비 칼로리입니다.
							이 계산기는 여러 공식
							가운데 실제 측정값과 잘
							맞는 편으로 알려진
							미플린-세인트
							제오르(Mifflin-St Jeor)
							공식을 씁니다.
						</p>
						<ul>
							<li>남자: 10 ×
								몸무게(kg) +
								6.25 × 키(cm) −
								5 × 나이 + 5</li>
							<li>여자: 10 ×
								몸무게(kg) +
								6.25 × 키(cm) −
								5 × 나이 − 161</li>
							<li>
								하루 소비 칼로리
								= 기초대사량 ×
								활동 계수 (거의
								안 움직임 1.2,
								가벼운 활동
								1.375, 보통
								1.55, 많음
								1.725, 매우 많음
								1.9)
							</li>
						</ul>
						<p>
							예를 들어 30세 남자, 키
							175cm, 몸무게 70kg이면
							기초대사량은 약
							1,649kcal이고, 주 3~5회
							운동한다면 하루 소비
							칼로리는 약
							2,556kcal입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>다이어트할 때는
								얼마나 먹어야
								하나요?</summary>
							<p>
								하루 소비
								칼로리보다
								500kcal 정도
								적게 먹는 방법이
								흔히 쓰입니다.
								기초대사량보다
								적게 먹으면
								근육이 빠지고
								오래 유지하기
								어려워, 이
								계산기는 감량
								칼로리를
								기초대사량
								아래로 내리지
								않습니다.
							</p>
						</details>
						<details>
							<summary>인바디에 나온
								기초대사량과 왜
								다른가요?</summary>
							<p>
								체성분 측정기는
								근육량을 반영해
								계산하고, 이
								계산기는
								키·몸무게·나이·성별만으로
								추정합니다.
								근육이 많은
								사람은 실제
								기초대사량이 더
								높을 수
								있습니다.
							</p>
						</details>
						<details>
							<summary>활동량은 어떻게
								고르나요?</summary>
							<p>
								사무직이고 따로
								운동하지 않으면
								"거의 안
								움직임"을
								고르세요.
								활동량을 높게
								고르면 실제보다
								많이 먹게 되기
								쉬우니, 헷갈리면
								한 단계 낮은
								쪽을 고르는 편이
								안전합니다.
							</p>
						</details>
						<p class="krw-source">
							공식: Mifflin MD, St
							Jeor ST 외 (1990). 이
							계산기는 의학적
							진단·영양 상담을
							대신하지 않습니다.
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="bmr-calc" />
			</:end>
		</CanonSplit>
	</template>
}
