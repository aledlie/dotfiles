# Data Flow

Single reference for how these dotfiles move from repo to running shell:
a high-level overview, then the step-by-step detail.

## Overview

### Install time

```
symlinks.conf ──▶ install.sh / make install ──▶ $HOME symlinks
   (manifest)         (reads each row)            (source → target)
```

1. Resolve `DOTFILES_DIR` from the script location (symlink-resolved `pwd -P`).
2. Read `symlinks.conf`; for each `source → target` row, back up any existing
   `$HOME` file, then symlink `$HOME/target → $DOTFILES_DIR/source`.
3. No files are generated — repo files are linked in place.

### Shell startup

```
new shell
   │
   ├─ entry point (~/.zshenv | ~/.bashrc)   # symlink into repo
   │     resolves DOTFILES_DIR + SHELL_DIR
   │     │
   │     └─ source common.sh                # shared setup
   │           platform detect ($PLATFORM) → OTEL/Sentry env → cache dir →
   │           PATH → tool init (pyenv/direnv) → doppler-secrets → functions
   │
   └─ zsh only: zshrc (interactive) + zprofile (login)
         completion, history, prompt; re-alias GITHUB_TOKEN for github MCP
```

### Secret access (runtime)

```
secret NAME ──▶ doppler-secrets cache ──▶ Doppler (on demand)
```

Secrets are pulled on demand and cached in memory — never committed.

## Install time (detailed)

```
install.sh execution:
  │
  ├─ Detect shell / arch / OS (informational log only; uname -m, uname -s)
  │
  ├─ Create backup directory (~/.dotfiles.backup/<timestamp>/)
  │
  └─ Create symlinks (backing up any existing file first) — the rows of
     symlinks.conf, the single source of truth:
     ├─ shell/zsh/zshenv → ~/.zshenv
     ├─ shell/zsh/zshrc → ~/.zshrc
     ├─ shell/zsh/zprofile → ~/.zprofile
     ├─ shell/bash/bashrc → ~/.bashrc
     ├─ shell/bash/bash_profile → ~/.bash_profile
     ├─ shell/dircolors → ~/.dircolors
     ├─ git/gitconfig → ~/.gitconfig
     ├─ vim/vimrc → ~/.vimrc
     └─ tmux/tmux.conf → ~/.tmux.conf

Prompt files (shell/zsh/prompt.zsh, shell/bash/prompt.bash) are NOT symlinked —
they are sourced directly from the repo via $SHELL_DIR, so they need no $HOME
symlink.

The script generates no files. Each shell bootstraps from its symlinked repo
file — `shell/zsh/zshenv` (zsh) and `shell/bash/bashrc` (bash) — which set
DOTFILES_DIR/SHELL_DIR and source common.sh (which sets $PLATFORM). Machine
arch/OS detection (detect_arch/detect_ostype) lives in install.sh and runs at
install time only. Values using $HOME/$USER are computed on each shell start,
not baked in.
```

## Shell startup (detailed)

### Zsh (all invocations)

```
Terminal starts → exec zsh
  │
  ├─ .zshenv → symlink to shell/zsh/zshenv (ALWAYS, every invocation)
  │  │
  │  ├─ export DOTFILES_DIR="$HOME/dotfiles"
  │  ├─ export SHELL_DIR="$DOTFILES_DIR/shell"
  │  │
  │  └─ source shell/common.sh
  │     │
  │     ├─ Detect $PLATFORM (macos/linux, from $OSTYPE)
  │     ├─ Export OTEL vars (PROTOCOL, COMPRESSION, TIMEOUT, SERVICE_NAME, RESOURCE_ATTRIBUTES)
  │     ├─ Export shell quality-of-life (EDITOR, VISUAL, HISTSIZE, SAVEHIST)
  │     ├─ Setup ls colors (with file existence guard)
  │     ├─ Load dircolors (with file existence guard)
  │     ├─ Source aliases.sh (with file existence guard)
  │     ├─ Source git-prompt.sh with git settings (with file existence guard)
  │     ├─ Add to PATH: local, cargo, pub-cache, GOPATH, etc.
  │     ├─ Configure NVM (Node Version Manager)
  │     ├─ Configure chruby (Ruby 3.4.4 auto-switch, interactive only)
  │     ├─ Configure pyenv (Python version management)
  │     ├─ Export Doppler project names (PROJECT_INTEGRITY, etc.)
  │     ├─ Source functions.sh (with file existence guard)
  │     └─ Load Doppler cache (load_doppler_cache)
  │
  ├─ .zprofile (login shells only)
  │
  ├─ .zshrc (interactive shells only)
  │  │
  │  ├─ Zsh options (AUTO_CD, CORRECT_ALL, AUTO_LIST, HIST_*, etc.)
  │  ├─ Setup completions (compinit)
  │  ├─ Configure pyenv (shell-specific init)
  │  ├─ Setup direnv
  │  ├─ Source $SHELL_DIR/zsh/prompt.zsh (custom prompt with git info; from repo)
  │  ├─ Load ~/.fzf.zsh (fuzzy finder)
  │  └─ Source dart-cli-completion
  │
  └─ Shell ready
```

### Bash (login shells only)

```
Terminal starts → exec bash -l
  │
  ├─ .bash_profile (login shells only) → symlink to shell/bash/bash_profile
  │  │
  │  ├─ source ~/.bashrc   (so login shells get the bootstrap below)
  │  └─ eval "$(brew shellenv)"   (Homebrew PATH on macOS)
  │
  ├─ .bashrc → symlink to shell/bash/bashrc (interactive + sourced by .bash_profile)
  │  │
  │  ├─ export DOTFILES_DIR="$HOME/dotfiles"
  │  ├─ export SHELL_DIR="$DOTFILES_DIR/shell"
  │  ├─ Bash options (histappend, checkwinsize, cdspell, etc.)
  │  ├─ Source $DOTFILES_DIR/shell/bash/prompt.bash (custom prompt; from repo)
  │  ├─ Load ~/.fzf.bash (fuzzy finder)
  │  └─ source shell/common.sh
  │     │ (same as Zsh common.sh setup above)
  │
  └─ Shell ready
```

**Key insights:**
- **No generated files:** Both shells bootstrap from their symlinked repo files (`shell/zsh/zshenv`, `shell/bash/bashrc`); install.sh only creates symlinks
- **Zsh:** All exports available everywhere (scripts, cron, login, interactive) via `.zshenv`
- **Bash:** Bootstrap lives in `.bashrc`; login shells pick it up because `.bash_profile` sources `.bashrc`. Non-interactive non-login bash still needs separate sourcing
- **Runtime values:** `$PLATFORM` (set by common.sh) and everything using `$HOME`/`$USER` are computed on each shell start, never baked in; machine arch/OS detection lives in install.sh (install-time only)
- **File guards:** All sourcing operations check file existence before loading, preventing errors during fresh installs
