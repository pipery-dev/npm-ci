# Pipery npm CI

CI pipeline for npm/Node.js: SAST, SCA, lint, build, test, versioning, packaging, publish, optional Docker image release, reintegration

## Status

- Owner: `pipery-dev`
- Repository: `pipery-npm-ci`
- Marketplace category: `continuous-integration`
- Current version: `1.1.1`

## Usage

```yaml
name: Example
on: [push]

jobs:
  run-action:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pipery-dev/pipery-npm-ci@v1
        with:
          project_path: .
          config_file: .pipery/config.yaml
          node_version: 20
          package_manager: auto
          skip_sast: false
          skip_sca: false
          skip_lint: false
          strict_lint: false
          skip_build: false
          tests_path: 
          skip_test: false
          skip_versioning: false
          skip_packaging: false
          skip_release: false
          release_docker_image: false
          docker_registry: ghcr.io
          docker_image: 
          docker_tags: 
          docker_context: .
          dockerfile: Dockerfile
          docker_username: 
          docker_password: 
          docker_push_latest: false
          skip_reintegration: false
          version_bump: patch
          npm_token: 
          github_token: 
          log_file: pipery.jsonl
          registry: npmjs
```

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `project_path` | no | `.` | Path to the project source tree the action should operate on. |
| `config_file` | no | `.pipery/config.yaml` | Path to pipery config file. |
| `node_version` | no | `20` | Node.js version to use. |
| `package_manager` | no | `auto` | Package manager: auto, npm, yarn. |
| `skip_sast` | no | `false` | Skip SAST scan. |
| `skip_sca` | no | `false` | Skip SCA scan. |
| `skip_lint` | no | `false` | Skip lint step. |
| `strict_lint` | no | `false` | Fail the action when lint reports errors. |
| `skip_build` | no | `false` | Skip build step. |
| `tests_path` | no | `` | Path or glob passed to the test runner as an argument. |
| `skip_test` | no | `false` | Skip test step. |
| `skip_versioning` | no | `false` | Skip versioning step. |
| `skip_packaging` | no | `false` | Skip packaging step. |
| `skip_release` | no | `false` | Skip npm release step. |
| `release_docker_image` | no | `false` | Build and push a Docker image for the application after npm packaging/release. |
| `docker_registry` | no | `ghcr.io` | Docker registry host used for login and image prefix. |
| `docker_image` | no | `` | Docker image name without tag. Defaults to the GitHub repository when available. |
| `docker_tags` | no | `` | Comma, space, or newline separated Docker tags. Defaults to package version and sha-<short sha> when available. |
| `docker_context` | no | `.` | Docker build context, relative to project_path unless absolute. |
| `dockerfile` | no | `Dockerfile` | Dockerfile path, relative to project_path unless absolute. |
| `docker_username` | no | `` | Docker registry username. For ghcr.io this is usually the GitHub actor. |
| `docker_password` | no | `` | Docker registry password or token. |
| `docker_push_latest` | no | `false` | Also tag and push latest. |
| `skip_reintegration` | no | `false` | Skip reintegration step. |
| `version_bump` | no | `patch` | Version bump kind: patch, minor, major. |
| `npm_token` | no | `` | npm registry auth token for publishing. |
| `github_token` | no | `` | GitHub token for reintegration. |
| `log_file` | no | `pipery.jsonl` | Path to the JSONL log file. |
| `registry` | no | `npmjs` | npm registry target for release. |

## Outputs

No outputs.

## Development

This repository is managed with `pipery-tooling`.

```bash
pipery-actions test --repo .
pipery-actions docs --repo .
pipery-actions release --repo . --dry-run
```

By default, `pipery-actions test --repo .` executes the action against `test-project` and validates `pipery.jsonl`.

## Marketplace Release Flow

1. Update the implementation and changelog.
2. Run `pipery-actions release --repo .`.
3. Push the created git tag and major tag alias.
4. Publish the GitHub release.
