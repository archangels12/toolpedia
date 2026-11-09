import RouteTemplate from 'ember-route-template';
import { pageTitle } from 'ember-page-title';
import type { ComponentLike } from '@glint/template';

// PDF 편집기 컴포넌트는 routes/errata.ts 가 필요할 때 불러온다
export default RouteTemplate<{ Args: { model: ComponentLike<object> } }>(
	<template>
		{{pageTitle "PDF 편집기"}}

		<div class="sub-editor-viewport">
			<@model />
		</div>
	</template>,
);
