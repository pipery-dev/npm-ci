#!/usr/bin/env psh
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT="${INPUT_PROJECT_PATH:-.}"

if command -v pipery-steps >/dev/null 2>&1; then
  pipery-steps sca --language javascript --project-path "${PROJECT}" --log-file "${LOG}"
elif command -v npm >/dev/null 2>&1; then
  echo "==> SCA: pipery-steps not found; running npm audit directly"
  cd "${PROJECT}" && npm audit --audit-level=high
  printf '{"event":"sca","status":"success","tool":"npm-audit"}\n' >> "${LOG}"
else
  echo "==> SCA: no tool available (pipery-steps, npm); skipping gracefully"
  printf '{"event":"sca","status":"skipped","reason":"no_tool"}\n' >> "${LOG}"
fi
