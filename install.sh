#!/bin/bash

# Dotfiles installation script
# This script creates symlinks from the home directory to dotfiles in ~/dotfiles

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles.backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        print_status "Created backup directory: $BACKUP_DIR"
    fi
}

# Backup existing file if it exists
backup_file() {
    local file="$1"
    if [ -f "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
        print_warning "Backing up existing $file"
        mv "$HOME/$file" "$BACKUP_DIR/"
    fi
}

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -f "$DOTFILES_DIR/$source" ]; then
        backup_file "$target"
        ln -sf "$DOTFILES_DIR/$source" "$HOME/$target"
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
    
    create_backup_dir
    
    # Create symlinks for shell configurations
    create_symlink "shell/zsh/zshrc" ".zshrc"
    create_symlink "shell/bash/bashrc" ".bashrc"
    create_symlink "shell/bash/bash_profile" ".bash_profile"
    
    # Create symlinks for other configurations
    create_symlink "git/gitconfig" ".gitconfig"
    create_symlink "vim/vimrc" ".vimrc"
    create_symlink "tmux/tmux.conf" ".tmux.conf"
    
    print_status "Installation complete!"
    print_status "Restart your shell or run: source ~/.zshrc"
    
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR)" ]; then
        print_warning "Your original dotfiles have been backed up to: $BACKUP_DIR"
    fi
}

main "$@"
