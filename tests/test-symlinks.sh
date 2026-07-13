#!/usr/bin/env bash
# Validate every symlinks.conf row is installed as a $HOME symlink into the repo.
# Usage: ./tests/test-symlinks.sh

set -euo pipefail

PASS=0
FAIL=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONF="$DOTFILES_DIR/symlinks.conf"

echo "=== Symlink tests ==="
echo "  dotfiles root: $DOTFILES_DIR"
echo ""

while IFS= read -r line; do
  # skip comments and blank lines
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line//[[:space:]]/}" ]] && continue

  source_rel="${line%%[[:space:]]*}"
  target_rel="${line##*[[:space:]]}"

  [[ -z "$source_rel" || -z "$target_rel" || "$source_rel" == "$target_rel" ]] && continue

  target_path="$HOME/$target_rel"
  source_path="$DOTFILES_DIR/$source_rel"

  if [[ ! -L "$target_path" ]]; then
    echo "  FAIL: $target_path is not a symlink (expected → $source_path)"
    FAIL=$((FAIL + 1))
    continue
  fi

  resolved="$(readlink "$target_path")"
  # resolve to absolute if relative
  if [[ "$resolved" != /* ]]; then
    resolved="$(cd "$(dirname "$target_path")" && cd "$(dirname "$resolved")" && pwd)/$(basename "$resolved")"
  fi

  if [[ "$resolved" == "$source_path" ]]; then
    echo "  PASS: ~/$target_rel → $source_rel"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: ~/$target_rel points to $resolved (expected $source_path)"
    FAIL=$((FAIL + 1))
  fi
done < "$CONF"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
