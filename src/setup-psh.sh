#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing bash-backed psh wrapper"
cat > /tmp/psh <<'EOF'
#!/usr/bin/env bash
exec bash "$@"
EOF
chmod +x /tmp/psh

if command -v sudo >/dev/null 2>&1; then
  sudo install -m755 /tmp/psh /usr/local/bin/psh
else
  mkdir -p "$HOME/.local/bin"
  install -m755 /tmp/psh "$HOME/.local/bin/psh"
  echo "$HOME/.local/bin" >> "$GITHUB_PATH"
fi

echo "psh installed: $(command -v psh || printf '%s' "$HOME/.local/bin/psh")"
