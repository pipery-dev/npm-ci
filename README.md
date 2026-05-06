# <img src="https://raw.githubusercontent.com/pipery-dev/pipery-npm-ci/main/assets/icon.png" alt="Pipery npm CI" width="28" align="center" /> Pipery npm CI

Reusable GitHub Action for a complete npm/Node.js CI pipeline with structured logging via [Pipery](https://pipery.dev).

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Pipery%20npm%20CI-blue?logo=github)](https://github.com/marketplace/actions/pipery-npm-ci)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Table of Contents

- [Quick Start](#quick-start)
- [Pipeline Overview](#pipeline-overview)
- [Configuration Options](#configuration-options)
- [Usage Examples](#usage-examples)
- [GitLab CI](#gitlab-ci)
- [Bitbucket Pipelines](#bitbucket-pipelines)
- [About Pipery](#about-pipery)
- [Development](#development)

## Quick Start

```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-npm-ci@v1
        with:
          project_path: .
          npm_token: ${{ secrets.NPM_TOKEN }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Pipeline Overview

| Step | Tool | Skip Input | Description |
| --- | --- | --- | --- |
| SAST | njsscan | `skip_sast` | Detects common Node.js security issues |
| SCA | npm audit / yarn audit | `skip_sca` | Identifies vulnerable dependencies |
| Lint | ESLint | `skip_lint` | Enforces code style and quality |
| Build | `npm run build` / `yarn build` | `skip_build` | Compiles or bundles your application |
| Test | `npm test` / `yarn test` | `skip_test` | Runs unit and integration tests |
| Version | Semantic versioning | `skip_versioning` | Bumps version and creates git tag |
| Package | `npm pack` | `skip_packaging` | Creates distributable package |
| Release | npm publish | `skip_release` | Publishes to npm registry |
| Reintegrate | Git merge | `skip_reintegration` | Merges back to default branch |

## Configuration Options

| Name | Default | Description |
| --- | --- | --- |
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `.pipery/config.yaml` | Path to Pipery config file. |
| `node_version` | `20` | Node.js version to use (e.g., `18`, `20`, `22`). |
| `package_manager` | `auto` | Package manager: `auto`, `npm`, or `yarn`. |
| `tests_path` | `` | Path or glob passed to the test runner after `--`. |
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |
| `npm_token` | `` | npm registry auth token for publishing. |
| `github_token` | `` | GitHub token for reintegration. |
| `log_file` | `pipery.jsonl` | Path to the JSONL structured log file. |
| `registry` | `npmjs` | Registry target for release. |
| `skip_sast` | `false` | Skip the SAST step. |
| `skip_sca` | `false` | Skip the SCA step. |
| `skip_lint` | `false` | Skip the lint step. |
| `skip_build` | `false` | Skip the build step. |
| `skip_test` | `false` | Skip the test step. |
| `skip_versioning` | `false` | Skip the versioning step. |
| `skip_packaging` | `false` | Skip the packaging step. |
| `skip_release` | `false` | Skip the release step. |
| `skip_reintegration` | `false` | Skip the reintegration step. |

## Usage Examples

### Example 1: Basic npm project with all steps

```yaml
name: CI
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-npm-ci@v1
        with:
          project_path: .
          node_version: "20"
          npm_token: ${{ secrets.NPM_TOKEN }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 2: Yarn-based project

```yaml
- uses: pipery-dev/pipery-npm-ci@v1
  with:
    project_path: .
    package_manager: yarn
    npm_token: ${{ secrets.NPM_TOKEN }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 3: Skip packaging and release (CI only)

```yaml
- uses: pipery-dev/pipery-npm-ci@v1
  with:
    project_path: .
    skip_packaging: true
    skip_release: true
```

### Example 4: Custom test path

```yaml
- uses: pipery-dev/pipery-npm-ci@v1
  with:
    project_path: .
    tests_path: "src/**/*.test.ts"
    npm_token: ${{ secrets.NPM_TOKEN }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 5: Minor version bump for release

```yaml
- uses: pipery-dev/pipery-npm-ci@v1
  with:
    project_path: .
    version_bump: minor
    npm_token: ${{ secrets.NPM_TOKEN }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 6: Private registry deployment

```yaml
- uses: pipery-dev/pipery-npm-ci@v1
  with:
    project_path: .
    registry: npm.example.com
    npm_token: ${{ secrets.PRIVATE_NPM_TOKEN }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## GitLab CI

This repository includes a GitLab CI equivalent at `.gitlab-ci.yml`. Copy it into a GitLab project or use it as a reference implementation for running the same Pipery pipeline outside GitHub Actions.

The GitLab pipeline maps action inputs to CI/CD variables, publishes `pipery.jsonl` as an artifact, and maintains the same skip controls. Store credentials as protected GitLab CI/CD variables.

```yaml
include:
  - remote: https://raw.githubusercontent.com/pipery-dev/pipery-npm-ci/v1/.gitlab-ci.yml
```

### GitLab CI Variables

Configure these protected variables in **Settings > CI/CD > Variables**:

- `NPM_TOKEN` - npm registry authentication token
- `GITHUB_TOKEN` - GitHub API access for reintegration
- `NODE_VERSION` - Node.js version (default: 20)
- `PACKAGE_MANAGER` - auto/npm/yarn (default: auto)
- `VERSION_BUMP` - patch/minor/major (default: patch)

## Bitbucket Pipelines

Bitbucket Cloud pipelines provide an alternative to GitHub Actions. The equivalent pipeline configuration is in `bitbucket-pipelines.yml`.

### Quick Start

1. Copy `bitbucket-pipelines.yml` to your Bitbucket repository root
2. Configure Protected Variables in **Repository Settings > Pipelines > Repository Variables**:
   - `NPM_TOKEN` - npm registry authentication token
   - `GITHUB_TOKEN` - GitHub API access (for reintegration)
   - `NODE_VERSION` - Node.js version (default: 20)
3. Commit and push to trigger the pipeline

### Pipeline Stages

The Bitbucket equivalent follows the same structure:

checkout → setup → SAST (njsscan) → SCA (npm audit) → lint (ESLint) → build → test → versioning → packaging → release → reintegration → logs

### Skip Flags

Disable any stage using environment variables:

- `SKIP_SAST`, `SKIP_SCA`, `SKIP_LINT`, `SKIP_BUILD`, `SKIP_TEST`, `SKIP_VERSIONING`, `SKIP_PACKAGING`, `SKIP_RELEASE`, `SKIP_REINTEGRATION`

Example: Set `SKIP_SAST=true` to skip security scanning.

### Features

- Same security scanning tools (njsscan, npm audit, ESLint)
- Parallel SAST and SCA stages
- Auto-detects npm or yarn
- Automatic versioning and tagging
- npm publish with token authentication
- JSONL-based pipeline logging
- 30-90 day artifact retention

## About Pipery

<img src="https://avatars.githubusercontent.com/u/270923927?s=32" alt="Pipery" width="22" align="center" /> [**Pipery**](https://pipery.dev) is an open-source CI/CD observability platform. Every step script runs under **psh** (Pipery Shell), which intercepts all commands and emits structured JSONL events — giving you full visibility into your pipeline without any manual instrumentation.

- Browse logs in the [Pipery Dashboard](https://github.com/pipery-dev/pipery-dashboard)
- Find all Pipery actions on [GitHub Marketplace](https://github.com/marketplace?q=pipery&type=actions)
- Source code: [pipery-dev](https://github.com/pipery-dev)

## Development

```bash
# Run the action locally against test-project/
pipery-actions test --repo .

# Regenerate docs
pipery-actions docs --repo .

# Dry-run release
pipery-actions release --repo . --dry-run
```
