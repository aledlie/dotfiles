# Dotfiles

Personal dotfiles for macOS development environment.

## Structure

```
dotfiles/
├── README.md           # This file
├── Makefile            # Make targets for install/backup/test
├── install.sh          # Installation script
├── shell/              # Shell configurations
│   ├── common.sh       # Shared shell config and exports
│   ├── aliases.sh      # Command aliases
│   ├── functions.sh    # Custom shell functions
│   ├── bash/           # Bash-specific configs
│   │   ├── bashrc
│   │   ├── bash_profile
│   │   └── prompt.bash
│   └── zsh/            # Zsh-specific configs
│       ├── zshrc
│       └── prompt.zsh
├── git/                # Git configuration
│   └── gitconfig
├── vim/                # Vim configuration
│   └── vimrc
├── tmux/               # Tmux configuration
│   └── tmux.conf
└── bin/                # Custom scripts (currently empty)
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
  - Git helpers: `qcommit`, `newbranch`, `git_current_branch`

### Aliases
- Directory navigation shortcuts (`..`, `...`, `....`)
- Git shortcuts (`gs`, `ga`, `gc`, `gp`, `gl`)
- macOS-specific system commands
- Development server (`serve`)
- Network utilities (`localip`, `flush`, `ips`)
- Doppler secrets management integration

### Environment Setup
- Homebrew integration
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
