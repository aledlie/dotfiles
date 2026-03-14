# Project Backlog

## Critical (P1)

#### C1: Remove source common.sh from install.sh ✅ Done
**Priority**: P1 | **Source**: code-review + auto-error-resolver session
Under `set -e`, sourcing `common.sh` at line 12 before function definitions will abort the installer silently if `brew`, `chruby`, or `doppler` are unavailable. `common.sh` is an interactive shell environment file and is never used by `install.sh`. Remove line 12 entirely. -- `install.sh:12`

## High (P2)

#### H5: Replace eval "$@" pattern with safer execution in test helpers ✅ Done
**Priority**: P2 | **Source**: code-review session (test files)
The `_check` helper in all test files uses `eval "$@"` which is unsafe despite current hardcoded inputs. Replace with `"$@"` or subshell execution `( "$@" )` to prevent future injection if arguments become dynamic. -- `tests/test-aliases.sh:33`, `tests/test-common-env.sh:32`, `tests/test-functions.sh:33`, `tests/test-shell-startup.sh:40`

#### H6: Fix _TMPFILE global race condition with function-scoped lifetime ✅ Done
**Priority**: P2 | **Source**: code-review session (test files)
Global `_TMPFILE` variable with both explicit `rm -f` and `trap EXIT` cleanup is fragile. Replace with `local tmpfile=$(mktemp ...)` for function-scoped lifetime and single cleanup via trap. -- `tests/test-aliases.sh:12-14`, `tests/test-common-env.sh:12-14`, `tests/test-functions.sh:12-14`, `tests/test-shell-startup.sh:12-14`

#### H7: Guard mkcd subshell cwd changes in test-functions.sh ✅ Done
**Priority**: P2 | **Source**: code-review session
test-functions.sh line 64-68: mkcd changes working directory in generated script, early exit leaves child in deleted directory. Wrap mkcd block in subshell: `( mkcd "$test_dir"; ... )` before cleanup. -- `tests/test-functions.sh:64-68`

#### H8: Remove misleading FN_EXISTS environment prefix in test-functions.sh ✅ Done
**Priority**: P2 | **Source**: code-review session
Line 27 has `FN_EXISTS=... cat > "$_TMPFILE"` which sets env on cat (ignored), not on the heredoc. The actual export is at line 91. Remove line 27 prefix to avoid confusion. -- `tests/test-functions.sh:27`

#### H9: Guard Doppler-dependent assertions in test-shell-startup.sh for offline environments ✅ Done
**Priority**: P2 | **Source**: code-review session
Lines 51-53 assert GITHUB_TOKEN, OTEL_API_KEY, STRIPE_API_KEY are non-empty. These fail if Doppler is offline or cache is stale, making tests flaky in CI. Either guard with reachability check or move to separate `test-integration` target. -- `tests/test-shell-startup.sh:51-53`

#### H10: Validate identifier names in doppler_export function
**Priority**: P2 | **Source**: code-reviewer agent (2026-03-14)
`doppler_export "$var"=...` should validate that `$var` is a legal identifier before exporting. If a caller passes a string containing `=` or special characters (e.g. `doppler_export "FOO=bar BAZ"`), the `export` builtin will misparse it. Add regex check: `[[ "$var" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]` before exporting. -- `shell/doppler-secrets.sh:145`

#### H1: Implement timestamped backup directory to prevent overwrite loss ✅ Done
**Priority**: P2 | **Source**: code-review + auto-error-resolver session
Currently `backup_file` uses `mv -f` to a fixed `$BACKUP_DIR`, which silently overwrites previous backups on re-run. Users lose their original backup. Change `BACKUP_DIR` to include timestamp: `$HOME/.dotfiles.backup/$(date +%Y%m%dT%H%M%S)`. -- `install.sh:9`

#### H2: Quote $BACKUP_DIR in ls command to handle paths with spaces ✅ Done
**Priority**: P2 | **Source**: code-review session
Line 90 has unquoted `$BACKUP_DIR` in command substitution: `ls -A $BACKUP_DIR` will word-split if path contains spaces. Fix: `ls -A "$BACKUP_DIR"`. -- `install.sh:90`

#### H3: Redirect print_error and print_warning output to stderr ✅ Done
**Priority**: P2 | **Source**: code-review session
`print_error` and `print_warning` write to stdout, making them invisible when caller redirects stdout. Add `>&2` to both functions. -- `install.sh:27,31`

#### H4: Fix create_symlink to handle directories and symlinks correctly ✅ Done
**Priority**: P2 | **Source**: code-review + auto-error-resolver session
Line 56 checks only `-f` (regular files), skipping directories and symlinks. Use `-e` (exists) instead to handle all file types: `if [ -e "$DOTFILES_DIR/$source" ] || [ -L "$DOTFILES_DIR/$source" ]`. -- `install.sh:56`

## Medium (P3)

#### M3: Fix alias ll check in test-common-env.sh for non-interactive bash ✅ Done
**Priority**: P3 | **Source**: code-review session
Line 68 checks `alias ll` inside non-interactive bash script where aliases are disabled by default. Add `shopt -s expand_aliases` in generated script header, or use `type ll` which works in both bash/zsh. -- `tests/test-common-env.sh:68`

#### M4: Replace ls glob with safer pattern matching in test-functions.sh ✅ Done
**Priority**: P3 | **Source**: code-review session
Line 75 uses `ls "$test_file".backup.* | head -1` for fragile pattern matching. Use `$(echo "$test_file".backup.* | tr ' ' '\n' | head -1)` or direct glob for robustness. -- `tests/test-functions.sh:75`

#### M5: Use grep -qF consistently to avoid regex metacharacter issues ✅ Done
**Priority**: P3 | **Source**: code-review session
Lines 53, 58 in test-common-env.sh use `grep -q` without fixed-string flag. If `$GOPATH` contains regex metacharacters (e.g. `.`), pattern matches incorrectly. Use `grep -qF` consistently (lines 43-44 already do). -- `tests/test-common-env.sh:53,58`

#### M1: Add mkdir -p guard inside backup_file for robustness ✅ Done
**Priority**: P3 | **Source**: auto-error-resolver session
`backup_file` assumes `$BACKUP_DIR` exists (created by `create_backup_dir` earlier), but this couples the functions. Add `mkdir -p "$BACKUP_DIR"` inside `backup_file` to make it self-contained and prevent failures if called out of order. -- `install.sh:43-48`

#### M2: Prevent ln -sf from creating symlinks inside existing same-named directories ✅ Done
**Priority**: P3 | **Source**: auto-error-resolver session
`ln -sf` at line 58 will create a symlink *inside* an existing directory with the same name instead of replacing it. Verify target does not exist as a directory before calling `ln`, or use `rm -rf` before `ln -sf`. -- `install.sh:58`

#### M6: Rename CLAUDE_* env vars to OBTOOL_* across dotfiles and hooks
**Priority**: P3 | **Source**: manual
`CLAUDE_CONFIG_DIR`, `CLAUDE_LOGS_DIR`, `CLAUDE_PROJECT_DIR`, `CLAUDE_TELEMETRY_DIR` should be renamed to `OBTOOL_CONFIG_DIR`, `OBTOOL_LOGS_DIR`, `OBTOOL_PROJECT_DIR`, `OBTOOL_TELEMETRY_DIR` to decouple from upstream Claude Code naming. Update `shell/aliases.sh`, `~/.claude/hooks/lib/constants.ts`, and all hook consumers. Keep `CLAUDE_*` as fallback aliases during migration.

#### M7: Add user feedback to dirsize when no directories exceed 1M
**Priority**: P3 | **Source**: code-reviewer agent (2026-03-14)
`dirsize` silently discards all `K`-sized directories via `grep -E '^ *[0-9.]*[MG]'` with no feedback. A user running `dirsize` in a directory of small files gets no output and no explanation. Consider printing a "nothing above 1M" message when tmpfile is empty after filtering. -- `shell/functions.sh:117-119`

#### M8: Add argument validation to newbranch function
**Priority**: P3 | **Source**: code-reviewer agent (2026-03-14)
`newbranch ""` runs `git checkout -b ""` and emits a confusing git error. Add guard: `[[ -n "$1" ]] || { echo "Usage: newbranch <name>" >&2; return 1; }` to catch empty arguments early. -- `shell/functions.sh:166-168`

## Low (P4)

#### L1: Replace echo -e with printf for POSIX portability ✅ Done
**Priority**: P4 | **Source**: code-review session
`echo -e` behavior is undefined in POSIX sh. Replace with `printf` for portability (shebang is `#!/bin/bash` so this works, but is fragile). -- `install.sh:23,27,31`

#### L2: Remove unused $@ argument to main function ✅ Done
**Priority**: P4 | **Source**: code-review session
Line 95 passes `$@` to `main`, but `main()` never parses arguments. Users could pass `--dry-run` with no effect. Either parse arguments or change to `main` (no args). -- `install.sh:95`

#### L3: PATH grows unboundedly on repeated sources ✅ Done
**Priority**: P4 | **Source**: code-review session (common.sh)
Every re-source of `common.sh` prepends all PATH entries again with no deduplication. Consider `typeset -U path` for zsh or membership checks before prepending. -- `common.sh:24,28,31,41,46`

#### L4: Export colorflag for subprocess visibility ✅ Done
**Priority**: P4 | **Source**: code-review session (common.sh)
`colorflag` is set but not exported, so subprocesses cannot see it. Add `export colorflag` if needed downstream. -- `common.sh:71,79`

#### L5: Add input validation to qcommit function ✅ Done
**Priority**: P4 | **Source**: code-review session (functions.sh)
`qcommit` uses `git add -A` which stages everything including untracked secrets/artifacts. Consider documenting this as a known footgun or adding a guard. -- `functions.sh:149-151`

#### L6: Document setup_tcl_tk_flags as intentional no-op stub
**Priority**: P4 | **Source**: code-reviewer agent (2026-03-14)
`setup_tcl_tk_flags() { :; }` is defined as a global no-op stub that always exists in the environment. This design is intentional, but not documented at the call site. Any script checking `typeset -f setup_tcl_tk_flags` to detect tcl-tk support will get a false positive. Add a comment noting "this is an intentional no-op stub" to prevent confusion. -- `shell/common.sh:99`

---

## Shell Code Review (2026-03-14)

### Critical (P1)

#### CR1: Lazy-load Doppler secrets instead of eager export ✅ Done
**Priority**: P1 | **Source**: code-reviewer agent (shell pack review)
50+ secrets (`GITHUB_TOKEN`, `STRIPE_API_KEY`, `OPENAI_API_KEY`, `JWT_SECRET`, etc.) are exported as environment variables on every shell startup. Exported vars are visible to every subprocess (`ps auxe`, `/proc/<pid>/environ`, npm scripts, build tools). Read secrets lazily at the call site or via `direnv` `.envrc` per-project instead of exporting globally. -- `shell/aliases.sh:407-544`

### High (P2)

#### CR3: qcommit stages all files including secrets ✅ Done
**Priority**: P2 | **Source**: code-reviewer agent (shell pack review)
`qcommit` uses `git add -A` unconditionally, risking staging `.env` files, credential dumps, and Doppler cache artifacts. Remove the function or replace `git add -A` with explicit file staging. -- `shell/functions.sh:149`

#### CR4: Remove hardcoded absolute PATH in zsh/.prompt.zsh ✅ Done
**Priority**: P2 | **Source**: code-reviewer agent (shell pack review)
Hardcoded `/Users/alyshialedlie` throughout a 200+ character `PATH` assignment. Duplicates entries already managed by `_path_prepend` in `common.sh`. Appears to be a leftover snapshot. Delete or rewrite using `$HOME`. -- `shell/zsh/.prompt.zsh:228-229`

### Medium (P3)

#### CR7: load_doppler_cache silently swallows failures ✅ Done
**Priority**: P3 | **Source**: code-reviewer agent (shell pack review)
If `doppler` or `jq` fails (network error, auth failure), the `while` loop exits with an empty cache and no error. All subsequent `doppler_get` calls return empty strings. The caller in `common.sh` suppresses output with `>/dev/null 2>&1 || true`. Add stderr warning on failure. -- `shell/functions.sh:826-834`

#### CR10: dirsize glob expansion unquoted and brittle ✅ Done
**Priority**: P3 | **Source**: code-reviewer agent (shell pack review)
`du -shx * .[a-zA-Z0-9_]*` fails in empty directories (error suppressed by `2>/dev/null`). Dotfile glob misses entries like `..hidden-file`. Use `du -shx -- */ .[^.]*/` or similar. -- `shell/functions.sh:893`

#### CR11: colorflag/ls alias in aliases.sh overrides common.sh unconditionally ✅ Done
**Priority**: P3 | **Source**: code-reviewer agent (shell pack review)
`aliases.sh` unconditionally sets `colorflag="-G"` and `alias ls='gls --color=auto'` without a platform check, overriding the conditional logic in `common.sh`. Breaks `ls` on Linux or Mac without coreutils. Remove these lines and rely on `common.sh`. -- `shell/aliases.sh:549-550`
