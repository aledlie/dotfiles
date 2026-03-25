# Project Backlog

## High (P2)

## Medium (P3)

## Low (P4)

## Done

#### M8: Fix OTEL SDK API incompatibilities in lib/otel.ts
**Priority**: P3 | **Source**: investigation | **Commit**: 41ad06f1, b15dd13c
Fixed 4 API breaks from SDK version drift (resources v2.x, sdk-trace-base v2.x, sdk-logs v0.213.0):
`detectResourcesSync+*DetectorSync` → `detectResources+*Detector`; `new Resource()` → `resourceFromAttributes()`; `parentSpanId` → dual-path shim for v1/v2 pnpm mismatch; `addLogRecordProcessor()` → `processors[]` constructor param.

#### M7: Fix chruby auto.sh unset variable warning
**Priority**: P3 | **Source**: manual | **Commit**: 08b96f8
`chruby/auto.sh` referenced unset `$RUBY_AUTO_VERSION` in non-interactive shells. Workaround: skip chruby loading in non-interactive shells via `[[ -t 0 ]]` check in `shell/common.sh`. Permanent fix already in installed chruby package — all `$RUBY_AUTO_VERSION` references are quoted.

#### M6: Migrate CLAUDE_* consumers to OTEL_* env vars
**Priority**: P3 | **Source**: manual | **Commit**: 42d8ba61, 13e3c583, 9d43e47, 99b6f59
Consumers in `hooks/lib/constants.ts`, `hooks/lib/otel-monitor.ts`, `scripts/lib/colors.{js,sh}`, `scripts/env/health.sh`, `scripts/env/check-environment.js`, and `jobs/sidequest/workers/claude-health-worker.ts` updated to prefer `OTEL_*` vars with backward-compat fallback to `CLAUDE_*`.

#### M3: Fix test-shell-startup.sh hanging + bash 3.2 compat
**Priority**: P3 | **Source**: manual
Replaced bash 4.2+ `-v` operator in `functions.sh` (`doppler_get`, `doppler_cache_debug`) with bash 3.2-compatible `${var+set}` parameter expansion. Test harness already batches checks into single shell invocation per shell type.

