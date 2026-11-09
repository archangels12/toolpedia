import RouteTemplate from 'ember-route-template';
import { pageTitle } from 'ember-page-title';
import ToolGrid from 'delphitools-v2/components/tool-grid';
import type { CategoryModel } from 'delphitools-v2/routes/category';

// 카테고리 모음 페이지: 소개 글 + 홈과 같은 도구 카드 목록
export default RouteTemplate<{ Args: { model: CategoryModel } }>(
	<template>
		{{pageTitle @model.page.heading}}

		<div class="tp-category">
			<header class="tp-doc tp-category-head">
				<h1>{{@model.page.heading}}</h1>
				{{#each @model.page.intro as |paragraph|}}
					<p>{{paragraph}}</p>
				{{/each}}
			</header>
			<ToolGrid @tools={{@model.category.tools}} />
		</div>
	</template>,
);
