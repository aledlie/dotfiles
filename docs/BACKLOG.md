# Project Backlog

## High (P2)

## Medium (P3)

#### M6: Rename CLAUDE_* env vars to OBTOOL_* across dotfiles and hooks
**Priority**: P3 | **Source**: manual
`CLAUDE_CONFIG_DIR`, `CLAUDE_LOGS_DIR`, `CLAUDE_PROJECT_DIR`, `CLAUDE_TELEMETRY_DIR` should be renamed to `OBTOOL_CONFIG_DIR`, `OBTOOL_LOGS_DIR`, `OBTOOL_PROJECT_DIR`, `OBTOOL_TELEMETRY_DIR` to decouple from upstream Claude Code naming. Update `shell/aliases.sh`, `~/.claude/hooks/lib/constants.ts`, and all hook consumers. Keep `CLAUDE_*` as fallback aliases during migration.

## Low (P4)

