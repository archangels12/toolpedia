import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import NumberField from 'delphitools-v2/components/tools/krw/number-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import {
	bedtimes,
	clock,
	duration,
	toMin,
	wakeTimes,
} from 'delphitools-v2/lib/life/sleep';
import './krw/krw.css';

const modes = ['일어날 시각으로', '잠들 시각으로', '지금 자면'];

export default class SleepCalc extends Component {
	@tracked mode = 0;
	@tracked wake = '07:00';
	@tracked bed = '23:00';
	@tracked fallAsleep = 15;

	get timeLabel() {
		return this.mode === 0 ? '일어날 시각' : '누울 시각';
	}

	get timeValue() {
		return this.mode === 0 ? this.wake : this.bed;
	}

	get showTime() {
		return this.mode !== 2;
	}

	get lines(): ResultLine[] {
		if (this.mode === 0) {
			const wake = toMin(this.wake);
			if (Number.isNaN(wake))
				return [
					{
						label: '시각을 넣어 주세요',
						value: '—',
					},
				];
			return bedtimes(wake, this.fallAsleep).map((o, i) => ({
				label: `${o.cycles}주기 (${duration(o.sleep)} 수면)`,
				value: `${clock(o.time)}에 눕기`,
				main: i === 1,
				note:
					i === 1
						? '성인 권장 수면 7~9시간에 맞는 시각'
						: undefined,
			}));
		}
		const now = new Date();
		const bed =
			this.mode === 1
				? toMin(this.bed)
				: now.getHours() * 60 + now.getMinutes();
		if (Number.isNaN(bed))
			return [{ label: '시각을 넣어 주세요', value: '—' }];
		return wakeTimes(bed, this.fallAsleep).map((o, i) => ({
			label: `${o.cycles}주기 (${duration(o.sleep)} 수면)`,
			value: `${clock(o.time)}에 일어나기`,
			main: i === 1,
		}));
	}

	pick = (index: number) => (this.mode = index);
	setTime = (event: Event) => {
		const value = (event.target as HTMLInputElement).value;
		if (this.mode === 0) this.wake = value;
		else this.bed = value;
	};
	setFall = (value: number) => (this.fallAsleep = value);

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
						{{#if this.showTime}}
							<label
								class="krw-field"
							>
								<span
									class="krw-field-label"
								>{{this.timeLabel}}</span>
								<span
									class="krw-field-box"
								>
									<input
										type="time"
										value={{this.timeValue}}
										{{on
											"change"
											this.setTime
										}}
									/>
								</span>
							</label>
						{{/if}}
						<NumberField
							@label="잠드는 데 걸리는 시간"
							@value={{this.fallAsleep}}
							@unit="분"
							@onChange={{this.setFall}}
							@hint="보통 10~20분"
						/>
					</div>
				</CanonRows>
			</:sidebar>
			<:main>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="추천 시각" />
					<KrwResult @lines={{this.lines}} />
				</CanonRows>
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading
						@text="수면 주기 계산 방법"
					/>
					<div class="krw-guide">
						<p>
							잠은 얕은 잠, 깊은 잠,
							렘수면이 한 묶음으로
							되풀이되며, 한 묶음(수면
							주기)은 평균 약
							90분입니다. 깊은 잠
							도중에 알람이 울리면
							멍하고 피곤하기 쉬워서,
							주기가 끝나는 무렵에
							맞춰 일어나는 방법이
							널리 쓰입니다.
						</p>
						<ul>
							<li>
								일어날 시각으로:
								기상 시각 −
								(90분 × 주기 수)
								− 잠드는 시간 =
								누울 시각
							</li>
							<li>
								잠들 시각으로:
								누울 시각 +
								잠드는 시간 +
								(90분 × 주기 수)
								= 일어날 시각
							</li>
						</ul>
						<p>
							예를 들어 오전 7시에
							일어나야 하고 잠드는 데
							15분이 걸린다면,
							5주기(7시간 30분)를 자기
							위해 오후 11시 15분에
							누우면 됩니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>수면 주기는
								누구나
								90분인가요?</summary>
							<p>
								아닙니다.
								사람마다, 같은
								사람도 밤마다
								70~120분 정도로
								달라집니다.
								90분은
								평균값이라 이
								계산 결과는
								참고용으로 쓰고,
								며칠 해 보며
								자신에게 맞는
								시각을 찾아
								보세요.
							</p>
						</details>
						<details>
							<summary>몇 시간 자는 게
								좋나요?</summary>
							<p>
								미국수면재단은
								성인(18~64세)에게
								하루 7~9시간
								수면을
								권장합니다.
								5주기(7시간
								30분)나
								6주기(9시간)가
								이 범위에
								들어갑니다.
							</p>
						</details>
						<details>
							<summary>낮잠은 얼마나
								자는 게 좋나요?</summary>
							<p>
								깊은 잠에 들기
								전인 20분 안팎의
								짧은 낮잠이 깨고
								나서 덜
								멍합니다. 길게
								자려면 한
								주기(90분)를
								채우는 편이
								낫습니다.
							</p>
						</details>
						<p class="krw-source">
							이 계산기는 의학적
							진단을 대신하지
							않습니다. 불면이나 낮
							졸림이 계속되면 전문의와
							상담하세요.
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="sleep-calc" />
			</:end>
		</CanonSplit>
	</template>
}
