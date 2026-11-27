#!/usr/bin/env bash
# 예약 가이드 공개일이 되면 배포한다. 매일 아침 launchd가 실행한다.
# 마지막 자동 배포 이후 ~ 오늘 사이에 공개일이 있는 가이드가 있을 때만 배포한다.
# 작업 중인(커밋 안 된) 변경이 있으면 그대로 올라가지 않도록 건너뛴다.
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

state=.auto-deploy-last
today=$(TZ=Asia/Seoul date +%F)
last=$(cat "$state" 2>/dev/null || echo 0000-00-00)

due=$(grep -o "published: '[0-9-]*'" app/lib/guides.ts | grep -o '[0-9-]\{10\}' |
	awk -v a="$last" -v b="$today" '$0 > a && $0 <= b' | sort -u)

echo "[$(date '+%F %T')] 마지막 배포 $last, 오늘 $today, 공개 대상: ${due:-없음}"
[ -z "$due" ] && exit 0

if [ -n "$(git status --porcelain)" ]; then
	echo "커밋 안 된 변경이 있어 건너뜀"
	exit 1
fi

npm run deploy
echo "$today" > "$state"
echo "배포 완료"
