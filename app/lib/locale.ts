// 언어는 주소로 정한다: /ko/... 는 한국어, 나머지는 영어.
// 라우터 rootURL을 /ko/ 로 바꾸면 기존 링크·이동 코드가 그대로 한국어 경로를 쓴다.
export type Locale = 'en' | 'ko';

export const LOCALES: Locale[] = ['en', 'ko'];

const KO_PATH = /^\/ko(\/|$)/;

export const LOCALE: Locale =
	typeof location !== 'undefined' && KO_PATH.test(location.pathname)
		? 'ko'
		: 'en';

export const ROOT_URL = LOCALE === 'ko' ? '/ko/' : '/';

export const isKo = LOCALE === 'ko';

// 같은 페이지의 다른 언어 주소 (언어 전환 링크용)
export function pathFor(locale: Locale, path: string): string {
	const bare = path.replace(KO_PATH, '/');
	return locale === 'ko' ? `/ko${bare === '/' ? '/' : bare}` : bare;
}
