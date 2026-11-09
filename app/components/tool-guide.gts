import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import type { TOC } from '@ember/component/template-only';
import { modifier } from 'ember-modifier';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import { toolGuides, type ToolGuideData } from 'delphitools-v2/lib/tool-guides';
import type { Tool } from 'delphitools-v2/lib/tools';
import './tool-guide.css';

const GuideBody: TOC<{ Args: { name: string; guide: ToolGuideData } }> =
	<template>
		<CanonRows @framed={{true}}>
			<CanonHeading @text="{{@name}} 사용법" />
			<div class="tp-guide">
				<p>{{@guide.intro}}</p>
				<ol>
					{{#each @guide.steps as |step|}}
						<li>{{step}}</li>
					{{/each}}
				</ol>
				{{#if @guide.tips}}
					<h3>알아 두면 좋은 점</h3>
					<ul>
						{{#each @guide.tips as |tip|}}
							<li>{{tip}}</li>
						{{/each}}
					</ul>
				{{/if}}
				<h3>자주 묻는 질문</h3>
				{{#each @guide.faq as |item|}}
					<details>
						<summary>{{item.q}}</summary>
						<p>{{item.a}}</p>
					</details>
				{{/each}}
			</div>
		</CanonRows>
	</template>;

interface Signature {
	Args: { tool: Tool };
}

// 도구 사용법·FAQ: 도구 화면 아래(.canon-split-end, 계산기 설명이 들어가는 자리)에 붙인다.
// 그 자리가 없는 도구는 도구 화면 바로 아래에 보인다. 내용은 lib/tool-guides.ts
export default class ToolGuide extends Component<Signature> {
	// 자리를 찾은 도구 id. 다른 도구로 옮기면 이전 자리는 쓰지 않는다
	@tracked found: { id: string; target: Element | null } | null = null;

	get guide() {
		return toolGuides[this.args.tool.id];
	}

	get target() {
		return this.found?.id === this.args.tool.id
			? this.found.target
			: null;
	}

	get looked() {
		return this.found?.id === this.args.tool.id;
	}

	// 도구 화면이 그려진 뒤 설명을 넣을 자리를 찾는다. 도구가 바뀌면(id) 다시 찾는다
	find = modifier((anchor: HTMLElement, [id]: [string]) => {
		let tries = 0;
		let frame = 0;
		const look = () => {
			const end = anchor
				.closest('.dt-main')
				?.querySelector(
					'.dt-canon-tool .canon-split-end',
				);
			if (end || tries++ > 20) {
				this.found = { id, target: end ?? null };
				return;
			}
			frame = requestAnimationFrame(look);
		};
		frame = requestAnimationFrame(look);
		return () => cancelAnimationFrame(frame);
	});

	<template>
		{{#if this.guide}}
			<span hidden {{this.find @tool.id}}></span>
			{{#if this.target}}
				{{#in-element this.target insertBefore=null}}
					<GuideBody
						@name={{@tool.name}}
						@guide={{this.guide}}
					/>
				{{/in-element}}
			{{else if this.looked}}
				<div class="tp-guide-fallback">
					<GuideBody
						@name={{@tool.name}}
						@guide={{this.guide}}
					/>
				</div>
			{{/if}}
		{{/if}}
	</template>
}
