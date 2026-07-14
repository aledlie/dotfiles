# Project Backlog

## Open Items

### Medium (P3)

- **Fresh-clone vim bootstrap** — commit 12965de moved plugin management to
  vim-plug only (cleared `.gitmodules`, gitignored `vim/plugin/`), so a fresh
  clone has zero plugins until `:PlugInstall` is run. Automate it (install.sh
  step or `vim +PlugInstall +qall`) and document in README/DATA_FLOW.md.
  *Deferred from 2026-07-13 vim review session.*
- **Delete stale `vim/viminfo`** — `set viminfofile` was removed (1a8cfe3) so
  the 24k `vim/viminfo` on disk is orphaned; it contains command/search
  history with ~71 lines matching token/key/password patterns. Gitignored but
  should be removed (`rm vim/viminfo`) to eliminate the exposure.
  *Deferred from 2026-07-13 vim review session.*
- **Add `make lint` (shellcheck) target** — the repo has no lint target; the
  2026-07-13 lint run used shellcheck ad hoc. Add a Makefile target over the
  bash-parseable shell files plus `# shellcheck shell=bash` directives to
  silence SC2148 on sourced files, so CI/`make test` can gate on it.

### Low (P4)

- **Doppler startup fetch hardening** — `shell/doppler-secrets.sh` now runs
  `load_doppler_cache` on every shell start (network call); offline or on a
  slow network this delays startup until the doppler CLI fails. Consider an
  interactive-shell-only guard or a short-TTL disk cache fallback.
  *Deferred from 2026-07-13 doppler eager-fetch change.*
- **Lazy-load heavy vim plugins** — nerdtree, tagbar, fzf.vim, and ale load
  eagerly at startup; vim-plug supports `{ 'on': ... }` lazy loading. Review
  finding that was cut by the 15-finding cap in the 2026-07-13 review.
- **Prefer `noremap` in vimrc mappings** — most mappings use recursive
  `map`/`nmap` (e.g. `map <space> /`, `map 0 ^`); any plugin remapping the
  RHS silently changes their behavior. Convert to `noremap` variants where
  chaining is not intended.
