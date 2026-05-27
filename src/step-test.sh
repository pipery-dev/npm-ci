#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
TESTS_PATH="${INPUT_TESTS_PATH:-}"

if [ -f "${PROJECT}/yarn.lock" ]; then
  PM="yarn"
else
  PM="npm"
fi

echo "==> Test: running '${PM} test' in ${PROJECT}"
cd "${PROJECT}"

${PM} test ${TESTS_PATH:+-- "$TESTS_PATH"}
printf '{"event":"test","status":"success","tool":"%s"}\n' "${PM}" >> "${LOG}"
