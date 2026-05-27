#!/usr/bin/env bash
set -euo pipefail

# Resolve project path: prefer INPUT_PROJECT_PATH, then PIPERY_TEST_PROJECT_PATH, then cwd
export INPUT_PROJECT_PATH="${INPUT_PROJECT_PATH:-${PIPERY_TEST_PROJECT_PATH:-.}}"
export INPUT_LOG_FILE="${INPUT_LOG_FILE:-${PIPERY_LOG_PATH:-pipery.jsonl}}"
export INPUT_CONFIG_FILE="${INPUT_CONFIG_FILE:-.pipery/config.yaml}"
export INPUT_NODE_VERSION="${INPUT_NODE_VERSION:-20}"
export INPUT_PACKAGE_MANAGER="${INPUT_PACKAGE_MANAGER:-auto}"
export INPUT_SKIP_SAST="${INPUT_SKIP_SAST:-false}"
export INPUT_SKIP_SCA="${INPUT_SKIP_SCA:-false}"
export INPUT_SKIP_LINT="${INPUT_SKIP_LINT:-false}"
export INPUT_STRICT_LINT="${INPUT_STRICT_LINT:-false}"
export INPUT_SKIP_BUILD="${INPUT_SKIP_BUILD:-false}"
export INPUT_TESTS_PATH="${INPUT_TESTS_PATH:-}"
export INPUT_SKIP_TEST="${INPUT_SKIP_TEST:-false}"
export INPUT_SKIP_VERSIONING="${INPUT_SKIP_VERSIONING:-false}"
export INPUT_SKIP_PACKAGING="${INPUT_SKIP_PACKAGING:-false}"
export INPUT_SKIP_RELEASE="${INPUT_SKIP_RELEASE:-false}"
export INPUT_RELEASE_DOCKER_IMAGE="${INPUT_RELEASE_DOCKER_IMAGE:-false}"
export INPUT_DOCKER_REGISTRY="${INPUT_DOCKER_REGISTRY:-ghcr.io}"
export INPUT_DOCKER_IMAGE="${INPUT_DOCKER_IMAGE:-}"
export INPUT_DOCKER_TAGS="${INPUT_DOCKER_TAGS:-}"
export INPUT_DOCKER_CONTEXT="${INPUT_DOCKER_CONTEXT:-.}"
export INPUT_DOCKERFILE="${INPUT_DOCKERFILE:-Dockerfile}"
export INPUT_DOCKER_USERNAME="${INPUT_DOCKER_USERNAME:-}"
export INPUT_DOCKER_PASSWORD="${INPUT_DOCKER_PASSWORD:-}"
export INPUT_DOCKER_PUSH_LATEST="${INPUT_DOCKER_PUSH_LATEST:-false}"
export INPUT_SKIP_REINTEGRATION="${INPUT_SKIP_REINTEGRATION:-false}"
export INPUT_VERSION_BUMP="${INPUT_VERSION_BUMP:-patch}"
export INPUT_REGISTRY="${INPUT_REGISTRY:-npmjs}"
export INPUT_NPM_TOKEN="${INPUT_NPM_TOKEN:-}"
export INPUT_GITHUB_TOKEN="${INPUT_GITHUB_TOKEN:-}"

if [ -n "${GITHUB_ACTION_PATH:-}" ]; then
  ACTION_ROOT="$GITHUB_ACTION_PATH"
else
  ACTION_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
SRC_DIR="${ACTION_ROOT}/src"

if [ ! -d "${INPUT_PROJECT_PATH}" ]; then
  echo "ERROR: project path does not exist: ${INPUT_PROJECT_PATH}" >&2
  exit 1
fi

echo "==> pipery-npm-ci starting"
echo "    project_path=${INPUT_PROJECT_PATH}"
echo "    log_file=${INPUT_LOG_FILE}"

# Setup psh
# In test mode use a bash wrapper for psh; the real psh binary has a Go runtime
  # incompatibility (newosproc) with the GitHub Actions runner seccomp profile.
  mkdir -p /tmp/pipery-test-bin
  printf '#!/bin/bash\nexec bash "$@"\n' > /tmp/pipery-test-bin/psh
  chmod +x /tmp/pipery-test-bin/psh
  export PATH="/tmp/pipery-test-bin:$PATH"

# Install pipery-tooling (skip if already installed)
if ! command -v pipery-steps >/dev/null 2>&1; then
  echo "==> Installing pipery-tooling..."
  pip install git+https://github.com/pipery-dev/pipery-tooling.git -q 2>/dev/null || \
    pip3 install git+https://github.com/pipery-dev/pipery-tooling.git -q 2>/dev/null || true
fi

echo "==> Install dependencies"
"${SRC_DIR}/step-install.sh" || { echo "Install step failed" >&2; exit 1; }

# SAST
if [ "${INPUT_SKIP_SAST}" != "true" ]; then
  echo "==> SAST scan"
  "${SRC_DIR}/step-sast.sh" || { echo "SAST step failed" >&2; exit 1; }
fi

# SCA
if [ "${INPUT_SKIP_SCA}" != "true" ]; then
  echo "==> SCA scan"
  "${SRC_DIR}/step-sca.sh" || { echo "SCA step failed" >&2; exit 1; }
fi

# Lint
if [ "${INPUT_SKIP_LINT}" != "true" ]; then
  echo "==> Lint"
  "${SRC_DIR}/step-lint.sh" || { echo "Lint step failed" >&2; exit 1; }
fi

# Build
if [ "${INPUT_SKIP_BUILD}" != "true" ]; then
  echo "==> Build"
  "${SRC_DIR}/step-build.sh" || { echo "Build step failed" >&2; exit 1; }
fi

# Test
if [ "${INPUT_SKIP_TEST}" != "true" ]; then
  echo "==> Test"
  "${SRC_DIR}/step-test.sh" || { echo "Test step failed" >&2; exit 1; }
fi

# Version
if [ "${INPUT_SKIP_VERSIONING}" != "true" ]; then
  echo "==> Version"
  "${SRC_DIR}/step-version.sh" || { echo "Version step failed" >&2; exit 1; }
fi

# Package
if [ "${INPUT_SKIP_PACKAGING}" != "true" ]; then
  echo "==> Package"
  "${SRC_DIR}/step-package.sh" || { echo "Package step failed" >&2; exit 1; }
fi

# Release
if [ "${INPUT_SKIP_RELEASE}" != "true" ]; then
  echo "==> Release"
  "${SRC_DIR}/step-release.sh" || { echo "Release step failed" >&2; exit 1; }
fi

# Docker image release
if [ "${INPUT_RELEASE_DOCKER_IMAGE}" = "true" ]; then
  echo "==> Docker image release"
  "${SRC_DIR}/step-docker-release.sh" || { echo "Docker image release step failed" >&2; exit 1; }
fi

# Reintegrate
if [ "${INPUT_SKIP_REINTEGRATION}" != "true" ]; then
  echo "==> Reintegrate"
  "${SRC_DIR}/step-reintegrate.sh" || { echo "Reintegrate step failed" >&2; exit 1; }
fi

# Write final success log entry
printf '{"event":"build","status":"success","project":"npm","mode":"ci"}\n' >> "${INPUT_LOG_FILE}"

echo "==> pipery-npm-ci complete"
