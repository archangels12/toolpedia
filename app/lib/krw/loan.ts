// 대출 상환 계산: 원리금균등 · 원금균등 · 만기일시
// 월 이자 = 남은 원금 × 연이율 ÷ 12 (원 미만 반올림). 마지막 회차에서 남은 원금을 모두 갚는다.

export type LoanMethod = 'equal-payment' | 'equal-principal' | 'bullet';

export interface LoanRow {
	month: number;
	payment: number; // 상환금 (원금 + 이자)
	principal: number;
	interest: number;
	balance: number; // 상환 후 남은 원금
}

export interface LoanResult {
	rows: LoanRow[];
	totalInterest: number;
	totalPayment: number;
	firstPayment: number;
}

export function loanSchedule(
	amount: number,
	annualRatePercent: number,
	months: number,
	method: LoanMethod,
): LoanResult {
	const rows: LoanRow[] = [];
	if (amount <= 0 || months <= 0)
		return { rows, totalInterest: 0, totalPayment: 0, firstPayment: 0 };

	const i = annualRatePercent / 100 / 12;
	// 원리금균등: 매달 같은 금액 = P·i·(1+i)^n / ((1+i)^n − 1)
	const level =
		i === 0
			? amount / months
			: (amount * i * (1 + i) ** months) / ((1 + i) ** months - 1);

	let balance = amount;
	for (let month = 1; month <= months; month++) {
		const interest = Math.round(balance * i);
		let principal: number;
		if (month === months) principal = balance;
		else if (method === 'equal-payment')
			principal = Math.round(level) - interest;
		else if (method === 'equal-principal')
			principal = Math.round(amount / months);
		else principal = 0;
		balance -= principal;
		rows.push({
			month,
			payment: principal + interest,
			principal,
			interest,
			balance,
		});
	}

	const totalInterest = rows.reduce((sum, row) => sum + row.interest, 0);
	return {
		rows,
		totalInterest,
		totalPayment: amount + totalInterest,
		firstPayment: rows[0]!.payment,
	};
}
