# Common shell configuration
# Shared between bash and zsh

# Platform detection
case "$(uname -s)" in
    Darwin*)
        export PLATFORM="macos"
        ;;
    Linux*)
        export PLATFORM="linux"
        ;;
    *)
        export PLATFORM="unknown"
        ;;
esac

# Common exports
export EDITOR=vim
export HISTSIZE=1000
export HISTFILESIZE=2000

# Add Homebrew to PATH (macOS)
if [[ "$PLATFORM" == "macos" ]]; then
    export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:$PATH"
fi

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"


# Add python settings to path
# Ensure Python builds can find Homebrew Tcl/Tk
export LDFLAGS="-L$(brew --prefix tcl-tk)/lib $LDFLAGS"
export CPPFLAGS="-I$(brew --prefix tcl-tk)/include $CPPFLAGS"
export PKG_CONFIG_PATH="$(brew --prefix tcl-tk)/lib/pkgconfig:$PKG_CONFIG_PATH"


# Ruby settings (if chruby is available)
if [[ "$PLATFORM" == "macos" ]] && [[ -f "/opt/homebrew/opt/chruby/share/chruby/chruby.sh" ]]; then
    source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
    source /opt/homebrew/opt/chruby/share/chruby/auto.sh
    chruby ruby-3.4.4 2>/dev/null || true
fi

# Load additional modules
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[[ -f "$DOTFILES_DIR/shell/aliases.sh" ]] && source "$DOTFILES_DIR/shell/aliases.sh"
[[ -f "$DOTFILES_DIR/shell/functions.sh" ]] && source "$DOTFILES_DIR/shell/functions.sh"

# Load environment variables (if file exists and is readable)
if [[ -f "$HOME/.env" ]] && [[ -r "$HOME/.env" ]]; then
    source "$HOME/.env"
fi
