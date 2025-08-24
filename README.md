# Dotfiles

Personal dotfiles for macOS development environment.

## Structure

```
dotfiles/
├── README.md           # This file
├── install.sh          # Installation script
├── shell/              # Shell configurations
│   ├── common.sh       # Shared shell functions and exports
│   ├── aliases.sh      # Command aliases
│   ├── functions.sh    # Custom shell functions
│   ├── bash/           # Bash-specific configs
│   └── zsh/            # Zsh-specific configs
├── git/                # Git configuration
├── vim/                # Vim configuration
├── tmux/               # Tmux configuration
└── bin/                # Custom scripts
```

## Installation

1. Clone this repository:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   ```

2. Run the installation script:
   ```bash
   cd ~/dotfiles
   ./install.sh
   ```

3. Restart your shell or source the new configuration:
   ```bash
   source ~/.zshrc
   ```

## Features

- Cross-platform shell configuration (macOS/Linux)
- Modular organization for easy maintenance
- Automated installation and symlinking
- Development-focused aliases and functions
- Git integration with custom prompt
- Vim configuration with custom settings

## Dependencies

- Homebrew (macOS)
- Git
- Vim
- Tmux (optional)
- Ruby with chruby (optional)

## Backup

The installation script automatically backs up existing dotfiles to `~/.dotfiles.backup/` before creating symlinks.
