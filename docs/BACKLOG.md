# Project Backlog

Unmitigated findings from the 2026-07-13 vim code review (max effort). Fixed in
that session and therefore not listed: unregistered submodules (.gitmodules),
unguarded `colorscheme solarized` (vim/vimrc).

## High (P2)

- [x] **vimrc hardcodes `~/dotfiles`** — fixed in 218352c: derive repo root
  via `fnamemodify(resolve(expand('<sfile>:p')), ':h:h')`.
- [x] **Duplicate vim-mustache-handlebars submodule inside runtime dir** —
  fixed in 8c869f1: removed `vim/vim/plugin/vim-mustache-handlebars` gitlink.
- [x] **`set viminfofile` portability + secrets exposure** — fixed in 1a8cfe3:
  removed `set viminfofile`; reverts to default `~/.viminfo`.

## Medium (P3)

- **Autocmds without augroups** — `vim/vimrc:88,156,243,261`: re-sourcing the
  vimrc stacks duplicate FocusGained/BufEnter checktime, TabLeave, and
  BufReadPost handlers. Wrap in `augroup vimrc | autocmd! | ... | augroup END`.
- **Dead second plugin manager in vim-plug's install root** —
  `vim/plugin/Vundle.vim` and `vim/plugin/Align` are committed submodules
  referenced by no `Plug` line; `:PlugClean` offers to delete them, which
  would leave stale gitlink index entries and a permanently dirty status.
  Remove the submodules or add Plug lines.
- **`<C-h/j/k/l>` window maps silently overridden** — `vim/vimrc:219-222` are
  dead: vim-tmux-navigator (loaded at line 36) remaps the same keys after the
  vimrc runs. Delete the four maps or set `g:tmux_navigator_no_mappings`.
- **DATA_FLOW.md install list omits `vim/vim → ~/.vim`** — the detailed
  symlink list (`docs/DATA_FLOW.md:~63`) lacks the row `symlinks.conf:14`
  defines, contradicting the manifest CLAUDE.md calls the single source of
  truth. Add the row.
- **No test coverage for vim symlink rows** — nothing in `tests/` references
  vim; `make test` passes even when `~/.vim` diverges from `symlinks.conf`.
  Add a `tests/test-symlinks.sh` that validates every symlinks.conf row.

## Low (P4)

- **`map <C-space> ?` never fires in terminal vim** — terminals send
  Ctrl-Space as `<C-@>`/`<Nul>` (`vim/vimrc:215`); map `<C-@>` instead.
- **Dead helpers** — `VisualSelection()`/`CmdLine()` (`vim/vimrc:326-345`)
  have no call sites; VisualSelection also invokes `:Ack` (no such plugin
  installed) and uses ignorecase-sensitive `==`. Delete both.
- **Redundant/silent settings** — duplicate `set wildmenu`
  (`vim/vimrc:83,95`), `%h` twice in statusline (line 70), empty `catch`
  swallowing errors around `set switchbuf` (lines 254-258).
- **snipmate missing `snippet_version`** — `vim/vimrc:41`: modern snipmate
  errors on first snippet expansion until
  `let g:snipMate = {'snippet_version': 1}` is set before `plug#end()`.
