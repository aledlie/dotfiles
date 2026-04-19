#!/bin/bash

# Dotfiles installation script
# This script creates symlinks from the home directory to dotfiles in ~/dotfiles
# Also sets up shell initialization files with DOTFILES_DIR, SHELL_DIR, ARCH, OSTYPE, and common.sh sourcing

set -e

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
        backup_file "$target"
        [ -d "$HOME/$target" ] && rm -rf "$HOME/$target"
        ln -sf "$DOTFILES_DIR/$source" "$HOME/$target" || {
            print_error "Failed to create symlink for $source"
            exit 1
        }
        print_status "Linked $source -> ~/$target"
    else
        print_warning "Source file $source not found, skipping"
    fi
}

# Setup shell initialization file with required exports and sourcing
setup_shell_init() {
    local shell_type="$1"
    local arch="$2"
    local ostype="$3"
    local init_file
    
    if [[ "$shell_type" == "zsh" ]]; then
        init_file="$HOME/.zshenv"
    else
        init_file="$HOME/.bash_profile"
    fi
    
    # Create file if it doesn't exist
    if [ ! -f "$init_file" ]; then
        touch "$init_file"
        print_status "Created $init_file"
    fi
    
    # Check if DOTFILES_DIR is already set
    if ! grep -q 'export DOTFILES_DIR' "$init_file" 2>/dev/null; then
        cat >> "$init_file" << SHELL_CONFIG

export DOTFILES_DIR="\$HOME/dotfiles"
export SHELL_DIR="\$DOTFILES_DIR/shell"
export ARCH="$arch"
export OSTYPE="$ostype"

# Prepend to PATH only if the entry is not already present
_path_prepend() {
  case ":\$PATH:" in
    *":\$1:"*) ;;
    *) export PATH="\$1:\$PATH" ;;
  esac
}

# Platform-specific PATH setup (macOS)
if [[ "\$OSTYPE" == "darwin"* ]]; then
  _path_prepend "/opt/homebrew/bin"
  _path_prepend "/opt/homebrew/sbin"
fi

unset -f _path_prepend

# Load common shell configuration
[[ -f "\$SHELL_DIR/common.sh" ]] && source "\$SHELL_DIR/common.sh"
SHELL_CONFIG
        print_status "Added shell initialization to $init_file"
    else
        print_status "Shell initialization already configured in $init_file"
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

    # Detect shell, architecture, and OS type
    SHELL_TYPE=$(detect_shell)
    ARCH=$(detect_arch)
    OSTYPE=$(detect_ostype)
    print_status "Detected shell: $SHELL_TYPE, architecture: $ARCH, OS: $OSTYPE"

    # Create symlinks for shell configurations
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

    # Setup shell initialization file
    setup_shell_init "$SHELL_TYPE" "$ARCH" "$OSTYPE"

    print_status "Installation complete!"
    print_status "Restart your shell to load new configuration"

    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        print_warning "Your original dotfiles have been backed up to: $BACKUP_DIR"
    fi
}


main
