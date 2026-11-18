import { pageTitle } from 'ember-page-title';
import { guides } from 'delphitools-v2/lib/guides';

// 가이드 목록
<template>
	{{pageTitle "가이드"}}

	<article class="tp-doc">
		<h1>가이드</h1>
		<p>
			사진 용량 줄이기, PDF 합치기, 파일 형식 바꾸기, 글자수
			맞추기처럼 자주 막히는 일을 해결하는 순서를
			정리했습니다. 글마다 바로 쓸 수 있는 툴피디아 도구를
			함께 안내합니다.
		</p>
		<ul class="tp-guide-list">
			{{#each guides as |guide|}}
				<li>
					<a
						href="/guides/{{guide.slug}}"
					>{{guide.title}}</a>
					<p>{{guide.description}}</p>
				</li>
			{{/each}}
		</ul>
	</article>
</template>
