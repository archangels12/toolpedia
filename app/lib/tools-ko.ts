// 한국어판(/ko/)에 공개할 도구와 그 한국어 이름·설명.
// 여기에 있는 도구만 한국어판 메뉴·검색·사이트맵에 나온다.
// 새 도구를 한국어판에 추가하려면 이 목록에 한 줄을 넣고, 도구 화면 문구를 i18n/ko.ts 에 번역한다.
export interface ToolKo {
	name: string;
	description: string;
	keywords?: string[];
}

export const toolsKo: Record<string, ToolKo> = {
	// 이미지
	'image-compressor': {
		name: '이미지 용량 줄이기',
		description: 'JPG·PNG·WebP·AVIF 사진 용량을 화질 손실 없이 줄입니다',
		keywords: ['이미지 압축', '사진 용량', 'jpg 압축'],
	},
	'image-converter': {
		name: '이미지 변환',
		description: 'PNG·JPG·WebP·GIF·ICO 등 이미지 형식 변환과 크기 조절',
		keywords: ['jpg png 변환', 'webp 변환', '확장자 변환'],
	},
	'background-remover': {
		name: '배경 제거',
		description: '사진 배경을 자동으로 지워 누끼를 땁니다',
		keywords: ['누끼', '배경 지우기', '투명 배경'],
	},
	'social-cropper': {
		name: 'SNS 이미지 자르기',
		description: '인스타그램·스레드 비율에 맞게 사진을 자릅니다',
		keywords: ['인스타 사진 자르기', '피드 비율'],
	},
	watermarker: {
		name: '워터마크 넣기',
		description: '이미지에 글자·로고 워터마크를 넣습니다',
		keywords: ['워터마크', '사진 도용 방지'],
	},
	'image-splitter': {
		name: '이미지 분할',
		description: '이미지 한 장을 여러 조각으로 나눕니다',
		keywords: ['사진 나누기', '인스타 분할'],
	},
	'image-stitcher': {
		name: '이미지 합치기',
		description: '여러 장의 이미지를 한 장으로 이어 붙입니다',
		keywords: ['사진 합치기', '이미지 이어붙이기'],
	},
	'metadata-stripper': {
		name: '사진 위치정보 삭제',
		description: '사진 속 EXIF·GPS 정보를 지워 개인정보를 보호합니다',
		keywords: ['exif 삭제', '메타데이터 제거'],
	},
	'favicon-genny': {
		name: '파비콘 만들기',
		description: '이미지 한 장으로 웹사이트 파비콘을 만듭니다',
		keywords: ['favicon', '파비콘 생성'],
	},
	'palette-extractor': {
		name: '이미지 색상 추출',
		description: '사진에서 색상 팔레트를 뽑아냅니다',
		keywords: ['컬러 추출', '색상 코드'],
	},
	// PDF
	'pdf-organiser': {
		name: 'PDF 합치기·나누기',
		description: 'PDF 파일을 합치고, 나누고, 페이지 순서를 바꿉니다',
		keywords: ['pdf 합치기', 'pdf 분할', 'pdf 페이지 삭제'],
	},
	'image-to-pdf': {
		name: 'JPG를 PDF로',
		description: '사진·이미지 여러 장을 PDF 한 파일로 만듭니다',
		keywords: ['jpg pdf 변환', '이미지 pdf 변환'],
	},
	'pdf-to-images': {
		name: 'PDF를 JPG로',
		description: 'PDF 페이지를 이미지 파일로 바꿉니다',
		keywords: ['pdf jpg 변환', 'pdf 이미지 변환'],
	},
	'pdf-compressor': {
		name: 'PDF 용량 줄이기',
		description: 'PDF 파일 크기를 줄여 메일·업로드를 쉽게 합니다',
		keywords: ['pdf 압축', 'pdf 용량'],
	},
	'pdf-rotate-crop': {
		name: 'PDF 회전·자르기',
		description: 'PDF 페이지를 돌리거나 여백을 잘라냅니다',
		keywords: ['pdf 회전', 'pdf 자르기'],
	},
	'pdf-page-numberer': {
		name: 'PDF 쪽번호 넣기',
		description: 'PDF에 페이지 번호나 도장을 찍습니다',
		keywords: ['pdf 페이지 번호', 'pdf 쪽수'],
	},
	// 영상·오디오
	'video-to-gif': {
		name: '동영상 GIF 변환',
		description: '동영상 구간을 반복 재생되는 GIF로 만듭니다',
		keywords: ['gif 만들기', 'mp4 gif 변환'],
	},
	'video-trimmer': {
		name: '동영상 자르기',
		description: '동영상의 원하는 구간만 잘라 저장합니다',
		keywords: ['영상 자르기', '동영상 편집'],
	},
	'audio-extractor': {
		name: '동영상 소리 추출',
		description: '동영상에서 오디오만 뽑아 저장합니다',
		keywords: ['mp4 mp3 변환', '영상 음원 추출'],
	},
	'screen-recorder': {
		name: '화면 녹화',
		description: '설치 없이 브라우저에서 화면과 마이크 소리를 녹화합니다',
		keywords: ['컴퓨터 화면 녹화', '화면 캡처 영상'],
	},
	'voice-recorder': {
		name: '음성 녹음',
		description: '브라우저에서 바로 음성 메모를 녹음합니다',
		keywords: ['녹음기', '온라인 녹음'],
	},
	'auto-subtitle': {
		name: '자동 자막 생성',
		description: '영상·음성을 받아써서 자막 파일을 만듭니다',
		keywords: ['자막 만들기', '받아쓰기', 'srt 생성'],
	},
	'video-muter': {
		name: '동영상 소리 제거',
		description: '동영상에서 소리를 없애 무음 영상으로 만듭니다',
		keywords: ['영상 음소거', '소리 없애기'],
	},
	'audio-trimmer': {
		name: '오디오 자르기',
		description: '음악·녹음 파일을 자르고 페이드를 넣습니다',
		keywords: ['mp3 자르기', '벨소리 만들기'],
	},
	// 텍스트
	'word-counter': {
		name: '글자수 세기',
		description: '공백 포함·제외 글자수와 단어 수를 셉니다',
		keywords: ['글자수', '자소서 글자수'],
	},
	'text-diff': {
		name: '텍스트 비교',
		description: '두 글을 비교해 달라진 부분을 표시합니다',
		keywords: ['문서 비교', '글 비교'],
	},
	// 기타
	'qr-genny': {
		name: 'QR코드 만들기',
		description: '색상·모양·로고를 넣은 QR코드를 무료로 만듭니다',
		keywords: ['qr코드 생성', 'qr 만들기'],
	},
	'code-genny': {
		name: '바코드 만들기',
		description: 'EAN-13·Code 128 등 다양한 바코드를 만듭니다',
		keywords: ['바코드 생성'],
	},
	'password-genny': {
		name: '비밀번호 생성기',
		description: '안전한 비밀번호나 여러 단어 암호문을 만듭니다',
		keywords: ['랜덤 비밀번호', '비밀번호 만들기'],
	},
	'unit-converter': {
		name: '단위 변환',
		description: '길이·무게·데이터 등 여러 단위를 바꿉니다',
		keywords: ['단위 계산', '평수 변환'],
	},

	// ── 2차: 나머지 도구 (이름·설명만 먼저, 화면 문구는 순차 번역) ──
	// SNS
	'matte-genny': { name: '정사각형 여백 넣기', description: '세로·가로 사진을 잘리지 않게 정사각형 여백 위에 올립니다', keywords: ['인스타 여백', '사진 안 잘리게'] },
	'scroll-genny': { name: '인스타 파노라마 분할', description: '긴 이미지를 인스타그램 캐러셀용으로 이어지게 나눕니다', keywords: ['파노라마 분할', '캐러셀'] },
	// 색상
	'colour-atlas': { name: '색상 정보 보기', description: '색 하나의 모든 정보를 한 페이지에서 확인합니다', keywords: ['색상 코드', 'hex'] },
	'colorblind-sim': { name: '색맹 시뮬레이터', description: '색각 이상인 사람에게 보이는 화면을 미리 봅니다', keywords: ['색약', '색각 이상'] },
	'colour-converter': { name: '색상 코드 변환', description: 'HEX·RGB·HSL 등 색상 표기를 서로 바꿉니다', keywords: ['hex rgb 변환'] },
	'contrast-checker': { name: '명도 대비 검사', description: '글자와 배경색의 대비가 웹 접근성 기준을 넘는지 확인합니다', keywords: ['색 대비', '접근성'] },
	'gradient-genny': { name: '그라데이션 만들기', description: 'CSS 그라데이션을 만들고 코드를 복사합니다', keywords: ['그라디언트', 'css gradient'] },
	'harmony-genny': { name: '배색 조합 만들기', description: '보색·유사색 등 어울리는 색 조합을 만듭니다', keywords: ['색 조합', '배색'] },
	'palette-collection': { name: '컬러 팔레트 모음', description: '바로 쓸 수 있는 색상 팔레트 모음', keywords: ['색상 팔레트'] },
	'palette-genny': { name: '컬러 팔레트 생성', description: '어울리는 색상 팔레트를 무작위로 만듭니다', keywords: ['팔레트 만들기'] },
	'pixel-picker': { name: '이미지 스포이드', description: '이미지에서 원하는 지점의 색을 집어냅니다', keywords: ['색 추출', '스포이드'] },
	'tailwind-shades': { name: 'Tailwind 색상 단계', description: '색 하나로 Tailwind 50~950 단계를 만듭니다' },
	// 이미지
	'image-atlas': { name: '이미지 정보 보기', description: '이미지 한 장의 크기·형식·메타데이터를 한눈에 봅니다', keywords: ['사진 정보', 'exif 보기'] },
	'artwork-enhancer': { name: '그림 질감 넣기', description: '그림에 컬러 노이즈를 입혀 인쇄물 같은 질감을 냅니다', keywords: ['노이즈', '그레인'] },
	'image-clipper': { name: '투명 여백 자르기', description: 'PNG의 투명한 가장자리를 잘라 크기를 최소로 줄입니다' },
	'image-deskewer': { name: '기울어진 사진 바로잡기', description: '비스듬히 찍힌 문서·사진을 반듯하게 펴줍니다', keywords: ['문서 스캔', '원근 보정'] },
	'image-masker': { name: '이미지 모양 자르기', description: '사진을 원·하트 등 원하는 모양으로 잘라냅니다', keywords: ['원형 자르기'] },
	'image-tracer': { name: '이미지 SVG 변환', description: '비트맵 이미지를 SVG 벡터로 바꿉니다', keywords: ['벡터 변환', 'png svg'] },
	'paste-image': { name: '캡처 이미지 저장', description: '클립보드에 복사한 이미지를 바로 파일로 저장합니다', keywords: ['클립보드 이미지'] },
	'placeholder-genny': { name: '더미 이미지 만들기', description: '원하는 크기의 임시 이미지를 만듭니다' },
	'svg-optimiser': { name: 'SVG 최적화', description: 'SVG 파일의 불필요한 코드를 지워 용량을 줄입니다', keywords: ['svg 압축'] },
	'base64-image-encoder': { name: '이미지 Base64 변환', description: '이미지를 Base64 문자열로, 문자열을 이미지로 바꿉니다' },
	substrata: { name: '이미지 편집기', description: '레이어·마스크·자르기·글자를 지원하는 브라우저 이미지 편집기', keywords: ['포토샵 대체', '온라인 포토샵'] },
	errata: { name: 'PDF 편집기', description: '가리기·양식 작성·서명까지 되는 브라우저 PDF 편집기', keywords: ['pdf 서명', 'pdf 수정'] },
	// 영상·오디오
	'audio-atlas': { name: '오디오 정보 보기', description: '오디오 파일의 형식·길이·음량 정보를 한눈에 봅니다' },
	'video-atlas': { name: '동영상 정보 보기', description: '동영상의 코덱·해상도·길이 정보를 한눈에 봅니다' },
	'audio-normaliser': { name: '음량 맞추기', description: '오디오 소리 크기를 일정하게 맞춥니다', keywords: ['볼륨 조절', '노멀라이즈'] },
	'frame-extractor': { name: '동영상 캡처 추출', description: '동영상에서 장면을 이미지로 뽑고 한 장에 모아 봅니다', keywords: ['영상 캡처', '썸네일 추출'] },
	'subtitle-converter': { name: '자막 변환', description: 'SRT·VTT 자막 형식을 서로 바꿉니다', keywords: ['srt vtt 변환'] },
	'subtitle-studio': { name: '자막 입히기', description: '자막을 동영상 화면에 직접 새겨 넣습니다', keywords: ['자막 합치기', '하드섭'] },
	'timecode-calc': { name: '타임코드 계산기', description: '영상 타임코드를 더하고 빼고 프레임으로 바꿉니다' },
	'waveform-genny': { name: '오디오 파형 이미지', description: '오디오 파형을 이미지로 만듭니다' },
	// 텍스트
	'doc-converter': { name: '문서 형식 변환', description: '마크다운·HTML·워드·EPUB 등 문서 형식을 바꿉니다', keywords: ['docx 변환', '마크다운 변환'] },
	'text-editor': { name: '집중 글쓰기', description: '방해 없이 쓰는 마크다운 글쓰기 도구' },
	'font-explorer': { name: '폰트 파일 보기', description: '폰트 파일의 글자·정보를 미리 봅니다' },
	'glyph-browser': { name: '특수문자 찾기', description: '유니코드 특수문자를 찾아 복사합니다', keywords: ['특수문자', '유니코드'] },
	'large-type': { name: '큰 글씨 띄우기', description: '화면 가득 큰 글씨로 보여줍니다', keywords: ['전광판'] },
	'line-height-calc': { name: '줄 간격 계산기', description: '글자 크기에 맞는 줄 간격을 계산합니다' },
	'paper-sizes': { name: '종이 규격 크기', description: 'A4·B5 등 종이 규격 크기를 한눈에 봅니다', keywords: ['a4 크기', '용지 크기'] },
	'px-to-rem': { name: 'PX REM 변환', description: 'CSS px와 rem 단위를 서로 바꿉니다' },
	'typo-calc': { name: '타이포 단위 변환', description: 'pt·px·mm 등 글자 단위를 서로 바꿉니다', keywords: ['pt px 변환'] },
	// PDF
	'pdf-preflight': { name: 'PDF 인쇄 점검', description: '인쇄소에 넘기기 전에 PDF 문제를 미리 찾아냅니다' },
	// 인쇄
	imposer: { name: '인쇄 판걸이', description: '책자·중철·모아찍기용으로 PDF 페이지를 배치합니다', keywords: ['하리꼬미', '책자 인쇄'] },
	'zine-imposer': { name: '미니 책자 만들기', description: '종이 한 장으로 접는 8쪽 미니 책자를 배치합니다' },
	// 개발
	'cron-builder': { name: '크론 표현식 만들기', description: '크론 일정을 사람이 읽는 말로 만들고 확인합니다' },
	'http-status': { name: 'HTTP 상태 코드', description: 'HTTP 상태 코드의 뜻을 찾아봅니다' },
	'json-formatter': { name: 'JSON 정리', description: 'JSON을 보기 좋게 정리하고 오류를 찾습니다', keywords: ['json 검사'] },
	'jwt-decoder': { name: 'JWT 해독', description: 'JWT 토큰의 내용을 풀어 봅니다' },
	'meta-tag-genny': { name: '메타 태그 생성기', description: 'SEO·SNS 공유용 메타 태그를 만듭니다', keywords: ['og 태그', 'seo 태그'] },
	'regex-tester': { name: '정규식 테스트', description: '정규 표현식을 실시간으로 시험합니다' },
	'request-builder': { name: 'API 요청 만들기', description: 'cURL·HTTP 요청을 조립합니다' },
	'tailwind-cheatsheet': { name: 'Tailwind 치트시트', description: 'Tailwind CSS 클래스를 빠르게 찾아봅니다' },
	'uuid-genny': { name: 'UUID 생성기', description: '고유 식별자 UUID를 만듭니다' },
	// 기타
	decoder: { name: '암호 해독기', description: '고전 암호를 풀거나 어떤 암호인지 자동으로 찾아냅니다' },
	'markdown-writer': { name: '텍스트 메모장', description: '대소문자 변환·정렬 등 편집 기능이 있는 메모장' },
	'morse-code': { name: '모스 부호 변환', description: '모스 부호로 바꾸고, 풀고, 소리로 들어봅니다' },
	// 계산기
	// 한국형 계산기
	'vat-calc': {
		name: '부가세 계산기',
		description: '공급가액·합계금액으로 부가가치세 10%를 바로 계산합니다',
		keywords: ['부가세 계산', '부가가치세', '공급가액', 'vat 계산'],
	},
	'loan-calc': {
		name: '대출이자 계산기',
		description: '원리금균등·원금균등·만기일시 상환의 월 상환금과 총 이자를 계산합니다',
		keywords: ['대출 이자 계산', '원리금균등', '원금균등', '주택담보대출 계산', '월 상환금'],
	},
	'severance-calc': {
		name: '퇴직금 계산기',
		description: '입사일·퇴직일·월급으로 법정 퇴직금을 계산합니다',
		keywords: ['퇴직금 계산', '평균임금', '퇴직금 지급 기준'],
	},
	'brokerage-calc': {
		name: '복비 계산기',
		description: '매매·전세·월세 부동산 중개보수 상한을 요율표대로 계산합니다',
		keywords: ['중개수수료', '중개보수', '복비', '부동산 수수료', '월세 복비'],
	},
	'insurance-calc': {
		name: '4대보험 계산기',
		description: '2026년 요율로 국민연금·건강보험·장기요양·고용보험료를 계산합니다',
		keywords: ['4대보험 계산', '국민연금 계산', '건강보험료 계산', '고용보험료', '4대보험 요율'],
	},
	'algebra-calc': { name: '방정식 계산기', description: '식 정리·인수분해·방정식 풀이·미분을 합니다' },
	'base-converter': { name: '진법 변환', description: '2진수·8진수·16진수를 서로 바꿉니다' },
	encoder: { name: '인코딩 변환', description: 'Base64·URL 인코딩과 해시를 만듭니다' },
	'graph-calc': { name: '그래프 계산기', description: '함수 그래프를 그려 봅니다' },
	'sci-calc': { name: '공학용 계산기', description: '삼각함수·로그 등을 계산합니다' },
	'time-calc': { name: '시간 계산기', description: '시간을 더하고 빼고 차이를 계산합니다' },
};

// 카테고리 한국어 이름
export const categoriesKo: Record<string, string> = {
	'social-media': 'SNS',
	colour: '색상',
	'img-assets': '이미지',
	'audio-video': '영상·오디오',
	'typo-text': '텍스트',
	pdf: 'PDF',
	'other-tools': '기타 도구',
	calculators: '계산기',
	'print-production': '인쇄',
	'dev-tools': '개발 도구',
	'turbo-nerd': '재미있는 변환',
};
