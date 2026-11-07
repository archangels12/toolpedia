import { LOCALE } from './locale';
import ko from './i18n/ko';

// 영어 원문을 키로 쓴다. 번역이 없으면 영어 그대로 보여준다.
// 템플릿에서: {{t "Home"}}
export function t(text: string): string {
	if (LOCALE === 'ko') return ko[text] ?? text;
	return text;
}
