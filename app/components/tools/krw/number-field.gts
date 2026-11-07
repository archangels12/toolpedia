import Component from '@glimmer/component';
import { on } from '@ember/modifier';

interface Signature {
	Args: {
		label: string;
		value: number;
		unit: string;
		onChange: (value: number) => void;
		/** 소수점 입력 허용 (이자율 등) */
		decimal?: boolean;
		hint?: string;
	};
}

// 이자율·기간·일수 같은 쉼표 없는 숫자 입력칸
export default class NumberField extends Component<Signature> {
	// 처음 값만 넣는다. 입력 중인 "4." 같은 글자를 다시 쓰지 않도록 추적하지 않는다
	text = this.args.value ? String(this.args.value) : '';

	input = (event: Event) => {
		const el = event.target as HTMLInputElement;
		const pattern = this.args.decimal ? /[^\d.]/g : /[^\d]/g;
		const cleaned = el.value.replace(pattern, '');
		if (cleaned !== el.value) el.value = cleaned;
		const value = Number(cleaned);
		this.args.onChange(Number.isFinite(value) ? value : 0);
	};

	<template>
		<label class="krw-field">
			<span class="krw-field-label">{{@label}}</span>
			<span class="krw-field-box">
				<input
					type="text"
					inputmode={{if @decimal "decimal" "numeric"}}
					autocomplete="off"
					value={{this.text}}
					placeholder="0"
					{{on "input" this.input}}
				/>
				<span class="krw-field-unit">{{@unit}}</span>
			</span>
			{{#if @hint}}
				<span class="krw-field-note">{{@hint}}</span>
			{{/if}}
		</label>
	</template>
}
