/** A bitmap of any image the browser can show, svg included: createImageBitmap rejects svg blobs, a sized <img> does not. */
export async function decodeImage(file: Blob): Promise<ImageBitmap> {
	const url = URL.createObjectURL(await displayable(file));
	try {
		const img = new Image();
		img.src = url;
		await img.decode();
		return await createImageBitmap(img, {
			imageOrientation: 'from-image',
		});
	} finally {
		URL.revokeObjectURL(url);
	}
}

// 아이폰 사진(HEIC)은 Safari만 직접 열 수 있다. 크롬·엣지에서는 PNG로 풀어서 쓴다.
// 변환기(heic-to, 약 3MB)는 HEIC 파일이 들어왔을 때만 내려받는다.
export const HEIC_ACCEPT = '.heic,.heif';

const converted = new WeakMap<Blob, Promise<Blob>>();

export async function isHeic(file: Blob): Promise<boolean> {
	if (/^image\/hei[cf]/.test(file.type)) return true;
	if ('name' in file && /\.hei[cf]$/i.test(String(file.name)))
		return true;
	// ISO 미디어 파일 머리: 4~8바이트 'ftyp', 8~12바이트 브랜드
	const head = new TextDecoder().decode(
		await file.slice(4, 12).arrayBuffer(),
	);
	return /^ftyp(heic|heix|hevc|hevx|heim|heis|mif1|msf1)$/.test(head);
}

async function canShow(file: Blob): Promise<boolean> {
	const url = URL.createObjectURL(file);
	try {
		const img = new Image();
		img.src = url;
		await img.decode();
		return true;
	} catch {
		return false;
	} finally {
		URL.revokeObjectURL(url);
	}
}

/** 브라우저가 <img>로 보여 줄 수 있는 파일. HEIC를 못 여는 브라우저에서는 PNG로 바꾼 것을 돌려준다. */
export function displayable(file: Blob): Promise<Blob> {
	let found = converted.get(file);
	if (!found) {
		found = (async () => {
			if (!(await isHeic(file)) || (await canShow(file)))
				return file;
			const { heicTo } = await import('heic-to');
			return heicTo({ blob: file, type: 'image/png' });
		})();
		converted.set(file, found);
	}
	return found;
}
