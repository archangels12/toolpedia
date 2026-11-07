// 부동산 중개보수(복비) 상한 계산
// 주택: 공인중개사법 시행규칙 제20조, 2021.10.19 개정 요율 (서울시 등 시·도 조례 같은 값)
// 오피스텔(전용 85㎡ 이하, 상·하수도·부엌·화장실 등 갖춤): 매매 0.5%, 임대차 0.4%
// 그 밖(토지·상가·위 조건 밖의 오피스텔): 0.9% 이내에서 협의

export type Deal = 'sale' | 'lease'; // 매매·교환 / 전세·월세
export type Property = 'house' | 'officetel' | 'other';

interface Band {
	/** 이 금액 미만까지 (원) */
	below: number;
	rate: number; // %
	/** 한도액 (원). 없으면 한도 없음 */
	cap?: number;
}

const EOK = 100000000;
const MAN = 10000;

const HOUSE_SALE: Band[] = [
	{ below: 5000 * MAN, rate: 0.6, cap: 25 * MAN },
	{ below: 2 * EOK, rate: 0.5, cap: 80 * MAN },
	{ below: 9 * EOK, rate: 0.4 },
	{ below: 12 * EOK, rate: 0.5 },
	{ below: 15 * EOK, rate: 0.6 },
	{ below: Infinity, rate: 0.7 },
];

const HOUSE_LEASE: Band[] = [
	{ below: 5000 * MAN, rate: 0.5, cap: 20 * MAN },
	{ below: 1 * EOK, rate: 0.4, cap: 30 * MAN },
	{ below: 6 * EOK, rate: 0.3 },
	{ below: 12 * EOK, rate: 0.4 },
	{ below: 15 * EOK, rate: 0.5 },
	{ below: Infinity, rate: 0.6 },
];

/** 월세 계약의 거래금액: 보증금 + 월세 × 100, 그 값이 5천만 원 미만이면 보증금 + 월세 × 70 */
export function leaseBase(deposit: number, monthlyRent: number): number {
	const base = deposit + monthlyRent * 100;
	return base < 5000 * MAN ? deposit + monthlyRent * 70 : base;
}

export interface BrokerageResult {
	/** 계산에 쓴 거래금액 */
	base: number;
	/** 상한요율 (%) */
	rate: number;
	/** 한도액 (없으면 undefined) */
	cap?: number;
	/** 중개보수 상한 (원 미만 버림, 부가세 별도) */
	fee: number;
	/** 부가세 10% (일반과세 중개사무소인 경우) */
	vat: number;
	/** '협의' 요율인지 (그 밖의 부동산) */
	negotiable: boolean;
}

export function brokerageFee(
	property: Property,
	deal: Deal,
	base: number,
): BrokerageResult {
	let band: Band;
	if (property === 'house') {
		const table = deal === 'sale' ? HOUSE_SALE : HOUSE_LEASE;
		band = table.find((b) => base < b.below)!;
	} else if (property === 'officetel') {
		band = { below: Infinity, rate: deal === 'sale' ? 0.5 : 0.4 };
	} else {
		band = { below: Infinity, rate: 0.9 };
	}
	const raw = Math.floor((base * band.rate) / 100);
	const fee = band.cap === undefined ? raw : Math.min(raw, band.cap);
	return {
		base,
		rate: band.rate,
		cap: band.cap,
		fee,
		vat: Math.floor(fee * 0.1),
		negotiable: property === 'other',
	};
}
