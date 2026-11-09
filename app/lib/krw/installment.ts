// 신용카드 할부 수수료: 원금은 개월 수로 똑같이 나눠 내고, 수수료는 남은 할부 잔액에 붙는다
// 회차 수수료 = 남은 잔액 × 연 수수료율 ÷ 12 (원 미만 버림). 마지막 회차에 남은 원금을 모두 낸다.
// 카드사는 실제 이용 일수(÷365)로 계산하기도 해서 몇십 원 차이가 날 수 있다.

export interface InstallmentRow {
	month: number;
	principal: number;
	fee: number;
	payment: number;
	balance: number;
}

export interface InstallmentResult {
	rows: InstallmentRow[];
	totalFee: number;
	totalPayment: number;
}

export function installment(
	amount: number,
	annualRatePercent: number,
	months: number,
): InstallmentResult {
	const rows: InstallmentRow[] = [];
	if (amount <= 0 || months <= 0)
		return { rows, totalFee: 0, totalPayment: 0 };
	const base = Math.floor(amount / months);
	let balance = amount;
	for (let month = 1; month <= months; month++) {
		const fee = Math.floor(
			(balance * annualRatePercent) / 100 / 12,
		);
		const principal = month === months ? balance : base;
		balance -= principal;
		rows.push({
			month,
			principal,
			fee,
			payment: principal + fee,
			balance,
		});
	}
	const totalFee = rows.reduce((s, r) => s + r.fee, 0);
	return { rows, totalFee, totalPayment: amount + totalFee };
}
