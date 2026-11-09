import { pageTitle } from 'ember-page-title';
import { LinkTo } from '@ember/routing';

// 사이트 소개 (2026-11-09). 사업자등록 후 운영자 표기를 바꾼다.
<template>
	{{pageTitle "툴피디아 소개"}}

	<article class="tp-doc">
		<h1>툴피디아 소개</h1>

		<p>
			툴피디아(toolpedia.app)는
			이미지·PDF·영상·글·색상·개발·계산기까지 일상과 업무에
			자주 필요한 도구 100여 가지를 한곳에 모은 무료 온라인
			도구 모음입니다. 회원가입이나 프로그램 설치 없이
			브라우저에서 바로 쓸 수 있습니다.
		</p>

		<h2>파일은 내 기기 밖으로 나가지 않습니다</h2>
		<p>
			사진 용량 줄이기, PDF 편집처럼 파일을 다루는 도구는 모두
			이용자의 브라우저 안에서 처리합니다. 파일을 사이트
			서버로 올리지 않기 때문에 개인 사진이나 업무 문서도
			안심하고 쓸 수 있습니다. 자세한 내용은
			<LinkTo @route="privacy">개인정보처리방침</LinkTo>에
			있습니다.
		</p>

		<h2>한국 기준으로 만든 계산기</h2>
		<p>
			연봉 실수령액, 4대보험, 대출 이자, 예적금 이자, 전월세
			전환, 주휴수당처럼 한국 법령과 요율을 따르는 계산기를
			제공합니다. 각 계산기 페이지에 계산 방법과 근거 법령을
			함께 적어 두었습니다. 계산 결과는 참고용이며, 실제
			금액은 금융회사·기관의 안내를 확인해 주세요.
		</p>

		<h2>운영 방식</h2>
		<p>
			툴피디아는 모든 도구를 무료로 제공하고, 사이트에
			표시되는 광고 수익으로 운영합니다. 특정 금융상품을
			추천하거나 가입을 중개하지 않습니다.
		</p>
		<p>
			툴피디아는 공개 소스 프로젝트 delphitools를 바탕으로
			한국어 사용자에 맞게 고쳐 만들었으며, 소스 코드는
			<a
				href="https://github.com/archangels12/toolpedia"
				target="_blank"
				rel="noopener noreferrer"
			>GitHub</a>에 공개되어 있습니다.
		</p>

		<h2>운영자</h2>
		<p>
			툴피디아 운영자<br />
			문의:
			<LinkTo @route="contact">문의하기</LinkTo>
		</p>
	</article>
</template>
