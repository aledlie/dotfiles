#!/bin/bash

# Dotfiles installation script
# Creates symlinks from the home directory to dotfiles in ~/dotfiles.
# Both shells bootstrap from their symlinked repo files: shell/zsh/zshenv and
# shell/bash/bashrc set DOTFILES_DIR/SHELL_DIR/ARCH/DOTFILES_OS and source
# common.sh, so the script generates no files at install time.

set -e

# Resolve the dotfiles directory (the location of this script) unless overridden
# pwd -P resolves symlinks so the recorded symlink targets match the Makefile's
# $(realpath ...) regardless of how the repo was reached.
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)}"

# PID suffix keeps the dir unique if two runs land in the same second (BSD date
# has no sub-second %N); the timestamp prefix still sorts chronologically.
BACKUP_DIR="$HOME/.dotfiles.backup/$(date +%Y%m%dT%H%M%S)-$$"

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
    local kernel
    kernel=$(uname -s)
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

# Backup existing file if it exists. A symlink already pointing into the repo
# has no original worth saving (matches the Makefile backup/clean behavior), so
# drop it rather than copy it into the backup.
backup_file() {
    local file="$1"
    local target="$HOME/$file"

    [ -e "$target" ] || [ -L "$target" ] || return 0

    case "$(readlink "$target" 2>/dev/null)" in
        "$DOTFILES_DIR"/*)
            print_status "Replacing stale repo symlink $file"
            rm -f "$target"
            return 0
            ;;
    esac

    mkdir -p "$BACKUP_DIR"
    print_status "Backing up existing $file"
    mv -f "$target" "$BACKUP_DIR/"
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

    # Shell/arch/OS are informational only — zshenv/bashrc set these at runtime.
    print_status "Detected shell: $(detect_shell), architecture: $(detect_arch), OS: $(detect_ostype)"

    # Symlinks are defined in symlinks.conf (shared with the Makefile) so the two
    # never drift. Both shells bootstrap entirely from these repo files
    # (zshenv/bashrc source common.sh), so there is no install-time file
    # generation — re-runs stay idempotent. Prompt and dircolors files are
    # sourced directly from the repo via $SHELL_DIR, so they need no $HOME symlink.
    while read -r source target _; do
        case "$source" in ''|'#'*) continue ;; esac
        create_symlink "$source" "$target"
    done < "$DOTFILES_DIR/symlinks.conf"

    print_status "Installation complete!"
    print_status "Restart your shell to load new configuration"

    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        print_warning "Your original dotfiles have been backed up to: $BACKUP_DIR"
    fi
}


main
