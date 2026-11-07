import EmberRouter from '@embroider/router';
import config from 'delphitools-v2/config/environment';
import { ROOT_URL } from 'delphitools-v2/lib/locale';

export default class Router extends EmberRouter {
	location = config.locationType;
	rootURL = ROOT_URL;
}

Router.map(function () {
	this.route('tools', function () {
		this.route('tool', { path: '/:tool_id' });
	});
	this.route('editor');
	this.route('errata');
	this.route('workflows');
	this.route('workflow', { path: '/w/:steps' });
	this.route('experiments');
	// 원작 UI 키트 문서(/canon)는 툴피디아에서 공개하지 않는다
	this.route('privacy');
	this.route('not-found', { path: '/*path' });
});
