#!/usr/bin/env psh
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT="${INPUT_PROJECT_PATH:-.}"

if command -v pipery-steps >/dev/null 2>&1; then
  pipery-steps sast --language javascript --project-path "${PROJECT}" --log-file "${LOG}"
else
  echo "==> SAST: pipery-steps not available; skipping gracefully"
  printf '{"event":"sast","status":"skipped","reason":"no_tool"}\n' >> "${LOG}"
fi
