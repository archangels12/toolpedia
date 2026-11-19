import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import DateField from 'delphitools-v2/components/tools/krw/date-field';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import { addDays, koDate, todayIso } from 'delphitools-v2/lib/life/date';
import { cycles, type Cycle } from 'delphitools-v2/lib/life/cycle';
import './krw/krw.css';

// "2026년 11월 10일 (화)" → "11월 10일 (화)"
const short = (iso: string) => koDate(iso).replace(/^\d+년 /, '');

export default class OvulationCalc extends Component {
	@tracked last = addDays(todayIso(), -14);
	@tracked length = 28;

	get lines(): ResultLine[] {
		const list = cycles(this.last, this.length, 3);
		if (!list.length)
			return [
				{
					label: '입력을 확인하세요',
					value: '—',
					note: '주기는 20~45일 사이로 넣어 주세요',
				},
			];
		const [now, ...later] = list as [Cycle, ...Cycle[]];
		return [
			{
				label: '이번 주기 배란 예정일',
				value: koDate(now.ovulation),
				main: true,
			},
			{
				label: '가임기',
				value: `${short(now.fertileStart)} ~ ${short(now.fertileEnd)}`,
			},
			{ label: '다음 생리 예정일', value: koDate(now.start) },
			...later.map((c, i) => ({
				label: `${i + 2}번째 주기 배란일`,
				value: koDate(c.ovulation),
				note: `가임기 ${short(c.fertileStart)} ~ ${short(c.fertileEnd)}`,
			})),
		];
	}

	setLast = (value: string) => (this.last = value);
	setLength = (value: number) => (this.length = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="입력" />
					<div class="krw-form">
						<DateField
							@label="마지막 생리 시작일"
							@value={{this.last}}
							@onChange={{this.setLast}}
						/>
						<NumberField
							@label="평균 생리 주기"
							@value={{this.length}}
							@unit="일"
							@onChange={{this.setLength}}
							@hint="생리 시작일부터 다음 시작일 전날까지. 모르면 28일"
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
						@text="배란일 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							마지막 생리 시작일과
							평균 주기를 넣으면 다음
							배란 예정일, 임신
							가능성이 높은 가임기,
							다음 생리 예정일을
							3주기까지 보여 줍니다.
							달력으로 계산하는
							방법(달력법)을 씁니다.
						</p>
						<ul>
							<li>
								다음 생리 예정일
								= 마지막 생리
								시작일 + 평균
								주기
							</li>
							<li>
								배란 예정일 =
								다음 생리 예정일
								− 14일. 배란 뒤
								다음 생리까지의
								기간(황체기)은
								평균 약
								14일입니다. 다만
								사람과 달에 따라
								짧게는 7일,
								길게는 19일까지
								차이 난다는
								연구도 있어
								추정값으로만
								보세요.
							</li>
							<li>
								가임기 = 배란일
								5일 전부터 배란
								다음 날까지.
								정자는 몸 안에서
								최대 5일 정도,
								난자는 배란 뒤
								하루 정도 살아
								있기 때문입니다.
							</li>
						</ul>
						<p>
							예를 들어 11월 1일에
							생리를 시작했고 주기가
							28일이면 다음 생리는
							11월 29일, 배란일은 11월
							15일, 가임기는 11월
							10일부터 16일까지입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>주기가
								불규칙하면
								어떻게 하나요?</summary>
							<p>
								최근 몇 달의
								주기를 평균 내어
								넣으세요. 다만
								주기가 달마다
								크게 달라지면
								달력법은 잘 맞지
								않습니다. 배란
								테스트기나
								기초체온 측정을
								함께 쓰면 더
								정확합니다.
							</p>
						</details>
						<details>
							<summary>가임기가 아니면
								피임하지 않아도
								되나요?</summary>
							<p>
								아닙니다.
								배란일은
								스트레스, 수면,
								건강 상태에 따라
								앞당겨지거나
								늦어질 수
								있어서,
								달력법만으로
								피임하면 실패할
								가능성이 큽니다.
								피임이
								목적이라면 다른
								방법을 쓰세요.
							</p>
						</details>
						<details>
							<summary>임신을 준비할
								때 언제가
								좋나요?</summary>
							<p>
								배란일과 그 전
								2~3일이 가능성이
								가장 높은 시기로
								알려져 있습니다.
								35세 미만은 1년,
								35세 이상은
								6개월 동안
								시도해도 임신이
								되지 않으면
								산부인과 상담을
								받아 보세요.
							</p>
						</details>
						<p class="krw-source">
							이 계산기는 평균값으로
							추정한 참고용이며,
							의학적 진단을 대신하지
							않습니다.
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="ovulation-calc" />
			</:end>
		</CanonSplit>
	</template>
}
