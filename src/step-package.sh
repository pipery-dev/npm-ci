#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_CACHE_KEY="$(printf '%s' "$PROJECT" | tr -c 'A-Za-z0-9._-' '_')"
NPM_CACHE="${RUNNER_TEMP:-/tmp}/pipery-npm-cache-${PROJECT_CACHE_KEY}"
mkdir -p "$NPM_CACHE"
export npm_config_cache="$NPM_CACHE"
export npm_config_update_notifier=false

echo "==> Package: running 'npm pack' in ${PROJECT}"
cd "${PROJECT}"
npm pack
printf '{"event":"package","status":"success","tool":"npm-pack"}\n' >> "${LOG}"
