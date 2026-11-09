// 녹음·녹화 형식 고르기와 저장 확장자.
// 브라우저마다 녹음 가능한 형식이 다르다 (예: Safari는 WebM 대신 MP4만 되는 버전이 있다).

/** 후보 중 이 브라우저가 녹음할 수 있는 첫 형식. 없으면 undefined(브라우저 기본 형식) */
export function pickMimeType(candidates: string[]): string | undefined {
	return candidates.find((type) => {
		try {
			return MediaRecorder.isTypeSupported(type);
		} catch {
			return false;
		}
	});
}

/** 실제 녹음된 Blob 형식에 맞는 확장자 (점 포함) */
export function recordingExtension(type: string): string {
	const base = type.split(';')[0]!.trim().toLowerCase();
	if (base === 'audio/mp4' || base === 'audio/x-m4a') return '.m4a';
	if (base.endsWith('/mp4')) return '.mp4';
	if (base.endsWith('/ogg')) return '.ogg';
	return '.webm';
}
