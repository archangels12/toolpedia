import RouteTemplate from 'ember-route-template';
import { pageTitle } from 'ember-page-title';
import GuideText from 'delphitools-v2/components/guide-text';
import { allTools } from 'delphitools-v2/lib/tools';
import { blockOf, guides, koDate, type Guide } from 'delphitools-v2/lib/guides';

const toolsOf = (g: Guide) =>
	g.tools.map((id) => allTools.find((t) => t.id === id)).filter((t) => t);
const othersOf = (g: Guide) => guides.filter((o) => o.slug !== g.slug);

// 가이드 글 한 편
export default RouteTemplate<{ Args: { model: Guide } }>(
	<template>
		{{pageTitle @model.title}}

		<article class="tp-doc tp-article">
			<p class="tp-doc-meta"><a href="/guides">가이드</a></p>
			<h1>{{@model.title}}</h1>
			<p class="tp-doc-meta">
				업데이트
				<time datetime={{@model.updated}}>{{koDate
						@model.updated
					}}</time>
			</p>

			{{#each @model.intro as |paragraph|}}
				<p><GuideText @text={{paragraph}} /></p>
			{{/each}}

			{{#each @model.sections as |section|}}
				<h2>{{section.heading}}</h2>
				{{#each section.body as |raw|}}
					{{#let (blockOf raw) as |b|}}
						{{#if b.p}}
							<p><GuideText
									@text={{b.p}}
								/></p>
						{{else if b.ol}}
							<ol>
								{{#each
									b.ol
									as |item|
								}}
									<li
									><GuideText
											@text={{item}}
										/></li>
								{{/each}}
							</ol>
						{{else if b.ul}}
							<ul>
								{{#each
									b.ul
									as |item|
								}}
									<li
									><GuideText
											@text={{item}}
										/></li>
								{{/each}}
							</ul>
						{{else if b.note}}
							<p
								class="tp-article-note"
							><GuideText
									@text={{b.note}}
								/></p>
						{{else if b.table}}
							<div
								class="tp-article-table"
							>
								<table>
									<thead>
										<tr
										>
											{{#each
												b.table.head
												as |h|
											}}
												<th
													scope="col"
												>{{h}}</th>
											{{/each}}
										</tr>
									</thead>
									<tbody>
										{{#each
											b.table.rows
											as |row|
										}}
											<tr
											>
												{{#each
													row
													as |cell|
												}}
													<td
													>{{cell}}</td>
												{{/each}}
											</tr>
										{{/each}}
									</tbody>
								</table>
							</div>
						{{/if}}
					{{/let}}
				{{/each}}
			{{/each}}

			<h2>자주 묻는 질문</h2>
			{{#each @model.faq as |item|}}
				<h3>{{item.q}}</h3>
				<p>{{item.a}}</p>
			{{/each}}

			<h2>이 글에서 쓴 도구</h2>
			<ul class="tp-article-tools">
				{{#each (toolsOf @model) as |tool|}}
					<li>
						<a
							href={{tool.href}}
						>{{tool.name}}</a>
						<span
						>{{tool.description}}</span>
					</li>
				{{/each}}
			</ul>

			<h2>다른 가이드</h2>
			<ul>
				{{#each (othersOf @model) as |other|}}
					<li><a
							href="/guides/{{other.slug}}"
						>{{other.title}}</a></li>
				{{/each}}
			</ul>
		</article>
	</template>,
);
