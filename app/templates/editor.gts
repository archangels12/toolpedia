import RouteTemplate from 'ember-route-template';
import { pageTitle } from 'ember-page-title';
import type { ComponentLike } from '@glint/template';
import ToolGuide from 'delphitools-v2/components/tool-guide';
import { allTools } from 'delphitools-v2/lib/tools';

// 편집기 아래에 붙는 사용법(lib/tool-guides.ts)
const tool = allTools.find((t) => t.id === 'substrata')!;

// 편집기 컴포넌트는 routes/editor.ts 가 필요할 때 불러온다
export default RouteTemplate<{ Args: { model: ComponentLike<object> } }>(
	<template>
		{{pageTitle "이미지 편집기"}}

		<h1 class="dt-sr-only">{{tool.name}}</h1>
		<div class="sub-editor-viewport">
			<@model />
		</div>
		<ToolGuide @tool={{tool}} />
	</template>,
);
