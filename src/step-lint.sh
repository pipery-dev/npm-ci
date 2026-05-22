#!/usr/bin/env psh
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT="${INPUT_PROJECT_PATH:-.}"
PROJECT_CACHE_KEY="$(printf '%s' "$PROJECT" | tr -c 'A-Za-z0-9._-' '_')"
NPM_CACHE="${RUNNER_TEMP:-/tmp}/pipery-npm-cache-${PROJECT_CACHE_KEY}"
mkdir -p "$NPM_CACHE"
export npm_config_cache="$NPM_CACHE"
export npm_config_update_notifier=false

ESLINT_CONFIG=$(find "${PROJECT}" -maxdepth 1 \( -name ".eslintrc*" -o -name "eslint.config.*" \) 2>/dev/null | head -1)

if [ -n "${ESLINT_CONFIG}" ]; then
  echo "==> Lint: ESLint config found at ${ESLINT_CONFIG}"
  npx --yes eslint "${PROJECT}" --max-warnings=0
  printf '{"event":"lint","status":"success","tool":"eslint"}\n' >> "${LOG}"
else
  echo "==> Lint: no ESLint config found; skipping gracefully"
  printf '{"event":"lint","status":"skipped","reason":"no_eslint_config"}\n' >> "${LOG}"
fi
