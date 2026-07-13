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

- [x] **Autocmds without augroups** — fixed in 165ea9b: wrapped all four bare
  autocmd declarations in named augroups with `autocmd!`.
- [x] **Dead second plugin manager in vim-plug's install root** — fixed in
  bf78766: removed Vundle.vim and Align submodules and their .gitmodules entries.
- [x] **`<C-h/j/k/l>` window maps silently overridden** — fixed in bb6227b:
  removed the four dead maps; vim-tmux-navigator handles them.
- [x] **DATA_FLOW.md install list omits `vim/vim → ~/.vim`** — fixed in
  c1e8d41: added the missing row.
- [x] **No test coverage for vim symlink rows** — fixed in 7a85fd0: added
  `tests/test-symlinks.sh` validating every symlinks.conf row.

## Low (P4)

- [x] **`map <C-space> ?` never fires in terminal vim** — fixed in 1aa21ee:
  changed to `map <C-@> ?`.
- [x] **Dead helpers** — fixed in eb74077: deleted VisualSelection() and
  CmdLine().
- [x] **Redundant/silent settings** — fixed in d8f3188: removed duplicate
  `set wildmenu`, fixed statusline duplicate flags, removed empty catch block.
- [x] **snipmate missing `snippet_version`** — fixed in f2c0375: added
  `let g:snipMate = {'snippet_version': 1}` before plug#end().
