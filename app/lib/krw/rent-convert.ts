// 전월세 전환: 보증금 일부를 월세로 돌리거나, 월세를 보증금으로 돌릴 때
// 월세 = 전환할 보증금 × 전환율 ÷ 12
// 법정 상한 (주택임대차보호법 시행령 제9조): 연 10%와 "한국은행 기준금리 + 연 2%" 중 낮은 비율

// 한국은행 기준금리 (2026-10-22 금융통화위원회 결정). 바뀌면 이 값과 날짜를 고친다.
export const BASE_RATE = 3.0;
export const BASE_RATE_DATE = '2026년 10월 22일';

export const legalCap = (baseRate = BASE_RATE) => Math.min(10, baseRate + 2);

/** 보증금 → 월세 */
export function depositToRent(deposit: number, ratePercent: number): number {
	return Math.round((deposit * ratePercent) / 100 / 12);
}

/** 월세 → 보증금 */
export function rentToDeposit(rent: number, ratePercent: number): number {
	return ratePercent > 0
		? Math.round((rent * 12 * 100) / ratePercent)
		: 0;
}
