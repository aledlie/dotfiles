# Project Backlog

## High (P2)

## Medium (P3)

#### M7: Fix chruby auto.sh unset variable warning
**Priority**: P3 | **Source**: manual | **Commit**: 08b96f8
`chruby/auto.sh` throws `RUBY_AUTO_VERSION: parameter not set` warnings in non-interactive shells because it references an unset variable without quoting. Workaround applied: skip chruby loading in non-interactive shells via `[[ -t 0 ]]` check in `shell/common.sh`. Permanent fix: modify installed chruby package's `auto.sh` line 19 to quote `$RUBY_AUTO_VERSION` as `"$RUBY_AUTO_VERSION"`.

#### M6: Migrate CLAUDE_* consumers to OTEL_* env vars
**Priority**: P3 | **Source**: manual
Primary exports renamed to `OTEL_CONFIG_DIR`, `OTEL_LOGS_DIR`, etc. in `shell/common.sh`. Backward-compat `CLAUDE_*` aliases still exported. Remaining: update `~/.claude/hooks/lib/constants.ts`, `~/.claude/scripts/lib/colors.{js,sh}`, `~/.claude/scripts/env/`, and `~/code/jobs/` consumers to read `OTEL_*` instead of `CLAUDE_*`, then remove the compat aliases.

## Low (P4)

## Done

#### M6: Migrate CLAUDE_* consumers to OTEL_* env vars
**Priority**: P3 | **Source**: manual | **Commit**: 42d8ba61, 13e3c583, 9d43e47, 99b6f59
Consumers in `hooks/lib/constants.ts`, `hooks/lib/otel-monitor.ts`, `scripts/lib/colors.{js,sh}`, `scripts/env/health.sh`, `scripts/env/check-environment.js`, and `jobs/sidequest/workers/claude-health-worker.ts` updated to prefer `OTEL_*` vars with backward-compat fallback to `CLAUDE_*`.

#### M3: Fix test-shell-startup.sh hanging + bash 3.2 compat
**Priority**: P3 | **Source**: manual
Replaced bash 4.2+ `-v` operator in `functions.sh` (`doppler_get`, `doppler_cache_debug`) with bash 3.2-compatible `${var+set}` parameter expansion. Test harness already batches checks into single shell invocation per shell type.

