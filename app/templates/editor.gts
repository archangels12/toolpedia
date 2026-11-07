import { pageTitle } from 'ember-page-title';
import SubstrataEditor from 'delphitools-v2/components/substrata/editor';

// bypass application chrome
<template>
	{{pageTitle "이미지 편집기"}}

	<div class="sub-editor-viewport">
		<SubstrataEditor />
	</div>
</template>
