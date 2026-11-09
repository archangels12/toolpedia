#!/usr/bin/env bash
# 빌드한 뒤 Hostinger로 업로드한다: npm run deploy
# 미리보기(실제 업로드 없음): npm run deploy -- --dry-run
# 접속 정보는 .env에만 둔다 (.env.example 참고). 로그인은 SSH 키로 한다.
set -euo pipefail
cd "$(dirname "$0")/.."

set -a
source .env
set +a

# 경로를 잘못 넣으면 --delete가 다른 파일을 지울 수 있으니 public_html 폴더만 허용
case "$DEPLOY_PATH" in
	*/public_html) ;;
	*) echo "DEPLOY_PATH는 public_html로 끝나야 합니다." >&2; exit 1 ;;
esac

npm run build:static
rsync -rlv --delete -e "ssh -p $DEPLOY_PORT" "$@" dist/ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
