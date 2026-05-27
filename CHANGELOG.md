# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

- _Nothing yet._

## [1.1.1]

- Added optional Docker image release support for npm applications.
- Added script coverage for Docker build, tag, login, push, and log emission behavior.

## [1.1.0]

- _Nothing yet._

## [1.0.0]

## [1.0.1] - 2026-04-27

### Added
- GitHub Marketplace branding icon updated to match action technology (Feather icon set)
- Added `simple_icon` field to `pipery-action.toml` for technology icon reference (Simple Icons slug)
- `tests_path` input: configures the path or glob appended after `-- ` to the test runner command
- Short git hash (`sha-<7chars>`) included in every release as a dist-tag alongside semver tags

### Changed
- All step scripts use `#!/usr/bin/env psh` as the shebang — psh intercepts and logs every command automatically
- `setup-psh.sh` detects runner architecture dynamically (amd64 and arm64)
- `config_file` is now loaded via a dedicated step at the start of the composite action
- `node_version` input wired to `actions/setup-node` step

## [0.1.0] - Initial scaffold
