# Changelog - 2026-03-14

Migration of completed backlog items.

## Critical (P1)

| ID | Title | Resolution |
|----|-------|-----------|
| C1 | Remove source common.sh from install.sh | Removed problematic sourcing that would abort installer silently if brew/chruby/doppler unavailable. Refactored install.sh to not depend on interactive shell environment. |
| CR1 | Lazy-load Doppler secrets instead of eager export | Implemented lazy-loading of 50+ secrets via doppler_get(), secret(), and doppler_export() functions. Secrets now loaded on-demand instead of exported on startup, improving security posture and subprocess isolation. |

## High (P2)

| ID | Title | Resolution |
|----|-------|-----------|
| H1 | Implement timestamped backup directory to prevent overwrite loss | Changed BACKUP_DIR to include timestamp: `$HOME/.dotfiles.backup/$(date +%Y%m%dT%H%M%S)` to prevent silent overwrites of previous backups. |
| H2 | Quote $BACKUP_DIR in ls command to handle paths with spaces | Fixed unquoted variable expansion in `ls -A $BACKUP_DIR` to `ls -A "$BACKUP_DIR"`. |
| H3 | Redirect print_error and print_warning output to stderr | Added `>&2` redirection to both functions so they output to stderr instead of stdout. |
| H4 | Fix create_symlink to handle directories and symlinks correctly | Changed `-f` check to `-e` to handle all file types (regular files, directories, symlinks). |
| H5 | Replace eval "$@" pattern with safer execution in test helpers | Replaced unsafe `eval "$@"` in _check helper with direct command execution `"$@"` to prevent injection. Applied across test-aliases.sh, test-common-env.sh, test-functions.sh, test-shell-startup.sh. |
| H6 | Fix _TMPFILE global race condition with function-scoped lifetime | Replaced global _TMPFILE variable with function-scoped `local tmpfile=$(mktemp ...)` and single cleanup via trap EXIT. |
| H7 | Guard mkcd subshell cwd changes in test-functions.sh | Wrapped mkcd block in subshell to prevent early exit from leaving child process in deleted directory. |
| H8 | Remove misleading FN_EXISTS environment prefix in test-functions.sh | Removed line 27 prefix that incorrectly set env on cat instead of heredoc, eliminating confusion. |
| H9 | Guard Doppler-dependent assertions in test-shell-startup.sh for offline environments | Added reachability checks to GITHUB_TOKEN, OTEL_API_KEY, STRIPE_API_KEY assertions, making tests robust to offline Doppler. |
| H10 | Validate identifier names in doppler_export function | Added regex validation `[[ ! "$var" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]` to reject invalid identifiers before exporting, preventing misparse of special characters in export variable names. |
| CR3 | qcommit stages all files including secrets | Completely removed qcommit function (replaced by explicit git add patterns) to prevent accidental staging of .env files and secrets. |
| CR4 | Remove hardcoded absolute PATH in zsh/.prompt.zsh | Removed hardcoded `/Users/alyshialedlie` entries and replaced with $HOME references to use system PATH management from common.sh. |

## Medium (P3)

| ID | Title | Resolution |
|----|-------|-----------|
| M1 | Add mkdir -p guard inside backup_file for robustness | Added `mkdir -p "$BACKUP_DIR"` inside backup_file to decouple from create_backup_dir and make function self-contained. |
| M2 | Prevent ln -sf from creating symlinks inside existing same-named directories | Added directory existence check before `ln -sf` to prevent creating symlinks inside existing directories. |
| M3 | Fix alias ll check in test-common-env.sh for non-interactive bash | Added `shopt -s expand_aliases` in generated script header, enabling alias expansion in non-interactive bash. |
| M4 | Replace ls glob with safer pattern matching in test-functions.sh | Replaced fragile `ls "$test_file".backup.*` with direct glob expansion `$(echo "$test_file".backup.* | tr ' ' '\n' | head -1)`. |
| M5 | Use grep -qF consistently to avoid regex metacharacter issues | Converted all `grep -q` calls to `grep -qF` to avoid regex metacharacter mismatches in patterns like $GOPATH containing `.`. |
| M7 | Add user feedback to dirsize when no directories exceed 1M | Added empty-file check `[[ ! -s "$tmpfile" ]]` to print "No directories above 1M" when filter returns no results, providing user feedback instead of silent empty output. |
| M8 | Add argument validation to newbranch function | Added empty-argument guard `[[ -n "$1" ]] \|\| { echo "Usage: newbranch <name>" >&2; return 1; }` to catch empty arguments early instead of passing to git. |
| CR7 | load_doppler_cache silently swallows failures | Added stderr warning when doppler or jq fails (network error, auth failure), making cache failures visible. |
| CR10 | dirsize glob expansion unquoted and brittle | Fixed glob expansion to `du -shx -- */ .[^.]*/` to handle empty directories and dotfiles correctly. |
| CR11 | colorflag/ls alias in aliases.sh overrides common.sh unconditionally | Removed unconditional colorflag and ls alias overrides; now relies on conditional platform checks in common.sh. |

## Low (P4)

| ID | Title | Resolution |
|----|-------|-----------|
| L1 | Replace echo -e with printf for POSIX portability | Replaced all `echo -e` calls with `printf` for POSIX sh compatibility. |
| L2 | Remove unused $@ argument to main function | Changed `main "$@"` to `main` (no args) since main() never parses arguments. |
| L3 | PATH grows unboundedly on repeated sources | Added `typeset -U path` for zsh and membership checks before prepending to prevent duplicates on re-source. |
| L4 | Export colorflag for subprocess visibility | Added `export colorflag` so subprocesses can access the variable. |
| L5 | Add input validation to qcommit function | Documented as known footgun that qcommit stages all files; now removed entirely (replaced by explicit git add patterns). |
