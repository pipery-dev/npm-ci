#!/usr/bin/env psh
set -euo pipefail

PROJECT="${INPUT_PROJECT_PATH:-.}"
LOG="${INPUT_LOG_FILE:-pipery.jsonl}"

if [ -f "${PROJECT}/yarn.lock" ]; then
  PM="yarn"
else
  PM="npm"
fi

if [ -f "${PROJECT}/package.json" ] && command -v node >/dev/null 2>&1; then
  HAS_BUILD=$(node -e "const path=require('path');const p=require(path.resolve(process.cwd(),'${PROJECT}/package.json')); process.exit(p.scripts && p.scripts.build ? 0 : 1);" 2>/dev/null && echo "yes" || echo "no")
else
  HAS_BUILD="no"
fi

if [ "${HAS_BUILD}" = "yes" ]; then
  echo "==> Build: running '${PM} run build'"
  cd "${PROJECT}" && ${PM} run build
  printf '{"event":"build_step","status":"success","tool":"%s"}\n' "${PM}" >> "${LOG}"
else
  echo "==> Build: no build script found in package.json; skipping"
  printf '{"event":"build_step","status":"skipped","reason":"no_build_script"}\n' >> "${LOG}"
fi
