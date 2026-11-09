// 프리랜서 3.3% 원천징수 (사업소득): 소득세 3% + 지방소득세 0.3% (소득세의 10%)
// 각 세금은 10원 미만 절사. 지급액이 3만 3천 원 이하처럼 소득세가 1,000원 미만이면 떼지 않는다 (소액부징수).

import { floorTo } from './money.ts';

export interface FreelanceResult {
	gross: number; // 세전 지급액
	incomeTax: number;
	localTax: number;
	net: number; // 실제 받는 돈
}

export function freelanceTax(gross: number): FreelanceResult {
	let incomeTax = floorTo(gross * 0.03, 10);
	if (incomeTax < 1000) incomeTax = 0;
	const localTax = floorTo(incomeTax * 0.1, 10);
	return {
		gross,
		incomeTax,
		localTax,
		net: gross - incomeTax - localTax,
	};
}

/** 받고 싶은 실수령액에서 세전 지급액을 거꾸로 찾는다 */
export function grossFromNet(net: number): FreelanceResult {
	// 0.967로 나눈 값 근처에서 실수령액이 net 이상이 되는 가장 작은 세전 금액
	let gross = Math.max(Math.floor(net / 0.967) - 20, 0);
	while (freelanceTax(gross).net < net) gross++;
	return freelanceTax(gross);
}
