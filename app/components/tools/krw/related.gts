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
</template>;

export default KrwRelated;
