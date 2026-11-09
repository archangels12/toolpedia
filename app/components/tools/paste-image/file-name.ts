export function extensionFor(type: string): string {
	const subtype = type.split('/')[1]?.replace(/\+.*$/, '') ?? 'png';
	return subtype === 'jpeg' ? 'jpg' : subtype;
}

export function downloadName(date: Date, type: string): string {
	return `toolpedia-capture-${date.toLocaleDateString('en-CA')}.${extensionFor(type)}`;
}
