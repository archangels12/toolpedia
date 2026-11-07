import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { comma, hangulWon, parseWon } from 'delphitools-v2/lib/krw/money';

interface Signature {
	Args: {
		label: string;
		value: number;
		onChange: (value: number) => void;
		/** 기본 "원". "개월", "%" 같은 단위도 쓴다 */
		unit?: string;
		/** 한글 금액(1억 2,000만원)을 아래에 보인다. 기본 켬 */
		hangul?: boolean;
		hint?: string;
	};
}

// 한국형 계산기 공용 입력칸: 입력하면서 천 단위 쉼표가 붙는다
export default class MoneyField extends Component<Signature> {
	get text() {
		return this.args.value ? comma(this.args.value) : '';
	}

	get showHangul() {
		return this.args.hangul !== false && this.args.value >= 10000;
	}

	get hangul() {
		return hangulWon(this.args.value);
	}

	input = (event: Event) => {
		const el = event.target as HTMLInputElement;
		const value = parseWon(el.value);
		el.value = value ? comma(value) : '';
		this.args.onChange(value);
	};

	<template>
		<label class="krw-field">
			<span class="krw-field-label">{{@label}}</span>
			<span class="krw-field-box">
				<input
					type="text"
					inputmode="numeric"
					autocomplete="off"
					value={{this.text}}
					placeholder="0"
					{{on "input" this.input}}
				/>
				<span class="krw-field-unit">{{if
						@unit
						@unit
						"원"
					}}</span>
			</span>
			{{#if this.showHangul}}
				<span
					class="krw-field-note"
				>{{this.hangul}}</span>
			{{else if @hint}}
				<span class="krw-field-note">{{@hint}}</span>
			{{/if}}
		</label>
	</template>
}
