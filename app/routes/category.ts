import Route from '@ember/routing/route';
import { service } from '@ember/service';
import type RouterService from '@ember/routing/router-service';
import { toolCategories, type ToolCategory } from 'delphitools-v2/lib/tools';
import {
	categoryPages,
	type CategoryPage,
} from 'delphitools-v2/lib/category-pages';

export interface CategoryModel {
	category: ToolCategory;
	page: CategoryPage;
}

// 카테고리 모음 페이지: 소개 글이 있는 카테고리만 연다
export default class CategoryRoute extends Route<CategoryModel> {
	@service declare router: RouterService;

	beforeModel() {
		const { category_id: id } = this.paramsFor('category') as {
			category_id: string;
		};
		if (!categoryPages[id])
			this.router.replaceWith('not-found', `category/${id}`);
	}

	model({ category_id: id }: { category_id: string }): CategoryModel {
		return {
			category: toolCategories.find((c) => c.id === id)!,
			page: categoryPages[id]!,
		};
	}
}
