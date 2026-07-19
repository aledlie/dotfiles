# Dotfiles

Personal dotfiles for macOS development environment.

## Structure

```
dotfiles/
├── README.md              # This file
├── Makefile               # Make targets for install/backup/clean/test
├── install.sh             # Installation script
├── symlinks.conf          # Symlink manifest — single source of truth for install.sh + Makefile
├── shell/                 # Shell configurations
│   ├── common.sh          # Shared config: platform, exports, PATH, tool init
│   ├── aliases.sh         # Command aliases
│   ├── functions.sh       # Utility shell functions
│   ├── doppler-secrets.sh # Doppler cache + helpers shared by bash and zsh
│   ├── dircolors          # LS_COLORS configuration
│   ├── bash/              # Bash-specific configs
│   │   ├── bashrc
│   │   ├── bash_profile
│   │   └── prompt.bash
│   └── zsh/               # Zsh-specific configs
│       ├── zshenv         # Entry point (all zsh invocations)
│       ├── zshrc
│       ├── zprofile
│       ├── prompt.zsh
│       └── doppler-secrets.zsh  # zsh-only helpers (secret, doppler_export, ...)
├── git/                   # Git configuration (gitconfig, vendored git-prompt.sh)
├── vim/                   # Vim configuration (vimrc; plugins managed by vim-plug)
├── tmux/                  # Tmux configuration
│   └── tmux.conf
├── tests/                 # Shell startup and function tests
└── docs/                  # Changelogs, backlog, data-flow docs
```

## Installation

1. Clone this repository:
   ```bash
   git clone git@github.com:aledlie/dotfiles.git ~/dotfiles
   ```

2. Run the installation script (either method):
   ```bash
   cd ~/dotfiles
   ./install.sh
   # OR
   make install
   ```

3. Restart your shell or source the new configuration:
   ```bash
   source ~/.zshrc
   ```

## Features

### Cross-Platform Support
- Platform detection (macOS/Linux) with platform-specific configurations
- Modular organization for easy maintenance

### Shell Configuration
- Shared configuration between bash and zsh via `common.sh`
- Custom prompts for both bash and zsh
- Smart aliases that adapt to platform
- Useful shell functions:
  - `dirsize` - Display directory sizes
  - `mkcd` - Create and enter directory
  - `extract` - Universal archive extraction
  - `findproc` - Find processes by name
  - `backup` - Quick file backup with timestamp
  - Git helpers: `newbranch`, `git_current_branch`
  - Doppler cache: `load_doppler_cache`, `unload_doppler_cache`, `doppler_cache_info`, `doppler_cache_has`, `doppler_cache_debug`

### Doppler Secrets Management
- Secrets loaded into an in-memory associative array (`DOPPLER_CACHE`) at shell startup via `load_doppler_cache`
- `secret KEY` - read a secret without exporting (zsh-only)
- `doppler_export KEY1 KEY2 ...` - export specific secrets as env vars (zsh-only)
- `doppler_export_all` - export all registered secrets (zsh-only)
- `unload_doppler_cache` - clear the cache from shell memory after extracting needed secrets
- Name mappings in `_DOPPLER_SECRET_NAMES` allow env var names to differ from Doppler key names (e.g., `OTEL_API_KEY` → `OBTOOL_API_KEY`)

### Aliases
- Directory navigation shortcuts (`..`, `...`, `....`)
- Git shortcuts via gitconfig aliases (`st`, `co`, `br`, `ci`, `lg`, ...)
- macOS-specific system commands
- Network utilities (`localip`, `flush`, `ips`)

### Environment Setup
- Homebrew integration (macOS)
- Python via pyenv, Node via nvm (cached/lazy init)
- Ruby version management with chruby
- Custom editor (vim) configuration
- History management

### Git Integration
- Custom git configuration
- Platform-aware settings
- Custom prompt showing branch info

### Vim Configuration
- Custom vimrc settings

### Tmux Configuration
- Custom tmux settings

## Data Flow

See [`docs/DATA_FLOW.md`](docs/DATA_FLOW.md) for how dotfiles flow from repo to
running shell — install-time symlinking, shell startup, and secret access, with
both a high-level overview and step-by-step diagrams.

## Make Targets

The Makefile provides convenient commands:

- `make help` - Show available targets
- `make install` - Install dotfiles (create symlinks)
- `make backup` - Backup existing dotfiles
- `make clean` - Remove symlinks and restore from backup
- `make test` - Run syntax checks and the test suite

## Dependencies

### Required
- Git

### Recommended (macOS)
- Homebrew
- Vim
- Tmux

### Optional
- chruby (Ruby version management)
- GNU coreutils (for better `ls` colors on macOS)
- Doppler CLI (secrets management)

## Backup

The installation script automatically backs up existing dotfiles to `~/.dotfiles.backup/` before creating symlinks. Use `make clean` to restore from backup.
