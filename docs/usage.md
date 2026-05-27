# Using Pipery npm CI

CI pipeline for npm/Node.js: SAST, SCA, lint, build, test, versioning, packaging, publish, optional Docker image release, reintegration

## Recommended workflow

1. Pin the action to a major tag in production workflows.
2. Keep a representative test project in the repository and point `test_project_path` at it.
3. Emit a `pipery.jsonl` build log during the action run and keep `test_log_path` pointed at it.
4. Make the action consume that path via the configured test input.
5. Keep changelog entries under `## [Unreleased]` until you cut a release.
6. Regenerate docs before publishing a new version.

## Example

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
