#!/usr/bin/env bash
set -euo pipefail

mkdir -p Config

if [ -z "${APP_BUNDLE_ID:-}" ]; then
  RAND=$(python3 - <<'PY'
import secrets, string
alphabet = string.ascii_lowercase + string.digits
print(''.join(secrets.choice(alphabet) for _ in range(10)))
PY
)
  APP_BUNDLE_ID="com.autogen.${RAND}"
fi

cat > Config/Generated.xcconfig <<CFG
// Auto-generated. Safe to edit if needed.
DEVELOPMENT_TEAM = ${APPLE_TEAM_ID:-}
PRODUCT_BUNDLE_IDENTIFIER = ${APP_BUNDLE_ID}
CFG

echo "Generated Config/Generated.xcconfig with bundle id: ${APP_BUNDLE_ID}"
