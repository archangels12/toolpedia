import type { TOC } from '@ember/component/template-only';
import { segments } from 'delphitools-v2/lib/guides';

// 가이드 본문 한 줄: [글자](/주소) 를 링크로 그린다
const GuideText: TOC<{ Args: { text: string } }> = <template>
	{{#each (segments @text) as |s|}}{{#if s.href}}<a
				href={{s.href}}
			>{{s.text}}</a>{{else}}{{s.text}}{{/if}}{{/each}}
</template>;

export default GuideText;
