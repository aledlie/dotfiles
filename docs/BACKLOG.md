# Project Backlog

## High (P2)

## Medium (P3)

#### M6: Rename CLAUDE_* env vars to OBTOOL_* across dotfiles and hooks
**Priority**: P3 | **Source**: manual
`CLAUDE_CONFIG_DIR`, `CLAUDE_LOGS_DIR`, `CLAUDE_PROJECT_DIR`, `CLAUDE_TELEMETRY_DIR` should be renamed to `OBTOOL_CONFIG_DIR`, `OBTOOL_LOGS_DIR`, `OBTOOL_PROJECT_DIR`, `OBTOOL_TELEMETRY_DIR` to decouple from upstream Claude Code naming. Update `shell/aliases.sh`, `~/.claude/hooks/lib/constants.ts`, and all hook consumers. Keep `CLAUDE_*` as fallback aliases during migration.

## Low (P4)

## Done

#### M3: Fix test-shell-startup.sh hanging + bash 3.2 compat
**Priority**: P3 | **Source**: manual
Replaced bash 4.2+ `-v` operator in `functions.sh` (`doppler_get`, `doppler_cache_debug`) with bash 3.2-compatible `${var+set}` parameter expansion. Test harness already batches checks into single shell invocation per shell type.

