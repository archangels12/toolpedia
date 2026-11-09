import RouteTemplate from 'ember-route-template';
import { pageTitle } from 'ember-page-title';
import type { ComponentLike } from '@glint/template';

// 편집기 컴포넌트는 routes/editor.ts 가 필요할 때 불러온다
export default RouteTemplate<{ Args: { model: ComponentLike<object> } }>(
	<template>
		{{pageTitle "이미지 편집기"}}

		<div class="sub-editor-viewport">
			<@model />
		</div>
	</template>,
);
