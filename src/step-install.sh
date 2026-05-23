#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
REQUESTED_PM="${INPUT_PACKAGE_MANAGER:-auto}"
PROJECT_CACHE_KEY="$(printf '%s' "$PROJECT" | tr -c 'A-Za-z0-9._-' '_')"
NPM_CACHE="${RUNNER_TEMP:-/tmp}/pipery-npm-cache-${PROJECT_CACHE_KEY}"
mkdir -p "$NPM_CACHE"
export npm_config_cache="$NPM_CACHE"
export npm_config_update_notifier=false

if [ ! -f "${PROJECT}/package.json" ]; then
  echo "==> Install: no package.json found; skipping"
  printf '{"event":"install","status":"skipped","reason":"no_package_json"}\n' >> "${LOG}"
  exit 0
fi

if [ "$REQUESTED_PM" = "yarn" ] || { [ "$REQUESTED_PM" = "auto" ] && [ -f "${PROJECT}/yarn.lock" ]; }; then
  PM="yarn"
else
  PM="npm"
fi

echo "==> Install: installing dependencies with ${PM}"
if [ "$PM" = "yarn" ]; then
  cd "$PROJECT" && yarn install --frozen-lockfile
else
  if [ -f "${PROJECT}/package-lock.json" ] || [ -f "${PROJECT}/npm-shrinkwrap.json" ]; then
    cd "$PROJECT" && npm ci --no-audit --no-fund
  else
    cd "$PROJECT" && npm install --no-audit --no-fund
  fi
fi

printf '{"event":"install","status":"success","tool":"%s"}\n' "$PM" >> "${LOG}"
