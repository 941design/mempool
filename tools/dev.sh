#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Load environment variables from .env.desktop if present
if [ -f "$ROOT_DIR/.env.desktop" ]; then
  set -a
  source "$ROOT_DIR/.env.desktop"
  set +a
fi

# Build backend and start it in the background
npm --prefix "$ROOT_DIR/backend" run build >/dev/null 2>&1 && \
  npm --prefix "$ROOT_DIR/backend" run start &
disown

# Start frontend dev server in the background
npm --prefix "$ROOT_DIR/frontend" run start &
disown

# Give servers a moment to start
sleep 5

# Launch Tauri app in dev mode
npm --prefix "$ROOT_DIR/app-launcher" run dev
