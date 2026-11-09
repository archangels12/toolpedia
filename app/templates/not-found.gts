import { pageTitle } from 'ember-page-title';
import { LinkTo } from '@ember/routing';

// 없는 주소: 다른 페이지처럼 메뉴 옆에 안내를 보여 메뉴·검색으로 이어가게 한다
<template>
	{{pageTitle "페이지를 찾을 수 없어요"}}

	<article class="tp-doc tp-404">
		<h1>페이지를 찾을 수 없어요</h1>
		<p>
			주소가 바뀌었거나 없는 페이지입니다. 왼쪽 메뉴나 메뉴 맨
			위의 도구 검색(⌘K)으로 찾는 도구를 열어 보세요.
		</p>
		<p><LinkTo @route="index">홈으로 가기</LinkTo></p>

		<h2>많이 찾는 도구</h2>
		<ul>
			<li><a href="/tools/image-compressor">이미지 용량 줄이기</a></li>
			<li><a href="/tools/qr-genny">QR코드 만들기</a></li>
			<li><a href="/tools/salary-calc">연봉 실수령액 계산기</a></li>
			<li><a href="/tools/loan-calc">대출이자 계산기</a></li>
			<li><a href="/tools/word-counter">글자수 세기</a></li>
		</ul>
	</article>
</template>
