#!/usr/bin/env bash
# Test that common.sh sets up environment correctly
# Usage: ./tests/test-common-env.sh

set -euo pipefail

PASS=0
FAIL=0
TIMEOUT=30

_TMPFILE=""
_cleanup() { rm -f "$_TMPFILE"; }
trap '_cleanup' EXIT INT TERM

run_env_checks() {
  local sh="$1"

  _TMPFILE=$(mktemp "${TMPDIR:-/tmp}/env-test-XXXXXX.sh")

  cat > "$_TMPFILE" <<'SCRIPT'
export DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/shell/common.sh"

_check() {
  local desc="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf 'PASS:%s\n' "$desc"
  else
    printf 'FAIL:%s\n' "$desc"
  fi
}

# Platform detection
_check "PLATFORM is set" '[ -n "$PLATFORM" ]'
_check "PLATFORM is macos or linux" '[ "$PLATFORM" = "macos" ] || [ "$PLATFORM" = "linux" ]'

# Common exports
_check "EDITOR is set" '[ -n "$EDITOR" ]'
_check "HISTSIZE is set" '[ -n "$HISTSIZE" ]'
_check "HISTFILESIZE is set" '[ -n "$HISTFILESIZE" ]'

# PATH entries
_check "PATH contains .local/bin" 'echo "$PATH" | grep -qF ".local/bin"'
_check "PATH contains pub-cache/bin" 'echo "$PATH" | grep -qF ".pub-cache/bin"'

# Homebrew (macOS)
if [ "$PLATFORM" = "macos" ]; then
  _check "PATH contains homebrew" 'echo "$PATH" | grep -qF "/opt/homebrew"'
fi

# Go
_check "GOPATH is set" '[ -n "$GOPATH" ]'
_check "PATH contains GOPATH/bin" 'echo "$PATH" | grep -qF "$GOPATH/bin"'

# Rust
_check "CARGO_HOME is set" '[ -n "$CARGO_HOME" ]'
_check "RUSTUP_HOME is set" '[ -n "$RUSTUP_HOME" ]'
_check "PATH contains CARGO_HOME/bin" 'echo "$PATH" | grep -qF "$CARGO_HOME/bin"'

# Python/pyenv
_check "PYENV_ROOT is set" '[ -n "$PYENV_ROOT" ]'

# NVM
_check "NVM_DIR is set" '[ -n "$NVM_DIR" ]'

# Sourcing chain: functions.sh and aliases.sh loaded
_check "functions.sh loaded (load_doppler_cache defined)" 'type load_doppler_cache'
_check "aliases.sh loaded (ll alias exists)" 'alias ll'
SCRIPT

  local output total=0
  output=$(timeout "$TIMEOUT" "$sh" "$_TMPFILE" </dev/null 2>/dev/null) || true
  rm -f "$_TMPFILE"; _TMPFILE=""

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    case "$line" in
      PASS:*)
        echo "  PASS: [$sh] ${line#PASS:}"
        PASS=$((PASS + 1))
        total=$((total + 1))
        ;;
      FAIL:*)
        echo "  FAIL: [$sh] ${line#FAIL:}"
        FAIL=$((FAIL + 1))
        total=$((total + 1))
        ;;
    esac
  done <<< "$output"

  if [ "$total" -eq 0 ]; then
    echo "  FAIL: [$sh] invocation timed out or crashed (no output)"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Environment setup tests ==="

for sh in zsh bash; do
  command -v "$sh" >/dev/null 2>&1 || { echo "  SKIP: $sh not found"; continue; }
  echo ""
  echo "--- $sh ---"
  run_env_checks "$sh"
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
