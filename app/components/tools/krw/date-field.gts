import type { TOC } from '@ember/component/template-only';
import { on } from '@ember/modifier';

interface Signature {
	Args: {
		label: string;
		/** YYYY-MM-DD */
		value: string;
		onChange: (value: string) => void;
		hint?: string;
	};
}

const read = (fn: (value: string) => void) => (event: Event) =>
	fn((event.target as HTMLInputElement).value);

// 날짜 입력칸 (생활 계산기 공용)
const DateField: TOC<Signature> = <template>
	<label class="krw-field">
		<span class="krw-field-label">{{@label}}</span>
		<span class="krw-field-box">
			<input
				type="date"
				value={{@value}}
				{{on "change" (read @onChange)}}
			/>
		</span>
		{{#if @hint}}
			<span class="krw-field-note">{{@hint}}</span>
		{{/if}}
	</label>
</template>;

export default DateField;
