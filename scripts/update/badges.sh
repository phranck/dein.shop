#!/usr/bin/env bash
# Updates version badges in README.md from package.json files
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
README="$ROOT/README.md"

# Read versions from package.json files
REACT_VERSION=$(node -p "require('$ROOT/apps/frontend/package.json').dependencies.react.replace('^','')" 2>/dev/null || echo "19.0.0")
TS_VERSION=$(node -p "require('$ROOT/apps/frontend/package.json').devDependencies.typescript.replace(/[\\^~]/g,'')" 2>/dev/null || echo "5.7.3")
HONO_VERSION=$(node -p "require('$ROOT/apps/backend/package.json').dependencies.hono.replace('^','')" 2>/dev/null || echo "4.7.4")

echo "Updating badges in README.md..."
echo "  React:      $REACT_VERSION"
echo "  TypeScript: $TS_VERSION"
echo "  Hono:       $HONO_VERSION"

TMP=$(mktemp)
inside=0

while IFS= read -r line; do
  if [[ "$line" == "<!-- BADGES:START -->" ]]; then
    inside=1
    printf '%s\n' "$line"
    printf '![React](https://img.shields.io/badge/React-%s-61DAFB?style=flat&logo=react&logoColor=white)\n' "$REACT_VERSION"
    printf '![TypeScript](https://img.shields.io/badge/TypeScript-%s-3178C6?style=flat&logo=typescript&logoColor=white)\n' "$TS_VERSION"
    printf '![Bun](https://img.shields.io/badge/Bun-1.x-FBF0DF?style=flat&logo=bun&logoColor=black)\n'
    printf '![Hono](https://img.shields.io/badge/Hono-%s-E36002?style=flat&logo=hono&logoColor=white)\n' "$HONO_VERSION"
    printf '![Vite](https://img.shields.io/badge/Vite-6.x-646CFF?style=flat&logo=vite&logoColor=white)\n'
    printf '![Tailwind CSS](https://img.shields.io/badge/Tailwind-v4-38BDF8?style=flat&logo=tailwindcss&logoColor=white)\n'
    continue
  fi
  if [[ "$line" == "<!-- BADGES:END -->" ]]; then
    inside=0
  fi
  if [[ $inside -eq 0 ]]; then
    printf '%s\n' "$line"
  fi
done < "$README" > "$TMP"

mv "$TMP" "$README"
echo "Done. README.md updated successfully."
