// 한국형 계산기 계산 로직 검사 (브라우저 없이 실행): node scripts/verify/krw-calcs.mjs
// 요율·세액표를 바꾼 뒤에는 기대값을 공식 예시로 다시 확인하고 고친다.
import { fromTotal } from '../../app/lib/krw/vat.ts';
import { loanSchedule } from '../../app/lib/krw/loan.ts';
import { severancePay } from '../../app/lib/krw/severance.ts';
import { brokerageFee, leaseBase } from '../../app/lib/krw/brokerage.ts';
import { insurance } from '../../app/lib/krw/insurance.ts';
import { wageTax } from '../../app/lib/krw/wage-tax.ts';
import { salary } from '../../app/lib/krw/salary.ts';
import { savings } from '../../app/lib/krw/savings.ts';
import { prepaymentFee } from '../../app/lib/krw/prepayment.ts';
import { compound } from '../../app/lib/krw/compound.ts';
import { depositToRent, rentToDeposit, legalCap } from '../../app/lib/krw/rent-convert.ts';
import { averagePrice, investReturn } from '../../app/lib/krw/invest.ts';
import { installment } from '../../app/lib/krw/installment.ts';
import { freelanceTax, grossFromNet } from '../../app/lib/krw/freelance.ts';
import { holidayPay } from '../../app/lib/krw/holiday-pay.ts';

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

// 손으로 계산한 값: 1,000만 원 × 3% = 30만 원, 소득세 42,000 + 지방소득세 4,200
check(
	'예금: 1천만 원 연 3% 1년 단리 세후 이자',
	savings('deposit', 10000000, 3, 12, 'simple', 'normal').afterTaxInterest,
	253800,
);
// 10만 원 × 0.25% × 78(=12×13÷2) = 19,500, 소득세 2,730 + 지방소득세 270
check(
	'적금: 월 10만 원 연 3% 12개월 단리 세후 이자',
	savings('installment', 100000, 3, 12, 'simple', 'normal').afterTaxInterest,
	16500,
);
check('중도상환: 1억 1.2% 3년 중 1년 경과', prepaymentFee(100000000, 1.2, 365, 1095).fee, 800000);
check('복리: 1천만 원 연 7% 10년 (1.07^10)', compound(10000000, 0, 7, 10).value, 19671514);
check('전환율 상한: 기준금리 3% → 5%', legalCap(3), 5);
check('전월세: 보증금 1억 5% → 월세', depositToRent(100000000, 5), 416667);
check('전월세: 월세 50만 원 5% → 보증금', rentToDeposit(500000, 5), 120000000);
check(
	'평단: 1만 원 10주 + 8천 원 10주',
	averagePrice([
		{ price: 10000, quantity: 10 },
		{ price: 8000, quantity: 10 },
	]).average,
	9000,
);
check('CAGR: 10년에 2배 (%)', investReturn(1000, 2000, 10).cagrPercent.toFixed(2), '7.18');
check('할부: 120만 원 3개월 연 12% 총 수수료', installment(1200000, 12, 3).totalFee, 24000);
check('3.3%: 100만 원 실수령', freelanceTax(1000000).net, 967000);
// 10원 미만 절사 때문에 세전 999,980원~1,000,000원이 모두 실수령 967,000원. 가장 작은 금액을 고른다
check('3.3%: 실수령 96만 7천 원 역산', grossFromNet(967000).gross, 999980);
check('3.3%: 역산 금액의 실수령', grossFromNet(1234567).net, 1234567);
check('3.3%: 3만 원은 소액부징수', freelanceTax(30000).net, 30000);
check('주휴수당: 최저임금 주 40시간', holidayPay(10320, 40).holidayPay, 82560);
// 고용노동부 고시 월 환산액 (209시간)
check('최저임금 월 환산 (2026 고시)', holidayPay(10320, 40).monthlyPay, 2156880);
check('주휴수당: 주 14시간은 없음', holidayPay(10320, 14).holidayPay, 0);

if (failed) {
	console.log(`${failed}건 실패`);
	process.exit(1);
}
console.log('모두 통과');
