import { pageTitle } from 'ember-page-title';
import ErrataShell from 'delphitools-v2/components/errata/errata-shell';

// bypass application chrome
<template>
	{{pageTitle "PDF 편집기"}}

	<div class="sub-editor-viewport">
		<ErrataShell />
	</div>
</template>
