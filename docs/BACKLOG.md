# Project Backlog

## Open Items

### Medium (P3)

- **Fresh-clone vim bootstrap** — commit 12965de moved plugin management to
  vim-plug only (cleared `.gitmodules`, gitignored `vim/plugin/`), so a fresh
  clone has zero plugins until `:PlugInstall` is run. Automate it (install.sh
  step or `vim +PlugInstall +qall`) and document in README/DATA_FLOW.md.
  *Deferred from 2026-07-13 vim review session.*
- **Add `make lint` (shellcheck) target** — the repo has no lint target; the
  2026-07-13 lint run used shellcheck ad hoc. Add a Makefile target over the
  bash-parseable shell files plus `# shellcheck shell=bash` directives to
  silence SC2148 on sourced files, so CI/`make test` can gate on it.

### Low (P4)

- **Lazy-load heavy vim plugins** — nerdtree, tagbar, fzf.vim, and ale load
  eagerly at startup; vim-plug supports `{ 'on': ... }` lazy loading. Review
  finding that was cut by the 15-finding cap in the 2026-07-13 review.
- **Prefer `noremap` in vimrc mappings** — most mappings use recursive
  `map`/`nmap` (e.g. `map <space> /`, `map 0 ^`); any plugin remapping the
  RHS silently changes their behavior. Convert to `noremap` variants where
  chaining is not intended.
