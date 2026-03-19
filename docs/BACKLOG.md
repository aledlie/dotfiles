# Project Backlog

## High (P2)

## Medium (P3)

#### M6: Migrate CLAUDE_* consumers to OTEL_* env vars
**Priority**: P3 | **Source**: manual
Primary exports renamed to `OTEL_CONFIG_DIR`, `OTEL_LOGS_DIR`, etc. in `shell/common.sh`. Backward-compat `CLAUDE_*` aliases still exported. Remaining: update `~/.claude/hooks/lib/constants.ts`, `~/.claude/scripts/lib/colors.{js,sh}`, `~/.claude/scripts/env/`, and `~/code/jobs/` consumers to read `OTEL_*` instead of `CLAUDE_*`, then remove the compat aliases.

## Low (P4)

## Done

#### M3: Fix test-shell-startup.sh hanging + bash 3.2 compat
**Priority**: P3 | **Source**: manual
Replaced bash 4.2+ `-v` operator in `functions.sh` (`doppler_get`, `doppler_cache_debug`) with bash 3.2-compatible `${var+set}` parameter expansion. Test harness already batches checks into single shell invocation per shell type.

