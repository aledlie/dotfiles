# Project Backlog

## Critical (P1)

#### C1: Remove source common.sh from install.sh
**Priority**: P1 | **Source**: code-review + auto-error-resolver session
Under `set -e`, sourcing `common.sh` at line 12 before function definitions will abort the installer silently if `brew`, `chruby`, or `doppler` are unavailable. `common.sh` is an interactive shell environment file and is never used by `install.sh`. Remove line 12 entirely. -- `install.sh:12`

## High (P2)

#### H5: Replace eval "$@" pattern with safer execution in test helpers ✅ Done
**Priority**: P2 | **Source**: code-review session (test files)
The `_check` helper in all test files uses `eval "$@"` which is unsafe despite current hardcoded inputs. Replace with `"$@"` or subshell execution `( "$@" )` to prevent future injection if arguments become dynamic. -- `tests/test-aliases.sh:33`, `tests/test-common-env.sh:32`, `tests/test-functions.sh:33`, `tests/test-shell-startup.sh:40`

#### H6: Fix _TMPFILE global race condition with function-scoped lifetime ✅ Done
**Priority**: P2 | **Source**: code-review session (test files)
Global `_TMPFILE` variable with both explicit `rm -f` and `trap EXIT` cleanup is fragile. Replace with `local tmpfile=$(mktemp ...)` for function-scoped lifetime and single cleanup via trap. -- `tests/test-aliases.sh:12-14`, `tests/test-common-env.sh:12-14`, `tests/test-functions.sh:12-14`, `tests/test-shell-startup.sh:12-14`

#### H7: Guard mkcd subshell cwd changes in test-functions.sh
**Priority**: P2 | **Source**: code-review session
test-functions.sh line 64-68: mkcd changes working directory in generated script, early exit leaves child in deleted directory. Wrap mkcd block in subshell: `( mkcd "$test_dir"; ... )` before cleanup. -- `tests/test-functions.sh:64-68`

#### H8: Remove misleading FN_EXISTS environment prefix in test-functions.sh
**Priority**: P2 | **Source**: code-review session
Line 27 has `FN_EXISTS=... cat > "$_TMPFILE"` which sets env on cat (ignored), not on the heredoc. The actual export is at line 91. Remove line 27 prefix to avoid confusion. -- `tests/test-functions.sh:27`

#### H9: Guard Doppler-dependent assertions in test-shell-startup.sh for offline environments
**Priority**: P2 | **Source**: code-review session
Lines 51-53 assert GITHUB_TOKEN, OTEL_API_KEY, STRIPE_API_KEY are non-empty. These fail if Doppler is offline or cache is stale, making tests flaky in CI. Either guard with reachability check or move to separate `test-integration` target. -- `tests/test-shell-startup.sh:51-53`

#### H1: Implement timestamped backup directory to prevent overwrite loss
**Priority**: P2 | **Source**: code-review + auto-error-resolver session
Currently `backup_file` uses `mv -f` to a fixed `$BACKUP_DIR`, which silently overwrites previous backups on re-run. Users lose their original backup. Change `BACKUP_DIR` to include timestamp: `$HOME/.dotfiles.backup/$(date +%Y%m%dT%H%M%S)`. -- `install.sh:9`

#### H2: Quote $BACKUP_DIR in ls command to handle paths with spaces
**Priority**: P2 | **Source**: code-review session
Line 90 has unquoted `$BACKUP_DIR` in command substitution: `ls -A $BACKUP_DIR` will word-split if path contains spaces. Fix: `ls -A "$BACKUP_DIR"`. -- `install.sh:90`

#### H3: Redirect print_error and print_warning output to stderr
**Priority**: P2 | **Source**: code-review session
`print_error` and `print_warning` write to stdout, making them invisible when caller redirects stdout. Add `>&2` to both functions. -- `install.sh:27,31`

#### H4: Fix create_symlink to handle directories and symlinks correctly
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

#### M1: Add mkdir -p guard inside backup_file for robustness
**Priority**: P3 | **Source**: auto-error-resolver session
`backup_file` assumes `$BACKUP_DIR` exists (created by `create_backup_dir` earlier), but this couples the functions. Add `mkdir -p "$BACKUP_DIR"` inside `backup_file` to make it self-contained and prevent failures if called out of order. -- `install.sh:43-48`

#### M2: Prevent ln -sf from creating symlinks inside existing same-named directories
**Priority**: P3 | **Source**: auto-error-resolver session
`ln -sf` at line 58 will create a symlink *inside* an existing directory with the same name instead of replacing it. Verify target does not exist as a directory before calling `ln`, or use `rm -rf` before `ln -sf`. -- `install.sh:58`

## Low (P4)

#### L1: Replace echo -e with printf for POSIX portability
**Priority**: P4 | **Source**: code-review session
`echo -e` behavior is undefined in POSIX sh. Replace with `printf` for portability (shebang is `#!/bin/bash` so this works, but is fragile). -- `install.sh:23,27,31`

#### L2: Remove unused $@ argument to main function
**Priority**: P4 | **Source**: code-review session
Line 95 passes `$@` to `main`, but `main()` never parses arguments. Users could pass `--dry-run` with no effect. Either parse arguments or change to `main` (no args). -- `install.sh:95`

#### L3: PATH grows unboundedly on repeated sources
**Priority**: P4 | **Source**: code-review session (common.sh)
Every re-source of `common.sh` prepends all PATH entries again with no deduplication. Consider `typeset -U path` for zsh or membership checks before prepending. -- `common.sh:24,28,31,41,46`

#### L4: Export colorflag for subprocess visibility
**Priority**: P4 | **Source**: code-review session (common.sh)
`colorflag` is set but not exported, so subprocesses cannot see it. Add `export colorflag` if needed downstream. -- `common.sh:71,79`

#### L5: Add input validation to qcommit function
**Priority**: P4 | **Source**: code-review session (functions.sh)
`qcommit` uses `git add -A` which stages everything including untracked secrets/artifacts. Consider documenting this as a known footgun or adding a guard. -- `functions.sh:149-151`
