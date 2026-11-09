import { module, test } from 'qunit';
import { recordingExtension } from 'delphitools-v2/lib/recording';

module('Unit | Lib | recording', function () {
	test('녹음 형식에 맞는 확장자', function (assert) {
		assert.strictEqual(
			recordingExtension('audio/webm;codecs=opus'),
			'.webm',
		);
		assert.strictEqual(
			recordingExtension('video/webm;codecs=vp9,opus'),
			'.webm',
		);
		assert.strictEqual(recordingExtension('audio/mp4'), '.m4a');
		assert.strictEqual(
			recordingExtension('video/mp4;codecs=avc1'),
			'.mp4',
		);
		assert.strictEqual(
			recordingExtension('audio/ogg;codecs=opus'),
			'.ogg',
		);
		assert.strictEqual(
			recordingExtension(''),
			'.webm',
			'형식을 모르면 webm',
		);
	});
});
