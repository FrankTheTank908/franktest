#!/usr/bin/env bash
set -euo pipefail

missing=0
for cmd in git; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
    missing=1
  fi
done

if [ "$missing" -eq 1 ]; then
  exit 1
fi

echo "Environment looks good for repository setup."
