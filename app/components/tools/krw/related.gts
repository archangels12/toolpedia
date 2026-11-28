import type { TOC } from '@ember/component/template-only';
import { LinkTo } from '@ember/routing';
import CanonHeading from 'delphicanon/components/canon-heading';
import CanonRows from 'delphicanon/components/canon-rows';
import { getCategoryByToolId } from 'delphitools-v2/lib/tools';

// 계산기 카테고리 중 수학·그래프·시간 계산기는 빼고 돈 계산기끼리 잇는다
const NOT_MONEY = ['algebra-calc', 'graph-calc', 'sci-calc', 'time-calc'];

function related(current: string) {
	return (getCategoryByToolId(current)?.tools ?? []).filter(
		(tool) =>
			tool.id !== current &&
			tool.id.endsWith('-calc') &&
			!NOT_MONEY.includes(tool.id),
	);
}

// 같은 주제를 더 자세히 설명하는 모노테카(운영자의 금융 정보 사이트) 페이지.
// 금융 계산기 키워드는 모노테카가 맡기로 해서(2026-11-11), 결과 아래에서 설명 글로 잇는다.
const MONOTECA = 'https://monoteca.com';
const GUIDES: Record<string, { href: string; label: string }[]> = {
	'salary-calc': [
		{
			href: '/calc/salary/',
			label: '연봉별 실수령액 표 (2,000만~1억 원)',
		},
		{
			href: '/calc/year-end-tax/',
			label: '연말정산 예상 환급액 계산',
		},
	],
	'insurance-calc': [
		{ href: '/calc/salary/', label: '4대보험을 뺀 연봉 실수령액' },
	],
	'loan-calc': [
		{
			href: '/guide/loan-repayment-methods/',
			label: '대출 상환 방식 3가지 차이',
		},
		{
			href: '/guide/policy/didimdol/',
			label: '디딤돌대출 조건과 금리',
		},
		{
			href: '/guide/loan/withdrawal-right/',
			label: '대출 청약철회권 (14일 내 취소)',
		},
		{
			href: '/guide/loan/max-interest-rate/',
			label: '법정 최고금리 연 20%',
		},
	],
	'prepayment-calc': [
		{
			href: '/calc/prepayment-fee/',
			label: '대출일·상환일로 중도상환수수료 계산하기',
		},
		{
			href: '/guide/loan-repayment-methods/',
			label: '대출 상환 방식 3가지 차이',
		},
		{
			href: '/guide/loan/prepayment-fee/',
			label: '중도상환수수료',
		},
		{
			href: '/guide/loan/withdrawal-right/',
			label: '대출 청약철회권 (14일 내 취소)',
		},
	],
	'rent-convert-calc': [
		{ href: '/calc/jeonse-loan/', label: '전세대출 월 이자 계산' },
		{
			href: '/guide/policy/youth-jeonse-loan/',
			label: '청년전세대출 조건',
		},
		{
			href: '/guide/policy/beotimmok/',
			label: '버팀목전세자금대출 조건',
		},
		{
			href: '/guide/tax/jeonse-loan-deduction/',
			label: '전세대출 연말정산 공제',
		},
	],
	'savings-calc': [
		{
			href: '/calc/deposit/',
			label: '적금 이자가 예금의 절반인 이유',
		},
	],
};

const guides = (current: string) =>
	(GUIDES[current] ?? []).map((g) => ({ ...g, href: MONOTECA + g.href }));

// 한국형 계산기 페이지 아래 "관련 계산기" 링크 (사용자 이동·내부 링크)
const KrwRelated: TOC<{ Args: { current: string } }> = <template>
	<CanonRows @framed={{true}}>
		<CanonHeading @text="관련 계산기" />
		<ul class="krw-related">
			{{#each (related @current) as |tool|}}
				<li><LinkTo
						@route="tools.tool"
						@model={{tool.id}}
					>{{tool.name}}</LinkTo></li>
			{{/each}}
		</ul>
	</CanonRows>
	{{#let (guides @current) as |list|}}
		{{#if list.length}}
			<CanonRows @framed={{true}}>
				<CanonHeading
					@text="모노테카에서 더 알아보기"
				/>
				<ul class="krw-related">
					{{#each list as |g|}}
						<li><a
								href={{g.href}}
							>{{g.label}}</a></li>
					{{/each}}
				</ul>
			</CanonRows>
		{{/if}}
	{{/let}}
</template>;

export default KrwRelated;
