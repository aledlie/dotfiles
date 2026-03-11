#!/usr/bin/env bash
# Test alias definitions and static exports from aliases.sh
# Usage: ./tests/test-aliases.sh

set -euo pipefail

PASS=0
FAIL=0
TIMEOUT=30

_TMPFILE=""
_cleanup() { rm -f "$_TMPFILE"; }
trap '_cleanup' EXIT INT TERM

run_alias_checks() {
  local sh="$1"
  local alias_check_cmd
  if [ "$sh" = "zsh" ]; then
    alias_check_cmd="whence -w"
  else
    alias_check_cmd="alias"
  fi

  _TMPFILE=$(mktemp "${TMPDIR:-/tmp}/alias-test-XXXXXX.sh")

  # Pass shell-specific command via env var so heredoc stays single-quoted
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

# --- Convenience aliases ---
_check "alias ll defined" "$ALIAS_CHECK ll"
_check "alias la defined" "$ALIAS_CHECK la"
_check "alias l defined"  "$ALIAS_CHECK l"
_check "alias .. defined" "$ALIAS_CHECK .."
_check "alias ... defined" "$ALIAS_CHECK ..."
_check "alias .... defined" "$ALIAS_CHECK ...."

# --- Static Doppler project exports ---
_check "DOPPLER_PROJECT_INTEGRITY set" '[ "$DOPPLER_PROJECT_INTEGRITY" = "integrity-studio" ]'
_check "DOPPLER_PROJECT_ANALYTICS set" '[ "$DOPPLER_PROJECT_ANALYTICS" = "analyticsbot" ]'
_check "DOPPLER_CONFIG_DEFAULT is dev" '[ "$DOPPLER_CONFIG_DEFAULT" = "dev" ]'
_check "DOPPLER_CONFIG_PRODUCTION is production" '[ "$DOPPLER_CONFIG_PRODUCTION" = "production" ]'

# --- OTEL static exports ---
_check "OTEL_EXPORTER_OTLP_PROTOCOL set" '[ "$OTEL_EXPORTER_OTLP_PROTOCOL" = "http/protobuf" ]'
_check "OTEL_EXPORTER_OTLP_COMPRESSION set" '[ "$OTEL_EXPORTER_OTLP_COMPRESSION" = "gzip" ]'
_check "OTEL_SERVICE_NAME set" '[ "$OTEL_SERVICE_NAME" = "claude-code-hooks" ]'

# --- Sentry static exports ---
_check "SENTRY_DISPLAY_NAME set" '[ "$SENTRY_DISPLAY_NAME" = "integrity" ]'
_check "SENTRY_ORG_SLUG set" '[ "$SENTRY_ORG_SLUG" = "integrity-jq" ]'

# --- macOS-specific aliases (only on macOS) ---
if [ "$PLATFORM" = "macos" ]; then
  _check "alias localip defined" "$ALIAS_CHECK localip"
  _check "alias flush defined" "$ALIAS_CHECK flush"
  _check "alias update defined" "$ALIAS_CHECK update"
fi
SCRIPT

  local output total=0
  output=$(ALIAS_CHECK="$alias_check_cmd" timeout "$TIMEOUT" "$sh" "$_TMPFILE" </dev/null 2>/dev/null) || true
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

echo "=== Alias and export tests ==="

for sh in zsh bash; do
  command -v "$sh" >/dev/null 2>&1 || { echo "  SKIP: $sh not found"; continue; }
  echo ""
  echo "--- $sh ---"
  run_alias_checks "$sh"
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
