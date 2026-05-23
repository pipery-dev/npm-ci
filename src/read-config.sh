#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${INPUT_CONFIG_FILE:-.pipery/config.yaml}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file not found: ${CONFIG_FILE}; skipping"
  exit 0
fi

echo "==> Reading config from ${CONFIG_FILE}"

python3 - "$CONFIG_FILE" <<'PY'
import os
import sys

try:
    import yaml
except Exception:
    sys.exit(0)

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    config = yaml.safe_load(handle) or {}

github_env = os.environ.get("GITHUB_ENV")
for key, value in config.items():
    env_key = "INPUT_" + str(key).upper().replace("-", "_")
    if env_key in os.environ:
        continue
    line = f"{env_key}={value}\n"
    if github_env:
        with open(github_env, "a", encoding="utf-8") as env_file:
            env_file.write(line)
    else:
        print(f"export {env_key}={value!r}")
PY
