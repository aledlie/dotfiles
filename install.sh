#!/bin/bash

# Dotfiles installation script
# Creates symlinks from the home directory to dotfiles in ~/dotfiles.
# Both shells bootstrap from their symlinked repo files: shell/zsh/zshenv and
# shell/bash/bashrc set DOTFILES_DIR/SHELL_DIR/ARCH/DOTFILES_OS and source
# common.sh, so the script generates no files at install time.

set -e

# Resolve the dotfiles directory (the location of this script) unless overridden
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

BACKUP_DIR="$HOME/.dotfiles.backup/$(date +%Y%m%dT%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    printf '%b\n' "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    printf '%b\n' "${YELLOW}[WARN]${NC} $1" >&2
}

print_error() {
    printf '%b\n' "${RED}[ERROR]${NC} $1" >&2
}

# Detect which shell to configure
detect_shell() {
    case "$(basename "$SHELL")" in
        zsh)  echo "zsh" ;;
        bash) echo "bash" ;;
        *)    [[ "$OSTYPE" == "darwin"* ]] && echo "zsh" || echo "bash" ;;
    esac
}

# Detect machine architecture
detect_arch() {
    uname -m
}

# Detect operating system type
detect_ostype() {
    local kernel=$(uname -s)
    case "$kernel" in
        Darwin)
            echo "darwin"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "$kernel" | tr '[:upper:]' '[:lower:]'
            ;;
    esac
}

# Backup existing file if it exists
backup_file() {
    local file="$1"
    if [ -f "$HOME/$file" ] || [ -L "$HOME/$file" ] || [ -d "$HOME/$file" ]; then
        mkdir -p "$BACKUP_DIR"
        print_status "Backing up existing $file"
        mv -f "$HOME/$file" "$BACKUP_DIR/"
    fi
}

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    if [ -e "$DOTFILES_DIR/$source" ] || [ -L "$DOTFILES_DIR/$source" ]; then
        # Already linked correctly — skip to keep re-runs idempotent (no churn backups)
        if [ "$(readlink "$HOME/$target" 2>/dev/null)" = "$DOTFILES_DIR/$source" ]; then
            print_status "Already linked $source -> ~/$target"
            return
        fi
        backup_file "$target"
        ln -sf "$DOTFILES_DIR/$source" "$HOME/$target" || {
            print_error "Failed to create symlink for $source"
            exit 1
        }
        print_status "Linked $source -> ~/$target"
    else
        print_warning "Source file $source not found, skipping"
    fi
}

# Main installation
main() {
    print_status "Starting dotfiles installation..."

    # Check if we're in the right directory
    if [ ! -d "$DOTFILES_DIR" ]; then
        print_error "Dotfiles directory not found at $DOTFILES_DIR"
        exit 1
    fi

    # Detect shell, architecture, and OS type (informational)
    SHELL_TYPE=$(detect_shell)
    ARCH=$(detect_arch)
    DOTFILES_OS=$(detect_ostype)
    print_status "Detected shell: $SHELL_TYPE, architecture: $ARCH, OS: $DOTFILES_OS"

    # Create symlinks for shell configurations. Both shells bootstrap entirely
    # from these repo files (zshenv/bashrc source common.sh), so there is no
    # install-time file generation — re-runs stay idempotent.
    create_symlink "shell/zsh/zshenv" ".zshenv"
    create_symlink "shell/zsh/zshrc" ".zshrc"
    create_symlink "shell/zsh/zprofile" ".zprofile"
    create_symlink "shell/zsh/prompt.zsh" ".prompt.zsh"
    create_symlink "shell/bash/bashrc" ".bashrc"
    create_symlink "shell/bash/bash_profile" ".bash_profile"
    create_symlink "shell/bash/prompt.bash" ".prompt.bash"
    create_symlink "shell/dircolors" ".dircolors"

    # Create symlinks for other configurations
    create_symlink "git/gitconfig" ".gitconfig"
    create_symlink "vim/vimrc" ".vimrc"
    create_symlink "tmux/tmux.conf" ".tmux.conf"

    print_status "Installation complete!"
    print_status "Restart your shell to load new configuration"

    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        print_warning "Your original dotfiles have been backed up to: $BACKUP_DIR"
    fi
}


main
