#!/usr/bin/env bash
# Test that common.sh, aliases.sh, and functions.sh load at terminal startup
# Usage: ./tests/test-shell-startup.sh

set -euo pipefail

PASS=0
FAIL=0
TIMEOUT=30

# Run all checks for a shell in a single invocation.
# Each assert previously spawned a new process that sourced common.sh,
# triggering a Doppler network call every time. Batching into one invocation
# means load_doppler_cache runs once per shell type instead of once per check.
run_shell_checks() {
  local sh="$1"
  local fn_check_cmd alias_check_cmd tmpfile

  if [ "$sh" = "zsh" ]; then
    fn_check_cmd="whence"
    alias_check_cmd='whence -w ll | grep -q alias'
  else
    fn_check_cmd="declare -f"
    alias_check_cmd='alias ll'
  fi

  tmpfile=$(mktemp "${TMPDIR:-/tmp}/shell-test-XXXXXX.sh")

  # Write the probe (source line) separately to avoid unquoted heredoc expansion
  printf 'export DOTFILES_DIR="$HOME/dotfiles"\nsource "$DOTFILES_DIR/shell/common.sh"\n\n' > "$tmpfile"

  cat >> "$tmpfile" <<'SCRIPT'
_check() {
  local desc="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf 'PASS:%s\n' "$desc"
  else
    printf 'FAIL:%s\n' "$desc"
  fi
}
SCRIPT

  # Append shell-specific checks (these need variable interpolation)
  cat >> "$tmpfile" <<CHECKS
_check "common.sh sets PLATFORM"                    '[ -n "\$PLATFORM" ]'
_check "functions.sh defines load_doppler_cache"    '$fn_check_cmd load_doppler_cache'
_check "functions.sh defines doppler_get"           '$fn_check_cmd doppler_get'
_check "functions.sh defines doppler_cache_info"    '$fn_check_cmd doppler_cache_info'
if doppler secrets >/dev/null 2>&1; then
_check "secret returns GITHUB_TOKEN"                '[ "\$(secret GITHUB_TOKEN)" != "" ]'
_check "secret returns OTEL_API_KEY"                '[ "\$(secret OTEL_API_KEY)" != "" ]'
_check "secret returns STRIPE_API_KEY"              '[ "\$(secret STRIPE_API_KEY)" != "" ]'
_check "doppler cache is populated"                 '[ "\$(doppler_get GITHUB_TOKEN)" != "" ]'
fi
_check "aliases.sh defines ll alias"                '$alias_check_cmd'
CHECKS

  local output total=0
  output=$(timeout "$TIMEOUT" "$sh" "$tmpfile" </dev/null 2>/dev/null) || true
  rm -f "$tmpfile"

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

echo "=== Shell startup load tests ==="

for sh in zsh bash; do
  command -v "$sh" >/dev/null 2>&1 || { echo "  SKIP: $sh not found"; continue; }
  echo ""
  echo "--- $sh ---"
  run_shell_checks "$sh"
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
