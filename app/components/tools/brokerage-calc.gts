import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import CanonSegmented from 'delphicanon/components/canon-segmented';
import CanonSplit from 'delphicanon/components/canon-split';
import MoneyField from 'delphitools-v2/components/tools/krw/money-field';
import KrwResult, {
	type ResultLine,
} from 'delphitools-v2/components/tools/krw/result';
import { won } from 'delphitools-v2/lib/krw/money';
import {
	brokerageFee,
	leaseBase,
	type Property,
} from 'delphitools-v2/lib/krw/brokerage';
import KrwRelated from 'delphitools-v2/components/tools/krw/related';
import './krw/krw.css';

const properties: Property[] = ['house', 'officetel', 'other'];
const propertyNames = ['주택', '오피스텔', '토지·상가 등'];
const dealNames = ['매매·교환', '전세', '월세'];

export default class BrokerageCalc extends Component {
	@tracked property = 0;
	@tracked deal = 0;
	@tracked price = 500000000;
	@tracked deposit = 10000000;
	@tracked rent = 500000;

	get isSale() {
		return this.deal === 0;
	}

	get isMonthly() {
		return this.deal === 2;
	}

	get base() {
		if (this.isMonthly) return leaseBase(this.deposit, this.rent);
		return this.price;
	}

	get priceLabel() {
		return this.isSale ? '매매가' : '전세 보증금';
	}

	get result() {
		return brokerageFee(
			properties[this.property]!,
			this.isSale ? 'sale' : 'lease',
			this.base,
		);
	}

	get lines(): ResultLine[] {
		const r = this.result;
		const lines: ResultLine[] = [
			{
				label: '중개보수 상한 (부가세 별도)',
				value: won(r.fee),
				main: true,
				note: r.negotiable
					? '0.9% 이내에서 중개사와 협의해요'
					: undefined,
			},
			{
				label: '부가세 포함',
				value: won(r.fee + r.vat),
				note: '일반과세 중개사무소인 경우',
			},
			{ label: '상한요율', value: `${r.rate}%` },
		];
		if (r.cap !== undefined)
			lines.push({ label: '한도액', value: won(r.cap) });
		lines.push({
			label: '계산 기준 거래금액',
			value: won(r.base),
			note: this.isMonthly
				? '보증금 + 월세 × 100 (5천만 원 미만이면 × 70)'
				: undefined,
		});
		return lines;
	}

	pickProperty = (index: number) => (this.property = index);
	pickDeal = (index: number) => (this.deal = index);
	setPrice = (value: number) => (this.price = value);
	setDeposit = (value: number) => (this.deposit = value);
	setRent = (value: number) => (this.rent = value);

	<template>
		<CanonSplit>
			<:sidebar>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="거래 정보" />
					<div class="krw-form">
						<div class="krw-choice">
							<span
								class="krw-field-label"
							>부동산 종류</span>
							<CanonSegmented
								aria-label="부동산 종류"
								@items={{propertyNames}}
								@selected={{this.property}}
								@onChange={{this.pickProperty}}
							/>
						</div>
						<div class="krw-choice">
							<span
								class="krw-field-label"
							>거래 종류</span>
							<CanonSegmented
								aria-label="거래 종류"
								@items={{dealNames}}
								@selected={{this.deal}}
								@onChange={{this.pickDeal}}
							/>
						</div>
						{{#if this.isMonthly}}
							<MoneyField
								@label="보증금"
								@value={{this.deposit}}
								@onChange={{this.setDeposit}}
							/>
							<MoneyField
								@label="월세"
								@value={{this.rent}}
								@onChange={{this.setRent}}
							/>
						{{else}}
							<MoneyField
								@label={{this.priceLabel}}
								@value={{this.price}}
								@onChange={{this.setPrice}}
							/>
						{{/if}}
					</div>
				</CanonRows>
			</:sidebar>
			<:main>
				<CanonRows @framed={{true}}>
					<CanonHeading @text="계산 결과" />
					<KrwResult @lines={{this.lines}} />
				</CanonRows>
			</:main>
			<:end>
				<CanonRows @framed={{true}}>
					<CanonHeading
						@text="주택 중개보수 요율표"
					/>
					<div class="krw-guide">
						<div class="krw-table-wrap">
							<table
								class="krw-table"
							>
								<thead>
									<tr><th
										>매매·교환
											거래금액</th><th
										>상한요율</th><th
										>한도액</th></tr>
								</thead>
								<tbody>
									<tr><td
										>5천만
											원
											미만</td><td
										>0.6%</td><td
										>25만
											원</td></tr>
									<tr><td
										>5천만~2억
											원
											미만</td><td
										>0.5%</td><td
										>80만
											원</td></tr>
									<tr><td
										>2억~9억
											원
											미만</td><td
										>0.4%</td><td
										>없음</td></tr>
									<tr><td
										>9억~12억
											원
											미만</td><td
										>0.5%</td><td
										>없음</td></tr>
									<tr><td
										>12억~15억
											원
											미만</td><td
										>0.6%</td><td
										>없음</td></tr>
									<tr><td
										>15억
											원
											이상</td><td
										>0.7%</td><td
										>없음</td></tr>
								</tbody>
							</table>
						</div>
						<div class="krw-table-wrap">
							<table
								class="krw-table"
							>
								<thead>
									<tr><th
										>전세·월세
											거래금액</th><th
										>상한요율</th><th
										>한도액</th></tr>
								</thead>
								<tbody>
									<tr><td
										>5천만
											원
											미만</td><td
										>0.5%</td><td
										>20만
											원</td></tr>
									<tr><td
										>5천만~1억
											원
											미만</td><td
										>0.4%</td><td
										>30만
											원</td></tr>
									<tr><td
										>1억~6억
											원
											미만</td><td
										>0.3%</td><td
										>없음</td></tr>
									<tr><td
										>6억~12억
											원
											미만</td><td
										>0.4%</td><td
										>없음</td></tr>
									<tr><td
										>12억~15억
											원
											미만</td><td
										>0.5%</td><td
										>없음</td></tr>
									<tr><td
										>15억
											원
											이상</td><td
										>0.6%</td><td
										>없음</td></tr>
								</tbody>
							</table>
						</div>
						<p>
							중개보수 = 거래금액 ×
							상한요율이며, 한도액이
							있으면 그 금액을 넘지
							못합니다. 오피스텔(전용
							85㎡ 이하, 부엌·화장실
							등을 갖춘 경우)은 매매
							0.5%, 임대차 0.4%이고,
							토지·상가 등은 0.9%
							이내에서 협의합니다.
						</p>

						<h3>자주 묻는 질문</h3>
						<details>
							<summary>계산 결과대로
								꼭 내야 하나요?</summary>
							<p>
								아니요. 결과는
								법이 정한 최대
								금액(상한)입니다.
								실제 중개보수는
								이 금액 안에서
								중개사와 협의해
								정합니다.
							</p>
						</details>
						<details>
							<summary>월세는 어떻게
								계산하나요?</summary>
							<p>
								보증금에 월세의
								100배를 더한
								금액을
								거래금액으로
								봅니다. 그 합이
								5천만 원
								미만이면 월세에
								70배를 곱해 다시
								더합니다.
							</p>
						</details>
						<details>
							<summary>부가세도 따로
								내나요?</summary>
							<p>
								중개사무소가
								일반과세자라면
								중개보수의 10%를
								부가세로 따로
								냅니다.
								간이과세자는
								세율이 다르니
								계약 전에
								확인하세요.
							</p>
						</details>
						<p class="krw-source">
							근거: 공인중개사법
							제32조, 같은 법 시행규칙
							제20조, 시·도 중개보수
							조례. 지역 조례에 따라
							다를 수 있으니 계약 전
							확인하세요.
						</p>
					</div>
				</CanonRows>
				<KrwRelated @current="brokerage-calc" />
			</:end>
		</CanonSplit>
	</template>
}
