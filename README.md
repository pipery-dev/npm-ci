# <img src="https://raw.githubusercontent.com/pipery-dev/pipery-npm-ci/main/assets/icon.png" width="28" align="center" /> Pipery npm CI

Reusable GitHub Action for a complete npm/Node.js CI pipeline with structured logging via [Pipery](https://pipery.dev).

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Pipery%20npm%20CI-blue?logo=github)](https://github.com/marketplace/actions/pipery-npm-ci)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Usage

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

## GitLab CI

This repository also includes a GitLab CI equivalent at `.gitlab-ci.yml`. Copy it into a GitLab project or use it as the reference implementation when you want to run the same Pipery pipeline outside GitHub Actions.

The GitLab pipeline maps the action inputs to CI/CD variables, publishes `pipery.jsonl` as an artifact, and keeps the same skip controls where the GitHub Action exposes them. Store credentials such as deploy tokens, registry passwords, and cloud provider keys as protected GitLab CI/CD variables.

```yaml
include:
  - remote: https://raw.githubusercontent.com/pipery-dev/pipery-npm-ci/v1/.gitlab-ci.yml
```

## Pipeline steps

| Step | Tool | Skip input |
|---|---|---|
| SAST | njsscan | `skip_sast` |
| SCA | npm audit / yarn audit | `skip_sca` |
| Lint | ESLint | `skip_lint` |
| Build | `npm run build` / `yarn build` | `skip_build` |
| Test | `npm test` / `yarn test` | `skip_test` |
| Version | Semantic version bump | `skip_versioning` |
| Package | `npm pack` | `skip_packaging` |
| Release | npm publish + SHA dist-tag | `skip_release` |
| Reintegrate | Merge back to default branch | `skip_reintegration` |

## Inputs

| Name | Default | Description |
|---|---|---|
| `project_path` | `.` | Path to the project source tree. |
| `config_file` | `.pipery/config.yaml` | Path to Pipery config file. |
| `node_version` | `20` | Node.js version to use. |
| `package_manager` | `auto` | Package manager: `auto`, `npm`, or `yarn`. |
| `tests_path` | `` | Path or glob passed to the test runner after `--`. |
| `version_bump` | `patch` | Version bump type: `patch`, `minor`, or `major`. |
| `npm_token` | `` | npm registry auth token for publishing. |
| `github_token` | `` | GitHub token for reintegration. |
| `log_file` | `pipery.jsonl` | Path to the JSONL structured log file. |
| `skip_sast` | `false` | Skip the SAST step. |
| `skip_sca` | `false` | Skip the SCA step. |
| `skip_lint` | `false` | Skip the lint step. |
| `skip_build` | `false` | Skip the build step. |
| `skip_test` | `false` | Skip the test step. |
| `skip_versioning` | `false` | Skip the versioning step. |
| `skip_packaging` | `false` | Skip the packaging step. |
| `skip_release` | `false` | Skip the release step. |
| `skip_reintegration` | `false` | Skip the reintegration step. |

## About Pipery

<img src="https://avatars.githubusercontent.com/u/270923927?s=32" width="22" align="center" /> [**Pipery**](https://pipery.dev) is an open-source CI/CD observability platform. Every step script runs under **psh** (Pipery Shell), which intercepts all commands and emits structured JSONL events — giving you full visibility into your pipeline without any manual instrumentation.

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
