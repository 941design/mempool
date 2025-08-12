.PHONY: dev build run

# Start backend, frontend dev server and Tauri app
# Requires environment variables from .env.desktop

dev:
	./tools/dev.sh

# Build frontend and Tauri bundle
build:
	./tools/build.sh

# Run the packaged desktop app
run:
	./tools/run.sh
