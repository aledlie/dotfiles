#!/usr/bin/env bash
# Test utility functions from functions.sh
# Usage: ./tests/test-functions.sh

set -euo pipefail

PASS=0
FAIL=0
TIMEOUT=30

run_fn_checks() {
  local sh="$1"
  local fn_exists tmpfile
  if [ "$sh" = "zsh" ]; then
    fn_exists="whence"
  else
    fn_exists="declare -f"
  fi

  tmpfile=$(mktemp "${TMPDIR:-/tmp}/fn-test-XXXXXX.sh")

  # Pass shell-specific command via env var so heredoc can stay single-quoted
  cat > "$tmpfile" <<'SCRIPT'
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

# --- Function existence ---
for fn in load_doppler_cache doppler_get doppler_cache_info doppler_cache_has doppler_cache_debug dirsize mkcd extract findproc backup weather git_current_branch newbranch; do
  _check "function $fn defined" "$FN_EXISTS $fn"
done

# --- doppler_get behavior ---
result=$(doppler_get "NONEXISTENT_KEY_12345" "fallback_value")
_check "doppler_get returns default for missing key" '[ "$result" = "fallback_value" ]'

result=$(doppler_get "NONEXISTENT_KEY_12345")
_check "doppler_get returns empty for missing key without default" '[ -z "$result" ]'

result=$(doppler_get "" "empty_key_default")
_check "doppler_get returns default for empty key" '[ "$result" = "empty_key_default" ]'

# --- doppler_cache_info output ---
info=$(doppler_cache_info)
_check "doppler_cache_info shows project" 'echo "$info" | grep -q "Project:"'
_check "doppler_cache_info shows config" 'echo "$info" | grep -q "Config:"'
_check "doppler_cache_info shows secrets count" 'echo "$info" | grep -q "Secrets:"'

# --- mkcd behavior ---
_mkcd_parent=$(mktemp -d)
test_dir="$_mkcd_parent/mkcd_test"
(
  mkcd "$test_dir"
  _check "mkcd creates directory" '[ -d "$test_dir" ]'
  _check "mkcd changes to directory" '[ "$(pwd)" = "$test_dir" ]'
)
rm -rf "$_mkcd_parent"

# --- backup behavior ---
_backup_dir=$(mktemp -d)
test_file="$_backup_dir/testfile"
echo "test content" > "$test_file"
backup "$test_file"
backup_file=$(printf '%s\n' "$test_file".backup.* | head -1)
_check "backup creates timestamped copy" '[ -n "$backup_file" ] && [ -f "$backup_file" ]'
_check "backup preserves content" 'diff -q "$test_file" "$backup_file"'
rm -rf "$_backup_dir"

# --- git_current_branch ---
cd "$DOTFILES_DIR"
branch=$(git_current_branch)
_check "git_current_branch returns non-empty" '[ -n "$branch" ]'

# --- extract error handling ---
result=$(extract "/nonexistent/file.tar.gz" 2>&1) || true
_check "extract reports error for missing file" 'echo "$result" | grep -q "not a valid file"'
SCRIPT

  local output total=0
  output=$(FN_EXISTS="$fn_exists" timeout "$TIMEOUT" "$sh" "$tmpfile" </dev/null 2>/dev/null) || true
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

echo "=== Utility function tests ==="

for sh in zsh bash; do
  command -v "$sh" >/dev/null 2>&1 || { echo "  SKIP: $sh not found"; continue; }
  echo ""
  echo "--- $sh ---"
  run_fn_checks "$sh"
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
