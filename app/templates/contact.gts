import { pageTitle } from 'ember-page-title';

// 문의 (2026-11-09). 문의 창구는 개인정보처리방침의 이메일과 같다.
<template>
	{{pageTitle "문의하기"}}

	<article class="tp-doc">
		<h1>문의하기</h1>

		<p>
			도구 오류 제보, 새 도구 제안, 계산기 요율 정정,
			광고·제휴 문의는 이메일로 보내 주세요.
		</p>
		<p>
			이메일:
			<a
				href="mailto:support@toolpedia.app"
			>support@toolpedia.app</a>
		</p>

		<h2>오류를 제보할 때</h2>
		<ul>
			<li>도구 이름 또는 페이지 주소</li>
			<li>사용한 기기와 브라우저 (예: 아이폰 Safari, 윈도우
				Chrome)</li>
			<li>어떤 순서로 무엇을 했을 때 문제가 생겼는지</li>
			<li>
				가능하면 화면 캡처. 개인정보가 담긴 파일 원본은
				보내지 마세요.
			</li>
		</ul>

		<h2>계산기 내용 정정</h2>
		<p>
			세율·요율·법령이 바뀌었거나 계산 결과가 공식 자료와
			다르면, 근거가 되는 자료(기관 안내 페이지 주소 등)와
			함께 알려 주세요. 확인한 뒤 반영합니다.
		</p>
	</article>
</template>
