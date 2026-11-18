import Route from '@ember/routing/route';
import { service } from '@ember/service';
import type RouterService from '@ember/routing/router-service';
import { getGuide, type Guide } from 'delphitools-v2/lib/guides';

// 가이드 글 한 편: 없는 주소는 404로 보낸다
export default class GuideRoute extends Route<Guide> {
	@service declare router: RouterService;

	beforeModel() {
		const { slug } = this.paramsFor('guide') as { slug: string };
		if (!getGuide(slug))
			this.router.replaceWith('not-found', `guides/${slug}`);
	}

	model({ slug }: { slug: string }): Guide {
		return getGuide(slug)!;
	}
}
