// 연봉 실수령액 = 월급 − 4대보험(근로자) − 소득세 − 지방소득세
import { insurance, type InsuranceResult } from './insurance.ts';
import { localTax, wageTax } from './wage-tax.ts';

export interface SalaryInput {
	/** 연봉 (비과세 포함, 퇴직금 제외) */
	annual: number;
	/** 월 비과세액 (식대 등) */
	taxFreeMonthly: number;
	/** 공제대상가족 수 (본인 포함) */
	family: number;
	/** 8세 이상 20세 이하 자녀 수 */
	children: number;
}

export interface SalaryResult {
	monthly: number;
	taxable: number;
	insurance: InsuranceResult;
	incomeTax: number;
	localTax: number;
	deductions: number;
	net: number;
	netAnnual: number;
}

export function salary(input: SalaryInput): SalaryResult {
	const monthly = Math.floor(input.annual / 12);
	const taxable = Math.max(0, monthly - input.taxFreeMonthly);
	const ins = insurance(taxable);
	const incomeTax = wageTax(taxable, input.family, input.children);
	const local = localTax(incomeTax);
	const deductions = ins.total + incomeTax + local;
	const net = monthly - deductions;
	return {
		monthly,
		taxable,
		insurance: ins,
		incomeTax,
		localTax: local,
		deductions,
		net,
		netAnnual: net * 12,
	};
}
