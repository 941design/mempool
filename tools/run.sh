#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ -f "$ROOT_DIR/.env.desktop" ]; then
  set -a
  source "$ROOT_DIR/.env.desktop"
  set +a
fi

BINARY="$ROOT_DIR/app-launcher/src-tauri/target/release/app-launcher"
if [ -f "$BINARY" ]; then
  "$BINARY" "$@"
else
  echo "Built launcher not found. Run make build first." >&2
  exit 1
fi
