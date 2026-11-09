import Route from '@ember/routing/route';
import type { ComponentLike } from '@glint/template';

// 이미지 편집기 코드는 크므로 이 페이지에 들어올 때만 불러온다 (다른 페이지의 첫 로딩을 가볍게)
export default class EditorRoute extends Route<ComponentLike<object>> {
	async model() {
		return (
			await import('delphitools-v2/components/substrata/editor')
		).default as ComponentLike<object>;
	}
}
