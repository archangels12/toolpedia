import type { TOC } from '@ember/component/template-only';

export interface ResultLine {
	label: string;
	value: string;
	/** 결과의 핵심 줄 (크게) */
	main?: boolean;
	note?: string;
}

// 계산 결과 표: 맨 위 핵심 금액을 크게, 나머지는 줄로
const KrwResult: TOC<{ Args: { lines: ResultLine[] } }> = <template>
	<dl class="krw-result" aria-live="polite">
		{{#each @lines as |line|}}
			<div class="krw-result-line {{if line.main 'is-main'}}">
				<dt>{{line.label}}</dt>
				<dd>
					<span
						class="krw-result-value"
					>{{line.value}}</span>
					{{#if line.note}}<small
						>{{line.note}}</small>{{/if}}
				</dd>
			</div>
		{{/each}}
	</dl>
</template>;

export default KrwResult;
