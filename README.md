# Pipery npm CI

CI pipeline for npm/Node.js: SAST, SCA, lint, build, test, versioning, packaging, publish, optional Docker image release, reintegration

## Status

- Owner: `pipery-dev`
- Repository: `pipery-npm-ci`
- Marketplace category: `continuous-integration`
- Current version: `1.1.0`

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
```

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `project_path` | no | `.` | Path to the project source tree the action should operate on. |
| `release_docker_image` | no | `false` | Build and push a Docker image for the application after npm packaging/release. |
| `docker_registry` | no | `ghcr.io` | Docker registry host used for login and image prefix. |
| `docker_image` | no | `` | Docker image name without tag. Defaults to the GitHub repository when available. |
| `docker_tags` | no | `` | Comma, space, or newline separated Docker tags. Defaults to package version and `sha-<short sha>` when available. |
| `docker_context` | no | `.` | Docker build context, relative to `project_path` unless absolute. |
| `dockerfile` | no | `Dockerfile` | Dockerfile path, relative to `project_path` unless absolute. |
| `docker_username` | no | `` | Docker registry username. For `ghcr.io` this is usually the GitHub actor. |
| `docker_password` | no | `` | Docker registry password or token. |
| `docker_push_latest` | no | `false` | Also tag and push `latest`. |

## Docker image release

Set `release_docker_image: true` when the Node.js project should publish a container image as part of the same pipeline. The action builds the image with Docker, tags it from `docker_tags` or from `package.json` plus the current commit SHA, and pushes each tag.

```yaml
- uses: pipery-dev/pipery-npm-ci@v1
  with:
    project_path: .
    release_docker_image: "true"
    docker_registry: ghcr.io
    docker_image: pipery-dev/my-node-app
    docker_tags: "1.2.3,sha-${{ github.sha }}"
    docker_username: ${{ github.actor }}
    docker_password: ${{ secrets.GITHUB_TOKEN }}
```

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
