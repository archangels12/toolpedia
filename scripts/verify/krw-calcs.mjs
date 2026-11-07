// 한국형 계산기 계산 로직 검사 (브라우저 없이 실행): node scripts/verify/krw-calcs.mjs
// 요율·세액표를 바꾼 뒤에는 기대값을 공식 예시로 다시 확인하고 고친다.
import { fromTotal } from '../../app/lib/krw/vat.ts';
import { loanSchedule } from '../../app/lib/krw/loan.ts';
import { severancePay } from '../../app/lib/krw/severance.ts';
import { brokerageFee, leaseBase } from '../../app/lib/krw/brokerage.ts';
import { insurance } from '../../app/lib/krw/insurance.ts';
import { wageTax } from '../../app/lib/krw/wage-tax.ts';
import { salary } from '../../app/lib/krw/salary.ts';

let failed = 0;
const check = (name, got, want) => {
	const ok = got === want;
	if (!ok) failed++;
	console.log(`${ok ? '통과' : '실패'} ${name}: ${got}${ok ? '' : ` (기대 ${want})`}`);
};

check('부가세: 합계 1만 원의 부가세', fromTotal(10000).vat, 909);
check(
	'대출: 1억 원 연 5% 30년 원리금균등 월 상환금',
	loanSchedule(100000000, 5, 360, 'equal-payment').firstPayment,
	536822,
);
check(
	'퇴직금: 3년(1,096일) 월 300만 원',
	severancePay({
		start: '2023-11-01',
		end: '2026-11-01',
		threeMonthPay: 9000000,
		yearlyBonus: 0,
		yearlyLeavePay: 0,
	}).severance,
	8812388,
);
check('복비: 주택 매매 5억 원', brokerageFee('house', 'sale', 500000000).fee, 2000000);
check(
	'복비: 보증금 500만 원·월세 30만 원',
	brokerageFee('house', 'lease', leaseBase(5000000, 300000)).fee,
	130000,
);
// 4대사회보험 정보연계센터 모의계산 공식 예시 (보수월액 200만 원)
check('건강보험: 보수 200만 원 (공식 예시)', insurance(2000000).health, 71900);
check('장기요양: 보수 200만 원 (공식 예시)', insurance(2000000).care, 9440);
// 홈택스 근로소득 간이세액표 안내 예시
check('소득세: 월 350만 원·4인·자녀 2명 (국세청 예시)', wageTax(3500000, 4, 2), 3510);
check(
	'연봉 실수령: 5천만 원·식대 20만 원·1인',
	salary({ annual: 50000000, taxFreeMonthly: 200000, family: 1, children: 0 }).net,
	3571586,
);

if (failed) {
	console.log(`${failed}건 실패`);
	process.exit(1);
}
console.log('모두 통과');
