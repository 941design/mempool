#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ -f "$ROOT_DIR/.env.desktop" ]; then
  set -a
  source "$ROOT_DIR/.env.desktop"
  set +a
fi

npm --prefix "$ROOT_DIR/frontend" run build
npm --prefix "$ROOT_DIR/backend" run build
npm --prefix "$ROOT_DIR/app-launcher" run build
