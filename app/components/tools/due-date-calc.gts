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
import { comma } from 'delphitools-v2/lib/krw/money';
import { addDays, koDate, todayIso } from 'delphitools-v2/lib/life/date';
import { pregnancy } from 'delphitools-v2/lib/life/cycle';
import './krw/krw.css';

const today = todayIso();

export default class DueDateCalc extends Component {
	@tracked last = addDays(today, -70);
	@tracked length = 28;

	get lines(): ResultLine[] {
		const r = pregnancy(this.last, this.length, today);
		if (!r.dueDate)
			return [
				{
					label: '입력을 확인하세요',
					value: '—',
					note: '주기는 20~45일 사이로 넣어 주세요',
				},
			];
		const lines: ResultLine[] = [
			{
				label: '출산 예정일',
				value: koDate(r.dueDate),
				main: true,
			},
		];
		if (!r.valid)
			return [
				...lines,
				{
					label: '오늘 기준',
					value: '아직 임신 주수를 셀 수 없어요',
				},
			];
		return [
			...lines,
			{
				label: '오늘 임신 주수',
				value: `${r.weeks}주 ${r.days}일`,
				note: `임신 ${r.trimester}기`,
			},
			{
				label: '예정일까지',
				value:
					r.daysLeft > 0
						? `${comma(r.daysLeft)}일 남음`
						: r.daysLeft === 0
							? '오늘이 예정일이에요'
							: `${comma(-r.daysLeft)}일 지남`,
			},
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
							@hint="모르면 28일"
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
						@text="출산 예정일 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							출산 예정일은 마지막
							생리 시작일로부터
							280일(40주) 뒤입니다.
							임신 주수도 실제
							수정일이 아니라 마지막
							생리 시작일부터 셉니다.
							그래서 임신 사실을 알게
							되는 무렵이면 이미
							4~5주로 계산됩니다.
						</p>
						<ul>
							<li>출산 예정일 = 마지막
								생리 시작일 +
								280일</li>
							<li>
								주기가 28일보다
								길거나 짧으면
								배란도 그만큼
								늦거나 이르므로,
								차이만큼
								예정일을
								조정합니다. 35일
								주기면 7일 뒤로
								미룹니다.
							</li>
							<li>
								임신 1기는 13주
								6일까지, 2기는
								14주부터 27주
								6일까지, 3기는
								28주부터입니다.
							</li>
						</ul>
						<p>
							예를 들어 마지막 생리
							시작일이 2026년 3월
							1일이고 주기가 28일이면
							출산 예정일은 2026년
							12월 6일이고, 2026년
							11월 19일에는 37주
							4일입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>병원에서 알려
								준 예정일과 왜
								다른가요?</summary>
							<p>
								임신 초기
								초음파로 태아
								크기(머리엉덩이
								길이)를 재서
								예정일을 다시
								정하는 경우가
								많습니다.
								병원에서 알려 준
								날짜가 있다면 그
								날짜를 따르세요.
							</p>
						</details>
						<details>
							<summary>예정일에 실제로
								낳는 경우가
								많나요?</summary>
							<p>
								예정일은
								평균적인 날짜일
								뿐이라 정확히 그
								날 태어나는
								아기는 많지
								않습니다.
								37주부터 42주
								전까지 태어나면
								만삭 출산으로
								봅니다.
							</p>
						</details>
						<details>
							<summary>시험관
								시술(IVF)도
								이렇게
								계산하나요?</summary>
							<p>
								시험관 시술은
								배아를 이식한
								날과 배아 배양
								일수로 예정일을
								계산합니다.
								시술한 병원의
								안내를 따르세요.
							</p>
						</details>
						<p class="krw-source">
							계산법: 네겔레
							법칙(마지막 생리 시작일
							+ 280일). 이 계산기는
							의학적 진단을 대신하지
							않습니다.
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="due-date-calc" />
			</:end>
		</CanonSplit>
	</template>
}
