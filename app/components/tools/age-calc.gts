import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSplit from 'delphicanon/components/canon-split';
import DateField from 'delphitools-v2/components/tools/krw/date-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import { comma } from 'delphitools-v2/lib/krw/money';
import { age } from 'delphitools-v2/lib/life/age';
import { todayIso } from 'delphitools-v2/lib/life/date';
import './krw/krw.css';

export default class AgeCalc extends Component {
	@tracked birth = '1990-01-01';
	@tracked ref = todayIso();

	get lines(): ResultLine[] {
		const r = age(this.birth, this.ref);
		if (!r.valid)
			return [
				{
					label: '날짜를 확인하세요',
					value: '—',
					note: '기준일이 생년월일보다 뒤여야 해요',
				},
			];
		return [
			{ label: '만 나이', value: `${r.man}세`, main: true },
			{
				label: '연 나이',
				value: `${r.year}세`,
				note: '병역·청소년 보호 기준',
			},
			{
				label: '세는 나이 (한국식)',
				value: `${r.counting}세`,
			},
			{ label: '띠', value: `${r.zodiac}띠` },
			{
				label: '태어난 지',
				value: `${comma(r.daysLived)}일`,
			},
			{
				label: '다음 생일까지',
				value:
					r.daysToBirthday === 0
						? '오늘이 생일이에요'
						: `${comma(r.daysToBirthday)}일`,
			},
		];
	}

	setBirth = (value: string) => (this.birth = value);
	setRef = (value: string) => (this.ref = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="입력" />
					<div class="krw-form">
						<DateField
							@label="생년월일 (양력)"
							@value={{this.birth}}
							@onChange={{this.setBirth}}
						/>
						<DateField
							@label="기준일"
							@value={{this.ref}}
							@onChange={{this.setRef}}
							@hint="처음에는 오늘 날짜예요"
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
					<CanonHeading @text="나이 계산 방법" />
					<div class="krw-guide">
						<p>
							생년월일을 넣으면 만
							나이, 연 나이, 세는
							나이를 한 번에
							계산합니다. 2023년 6월
							28일부터
							법령·계약·공문서의
							나이는 특별한 규정이
							없으면 만 나이로
							셉니다(행정기본법
							제7조의2, 민법 제158조).
						</p>
						<ul>
							<li>
								만 나이: 기준
								연도 − 출생
								연도, 올해
								생일이 아직 안
								지났으면 1을
								뺍니다. 태어난
								날은 0살입니다.
							</li>
							<li>
								연 나이: 기준
								연도 − 출생
								연도. 생일과
								상관없이 1월
								1일에 모두 한
								살씩 먹습니다.
							</li>
							<li>
								세는 나이: 연
								나이 + 1.
								태어나자마자
								1살로 치는 예전
								한국식
								나이입니다.
							</li>
						</ul>
						<p>
							예를 들어 1990년 5월
							15일에 태어난 사람은
							2026년 11월 19일
							기준으로 만 36세, 연
							나이 36세, 세는 나이
							37세입니다. 같은 해 5월
							14일이라면 생일 전이라
							만 35세입니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>만 나이 통일
								뒤에도 연 나이를
								쓰는 곳이
								있나요?</summary>
							<p>
								있습니다. 병역
								의무(병역법),
								청소년 술·담배
								구매 제한(청소년
								보호법)처럼 법에
								따로 정해 둔
								경우에는 연
								나이를 그대로
								씁니다. 같은
								해에 태어난
								사람을 한꺼번에
								관리하기
								위해서입니다.
							</p>
						</details>
						<details>
							<summary>2월 29일생은
								평년에 언제
								나이를 먹나요?</summary>
							<p>
								이 계산기는 2월
								29일이 없는
								해에는 3월 1일에
								한 살을
								더합니다. 2월
								28일까지는 생일
								전으로 봅니다.
							</p>
						</details>
						<details>
							<summary>띠는 양력 1월
								1일에 바뀌나요?</summary>
							<p>
								전통적으로 띠는
								음력 설날이나
								입춘(양력 2월
								4일 무렵)에
								바뀝니다. 이
								계산기는 양력
								출생 연도로 띠를
								보여 주므로,
								1월이나 2월 초에
								태어났다면 앞
								해의 띠일 수
								있습니다.
							</p>
						</details>
						<details>
							<summary>음력 생일로도
								계산할 수
								있나요?</summary>
							<p>
								만 나이는 양력
								생년월일로
								계산합니다.
								주민등록상
								생년월일이
								음력이라면
								양력으로 바꾼
								날짜를 넣으세요.
							</p>
						</details>
						<p class="krw-source">근거: 민법
							제158조(나이의 계산과
							표시), 행정기본법
							제7조의2</p>
					</div>
				</CanonRows>
				<KrwRelated @current="age-calc" />
			</:end>
		</CanonSplit>
	</template>
}
