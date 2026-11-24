#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# github-pages pins Jekyll 3.9, which does not run on Ruby 4.
if [[ -d /opt/homebrew/opt/ruby@3.3/bin ]]; then
  export PATH="/opt/homebrew/opt/ruby@3.3/bin:$PATH"
fi
cd "$ROOT"

ENV_FILE="$ROOT/.env"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

: "${OSS_BUCKET:?Set OSS_BUCKET in .env (see .env.example)}"
: "${OSS_ENDPOINT:?Set OSS_ENDPOINT in .env}"
: "${OSS_ACCESS_KEY_ID:?Set OSS_ACCESS_KEY_ID in .env}"
: "${OSS_ACCESS_KEY_SECRET:?Set OSS_ACCESS_KEY_SECRET in .env}"

if [[ -z "${OSS_REGION:-}" ]]; then
  endpoint_host="${OSS_ENDPOINT#https://}"
  endpoint_host="${endpoint_host#http://}"
  endpoint_host="${endpoint_host%%/*}"
  if [[ "$endpoint_host" =~ ^oss-([a-z0-9-]+)\.aliyuncs\.com$ ]]; then
    OSS_REGION="${BASH_REMATCH[1]}"
  else
    echo "Set OSS_REGION in .env (could not derive from OSS_ENDPOINT)." >&2
    exit 1
  fi
fi

OSSUTIL="$ROOT/bin/ossutil"
if [[ ! -x "$OSSUTIL" ]]; then
  if command -v ossutil >/dev/null 2>&1; then
    OSSUTIL="ossutil"
  else
    echo "ossutil not found. Run ./scripts/setup.sh first." >&2
    exit 1
  fi
fi

CONFIG_FILE="$ROOT/.ossutilconfig"
cat > "$CONFIG_FILE" <<EOF
[default]
accessKeyID = ${OSS_ACCESS_KEY_ID}
accessKeySecret = ${OSS_ACCESS_KEY_SECRET}
region = ${OSS_REGION}
endpoint = ${OSS_ENDPOINT}
EOF
chmod 600 "$CONFIG_FILE"

export JEKYLL_ENV=production
export SITE_URL="${SITE_URL:-https://coutto.cn}"
# liquid 4.0.3 calls String#tainted?, gone since Ruby 3.2. _plugins may be skipped when safe: true.
export RUBYOPT="-r${ROOT}/_plugins/liquid_taint.rb${RUBYOPT:+ ${RUBYOPT}}"

PROD_OVERRIDE="$ROOT/.jekyll-prod.override.yml"
cat > "$PROD_OVERRIDE" <<EOF
url: '${SITE_URL}'
EOF

echo "==> Building Jekyll site (production, url=${SITE_URL})"
bundle exec jekyll build --config _config.yml,_config.prod.yml,"$PROD_OVERRIDE"

DEST="oss://${OSS_BUCKET}/"
echo "==> Syncing _site/ -> ${DEST}"
"$OSSUTIL" -c "$CONFIG_FILE" sync "$ROOT/_site/" "$DEST" --delete --force

echo "==> Ensuring OSS static website (SupportSubDir)"
"$OSSUTIL" -c "$CONFIG_FILE" api put-bucket-website --bucket "${OSS_BUCKET}" --website-configuration "$(cat <<'EOF'
{"IndexDocument":{"Suffix":"index.html","SupportSubDir":true,"Type":"0"},"ErrorDocument":{"Key":"404.html","HttpStatus":"404"}}
EOF
)" >/dev/null

# Anonymous GET / is rejected (0003-00000905) unless ListObjects is allowed.
# With that permission, static website hosting returns index.html instead of a listing.
owner="$("$OSSUTIL" -c "$CONFIG_FILE" stat "oss://${OSS_BUCKET}" | awk -F: '/^Owner/ {gsub(/ /,"",$2); print $2; exit}')"
echo "==> Allowing anonymous ListObjects so the homepage can be served"
"$OSSUTIL" -c "$CONFIG_FILE" api put-bucket-policy --bucket "${OSS_BUCKET}" --body "$(cat <<EOF
{"Version":"1","Statement":[{"Effect":"Allow","Action":["oss:ListObjects"],"Principal":["*"],"Resource":["acs:oss:*:${owner}:${OSS_BUCKET}"]}]}
EOF
)" >/dev/null

# permalink: pretty writes page/index.html.
# - /page/ needs the directory marker "page/" plus page/index.html
# - /page  needs a file object "page" (no trailing slash, including /open)
# Do not delete the "page/" marker; removing it makes HEAD /page/ 404.
echo "==> Fixing pretty URLs (dir marker + no-trailing-slash)"
while IFS= read -r index; do
  rel="${index#"$ROOT/_site/"}"
  [[ "$rel" == "index.html" ]] && continue
  page="${rel%/index.html}"
  [[ -n "$page" ]] || continue
  "$OSSUTIL" -c "$CONFIG_FILE" cp "$index" "oss://${OSS_BUCKET}/${page}/index.html" \
    --content-type "text/html; charset=utf-8" -f
  "$OSSUTIL" -c "$CONFIG_FILE" api put-object \
    --bucket "${OSS_BUCKET}" \
    --key "${page}/" \
    --body "" \
    --content-type "application/x-directory" >/dev/null
  "$OSSUTIL" -c "$CONFIG_FILE" cp "$index" "oss://${OSS_BUCKET}/${page}" \
    --content-type "text/html; charset=utf-8" -f
done < <(find "$ROOT/_site" -name index.html -type f)

aasa="$ROOT/_site/.well-known/apple-app-site-association"
if [[ -f "$aasa" ]]; then
  echo "==> Setting Universal Links content type"
  "$OSSUTIL" -c "$CONFIG_FILE" cp "$aasa" "oss://${OSS_BUCKET}/.well-known/apple-app-site-association" \
    --content-type "application/json" -f
fi

echo "==> Deploy complete."
if [[ -n "${OSS_WEBSITE_URL:-}" ]]; then
  echo "    ${OSS_WEBSITE_URL}"
fi
