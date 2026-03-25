# Project Backlog

## High (P2)

## Medium (P3)

#### M8: Fix OTEL SDK API incompatibilities in lib/otel.ts
**Priority**: P3 | **Source**: investigation
5 API breaks discovered from SDK version drift (v0.39.x → v0.40.x+):
1. `detectResourcesSync()` + `*DetectorSync` removed → use async `detectResources()`
2. `Resource` constructor → factory API (line 261)
3. `ReadableSpan.parentSpanId` property removed (line 136)
4. `LoggerProvider.addLogRecordProcessor()` renamed/removed (lines 313, 322)

Impact: 127 test failures, 3 test files fail at init. Requires either SDK downgrade to v0.39.x or refactor to async resource detection pattern. Recommend async refactor to align with modern OTEL best practices; affects `initTelemetry()` caller pattern.

#### M7: Fix chruby auto.sh unset variable warning
**Priority**: P3 | **Source**: manual | **Commit**: 08b96f8
`chruby/auto.sh` throws `RUBY_AUTO_VERSION: parameter not set` warnings in non-interactive shells because it references an unset variable without quoting. Workaround applied: skip chruby loading in non-interactive shells via `[[ -t 0 ]]` check in `shell/common.sh`. Permanent fix: modify installed chruby package's `auto.sh` line 19 to quote `$RUBY_AUTO_VERSION` as `"$RUBY_AUTO_VERSION"`.

## Low (P4)

## Done

#### M6: Migrate CLAUDE_* consumers to OTEL_* env vars
**Priority**: P3 | **Source**: manual | **Commit**: 42d8ba61, 13e3c583, 9d43e47, 99b6f59
Consumers in `hooks/lib/constants.ts`, `hooks/lib/otel-monitor.ts`, `scripts/lib/colors.{js,sh}`, `scripts/env/health.sh`, `scripts/env/check-environment.js`, and `jobs/sidequest/workers/claude-health-worker.ts` updated to prefer `OTEL_*` vars with backward-compat fallback to `CLAUDE_*`.

#### M3: Fix test-shell-startup.sh hanging + bash 3.2 compat
**Priority**: P3 | **Source**: manual
Replaced bash 4.2+ `-v` operator in `functions.sh` (`doppler_get`, `doppler_cache_debug`) with bash 3.2-compatible `${var+set}` parameter expansion. Test harness already batches checks into single shell invocation per shell type.

