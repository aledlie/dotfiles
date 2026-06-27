# Dotfiles

Personal dotfiles for macOS development environment.

## Structure

```
dotfiles/
├── README.md              # This file
├── Makefile               # Make targets for install/backup/test
├── install.sh             # Installation script
├── shell/                 # Shell configurations
│   ├── common.sh          # Shared shell config, exports, Doppler cache init
│   ├── aliases.sh         # Command aliases
│   ├── functions.sh       # Custom shell functions (incl. Doppler cache)
│   ├── doppler-secrets.sh # Doppler secret registry and export helpers (zsh-only)
│   ├── dircolors          # LS_COLORS configuration
│   ├── bash/              # Bash-specific configs
│   │   ├── bashrc
│   │   ├── bash_profile
│   │   └── prompt.bash
│   └── zsh/               # Zsh-specific configs
│       ├── zshrc
│       └── prompt.zsh
├── git/                   # Git configuration
│   └── gitconfig
├── vim/                   # Vim configuration
│   └── vimrc
├── tmux/                  # Tmux configuration
│   └── tmux.conf
├── tests/                 # Shell startup and function tests
└── docs/                  # Changelogs and backlog
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
  - `weather` - Display weather info
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
- Git shortcuts (`gs`, `ga`, `gc`, `gp`, `gl`)
- macOS-specific system commands
- Development server (`serve`)
- Network utilities (`localip`, `flush`, `ips`)

### Environment Setup
- Homebrew integration (macOS)
- Python build configuration (Tcl/Tk support)
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

## Installation Data Flow

```
install.sh execution:
  │
  ├─ Detect shell type ($SHELL)
  │  ├─ zsh? → Use ~/.zshenv
  │  └─ bash? → Use ~/.bash_profile
  │
  ├─ Detect machine architecture (uname -m)
  │  └─ Returns: arm64, x86_64, aarch64, etc.
  │
  ├─ Detect operating system type (uname -s)
  │  └─ Normalizes to: darwin, linux, etc.
  │
  ├─ Create backup directory (~/.dotfiles.backup/<timestamp>/)
  │
  ├─ Create symlinks:
  │  ├─ shell/zsh/zshrc → ~/.zshrc
  │  ├─ shell/zsh/zprofile → ~/.zprofile
  │  ├─ shell/zsh/prompt.zsh → ~/.prompt.zsh
  │  ├─ shell/bash/bashrc → ~/.bashrc
  │  ├─ shell/bash/bash_profile → ~/.bash_profile
  │  ├─ shell/bash/prompt.bash → ~/.prompt.bash
  │  ├─ shell/dircolors → ~/.dircolors
  │  ├─ git/gitconfig → ~/.gitconfig
  │  ├─ vim/vimrc → ~/.vimrc
  │  └─ tmux/tmux.conf → ~/.tmux.conf
  │
  ├─ Backup existing files to BACKUP_DIR (if they exist)
  │
  └─ Write shell initialization to .zshenv or .bash_profile:
     └─ export DOTFILES_DIR="$HOME/dotfiles"
        export SHELL_DIR="$DOTFILES_DIR/shell"
        export ARCH="arm64"              # (detected at install time)
        export DOTFILES_OS="darwin"      # (detected at install time)
        
        # Platform-specific PATH setup (macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
          _path_prepend "/opt/homebrew/bin"
          _path_prepend "/opt/homebrew/sbin"
        fi
        
        [[ -f "$SHELL_DIR/common.sh" ]] && source "$SHELL_DIR/common.sh"
```

## Shell Startup Data Flow

### Zsh (All Invocations)
```
Terminal starts → exec zsh
  │
  ├─ .zshenv (ALWAYS, every invocation)
  │  │
  │  ├─ export DOTFILES_DIR="$HOME/dotfiles"
  │  ├─ export SHELL_DIR="$DOTFILES_DIR/shell"
  │  ├─ export ARCH="arm64"          # (set at install time)
  │  ├─ export DOTFILES_OS="darwin"  # (set at install time)
  │  │
  │  ├─ Platform-specific PATH setup (if macOS)
  │  │
  │  └─ source shell/common.sh
  │     │
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
  │  ├─ Load .prompt.zsh (custom prompt with git info)
  │  ├─ Load fzf.zsh (fuzzy finder)
  │  └─ Source dart-cli-completion
  │
  └─ Shell ready
```

### Bash (Login Shells Only)
```
Terminal starts → exec bash -l
  │
  ├─ .bash_profile (login shells only)
  │  │
  │  ├─ export DOTFILES_DIR="$HOME/dotfiles"
  │  ├─ export SHELL_DIR="$DOTFILES_DIR/shell"
  │  ├─ export ARCH="x86_64"         # (set at install time)
  │  ├─ export DOTFILES_OS="linux"   # (set at install time)
  │  │
  │  ├─ Platform-specific PATH setup (if macOS)
  │  │
  │  └─ source shell/common.sh
  │     │ (same as Zsh common.sh setup above)
  │
  ├─ .bashrc (interactive shells only)
  │  │
  │  ├─ Bash options (histappend, checkwinsize, cdspell, etc.)
  │  ├─ Setup completions
  │  ├─ Configure pyenv (shell-specific init)
  │  ├─ Setup direnv
  │  ├─ Load prompt.bash (custom prompt with git info)
  │  ├─ Load fzf.bash (fuzzy finder)
  │  └─ Source cargo env
  │
  └─ Shell ready
```

**Key insights:**
- **Zsh:** All exports available everywhere (scripts, cron, login, interactive) via `.zshenv`
- **Bash:** Exports only available in login shells (`.bash_profile`); scripts and non-login shells need separate sourcing
- **Install-time values:** ARCH, DOTFILES_OS, and platform-specific PATH setup are baked into shell init files
- **Runtime values:** Everything using `$HOME`, `$USER`, or environment variable expansion stays in `common.sh`
- **File guards:** All sourcing operations check file existence before loading, preventing errors during fresh installs

## Make Targets

The Makefile provides convenient commands:

- `make help` - Show available targets
- `make install` - Install dotfiles (create symlinks)
- `make backup` - Backup existing dotfiles
- `make clean` - Remove symlinks and restore from backup
- `make test` - Test shell configurations for syntax errors

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
