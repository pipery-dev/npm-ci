#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pipery-npm-docker.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

FAKE_BIN="${TMP_DIR}/bin"
CALLS="${TMP_DIR}/docker-calls.log"
mkdir -p "$FAKE_BIN"

cat > "${FAKE_BIN}/docker" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
printf '%q ' "$0" "$@" >> "${PIPERY_FAKE_DOCKER_CALLS}"
printf '\n' >> "${PIPERY_FAKE_DOCKER_CALLS}"
if [ "${1:-}" = "login" ]; then
  cat >/dev/null
fi
SCRIPT
chmod +x "${FAKE_BIN}/docker"

export PATH="${FAKE_BIN}:$PATH"
export PIPERY_FAKE_DOCKER_CALLS="$CALLS"
export INPUT_PROJECT_PATH="${ROOT}/test-project-docker"
export INPUT_LOG_FILE="${TMP_DIR}/pipery.jsonl"
export INPUT_DOCKER_REGISTRY="registry.example.com"
export INPUT_DOCKER_IMAGE="team/web"
export INPUT_DOCKER_TAGS="1.2.3,sha-test"
export INPUT_DOCKER_CONTEXT="."
export INPUT_DOCKERFILE="Dockerfile"
export INPUT_DOCKER_USERNAME="ci-user"
export INPUT_DOCKER_PASSWORD="ci-token"
export INPUT_DOCKER_PUSH_LATEST="true"
export GITHUB_SHA="abc123456789"

bash "${ROOT}/src/step-docker-release.sh"

grep -F "docker login registry.example.com --username ci-user --password-stdin" "$CALLS" >/dev/null
grep -F -- "-t registry.example.com/team/web:1.2.3" "$CALLS" >/dev/null
grep -F -- "-t registry.example.com/team/web:sha-test" "$CALLS" >/dev/null
grep -F -- "-t registry.example.com/team/web:latest" "$CALLS" >/dev/null
grep -F "docker push registry.example.com/team/web:1.2.3" "$CALLS" >/dev/null
grep -F "docker push registry.example.com/team/web:sha-test" "$CALLS" >/dev/null
grep -F "docker push registry.example.com/team/web:latest" "$CALLS" >/dev/null
grep -F '"event":"docker_release","status":"success","image":"registry.example.com/team/web"' "${INPUT_LOG_FILE}" >/dev/null

echo "docker release script test passed"
