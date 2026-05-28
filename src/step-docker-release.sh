#!/usr/bin/env psh
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT="${INPUT_PROJECT_PATH:-.}"
REGISTRY="${INPUT_DOCKER_REGISTRY:-ghcr.io}"
IMAGE="${INPUT_DOCKER_IMAGE:-}"
TAGS="${INPUT_DOCKER_TAGS:-}"
CONTEXT="${INPUT_DOCKER_CONTEXT:-.}"
DOCKERFILE="${INPUT_DOCKERFILE:-Dockerfile}"
PLATFORMS="${INPUT_DOCKER_PLATFORMS:-}"
USERNAME="${INPUT_DOCKER_USERNAME:-}"
PASSWORD="${INPUT_DOCKER_PASSWORD:-}"
PUSH_LATEST="${INPUT_DOCKER_PUSH_LATEST:-false}"
SHORT_SHA="${GITHUB_SHA:-}"
SHORT_SHA="${SHORT_SHA:0:7}"

resolve_path() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *) printf '%s/%s\n' "$PROJECT" "$1" ;;
  esac
}

json_log() {
  printf '{"event":"docker_release","status":"%s","image":"%s"}\n' "$1" "$2" >> "$LOG"
}

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker release requested but docker is not installed or not in PATH" >&2
  json_log "failed" "${IMAGE:-unknown}"
  exit 1
fi

if [ ! -d "$PROJECT" ]; then
  echo "ERROR: project path does not exist: ${PROJECT}" >&2
  json_log "failed" "${IMAGE:-unknown}"
  exit 1
fi

if [ -z "$IMAGE" ]; then
  if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    IMAGE="$(printf '%s' "$GITHUB_REPOSITORY" | tr '[:upper:]' '[:lower:]')"
  else
    PACKAGE_NAME=""
    if PACKAGE_NAME_RAW="$(cd "$PROJECT" && node -p "require('./package.json').name" 2>/dev/null)"; then
      PACKAGE_NAME="$PACKAGE_NAME_RAW"
    fi
    IMAGE="$(printf '%s' "$PACKAGE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/^@//; s#[^a-z0-9._/-]#-#g')"
  fi
fi

if [ -z "$IMAGE" ]; then
  echo "ERROR: Docker release requested but docker_image could not be inferred" >&2
  json_log "failed" "unknown"
  exit 1
fi

REGISTRY="${REGISTRY%/}"
if [ -n "$REGISTRY" ] && [ "${IMAGE#"$REGISTRY"/}" = "$IMAGE" ]; then
  IMAGE_REF="${REGISTRY}/${IMAGE}"
else
  IMAGE_REF="$IMAGE"
fi

BUILD_CONTEXT="$(resolve_path "$CONTEXT")"
BUILD_DOCKERFILE="$(resolve_path "$DOCKERFILE")"

if [ ! -d "$BUILD_CONTEXT" ]; then
  echo "ERROR: Docker build context does not exist: ${BUILD_CONTEXT}" >&2
  json_log "failed" "$IMAGE_REF"
  exit 1
fi

if [ ! -f "$BUILD_DOCKERFILE" ]; then
  echo "ERROR: Dockerfile does not exist: ${BUILD_DOCKERFILE}" >&2
  json_log "failed" "$IMAGE_REF"
  exit 1
fi

if [ -z "$TAGS" ]; then
  PACKAGE_VERSION=""
  if PACKAGE_VERSION_RAW="$(cd "$PROJECT" && node -p "require('./package.json').version" 2>/dev/null)"; then
    PACKAGE_VERSION="$PACKAGE_VERSION_RAW"
  fi
  if [ -n "$PACKAGE_VERSION" ]; then
    TAGS="$PACKAGE_VERSION"
  fi
  if [ -n "$SHORT_SHA" ]; then
    TAGS="${TAGS:+$TAGS }sha-${SHORT_SHA}"
  fi
fi

if [ "$PUSH_LATEST" = "true" ]; then
  TAGS="${TAGS:+$TAGS }latest"
fi

if [ -z "$TAGS" ]; then
  TAGS="latest"
fi

NORMALIZED_TAGS="$(printf '%s\n' "$TAGS" | tr ',\n' '  ')"

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
  echo "==> Docker release: logging in to ${REGISTRY:-default registry}"
  if [ -n "$REGISTRY" ]; then
    printf '%s' "$PASSWORD" | docker login "$REGISTRY" --username "$USERNAME" --password-stdin
  else
    printf '%s' "$PASSWORD" | docker login --username "$USERNAME" --password-stdin
  fi
else
  echo "==> Docker release: no docker credentials provided; using existing registry session"
fi

DOCKER_BUILD_ARGS=()
for tag in $NORMALIZED_TAGS; do
  DOCKER_BUILD_ARGS+=("-t" "${IMAGE_REF}:${tag}")
done

if [ -n "$PLATFORMS" ]; then
  if ! docker buildx version >/dev/null 2>&1; then
    echo "ERROR: Docker buildx is required when docker_platforms is set" >&2
    json_log "failed" "$IMAGE_REF"
    exit 1
  fi
  echo "==> Docker release: building ${IMAGE_REF} for ${PLATFORMS}"
  docker buildx build --platform "$PLATFORMS" -f "$BUILD_DOCKERFILE" "${DOCKER_BUILD_ARGS[@]}" --push "$BUILD_CONTEXT"
else
  echo "==> Docker release: building ${IMAGE_REF}"
  docker build -f "$BUILD_DOCKERFILE" "${DOCKER_BUILD_ARGS[@]}" "$BUILD_CONTEXT"

  for tag in $NORMALIZED_TAGS; do
    echo "==> Docker release: pushing ${IMAGE_REF}:${tag}"
    docker push "${IMAGE_REF}:${tag}"
  done
fi

json_log "success" "$IMAGE_REF"
