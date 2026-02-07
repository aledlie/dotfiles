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


# Ruby settings are configured in ~/.zshrc
# (chruby is loaded there with auto-switching enabled)

# Load additional modules
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[[ -f "$DOTFILES_DIR/shell/aliases.sh" ]] && source "$DOTFILES_DIR/shell/aliases.sh"
[[ -f "$DOTFILES_DIR/shell/functions.sh" ]] && source "$DOTFILES_DIR/shell/functions.sh"

# Secrets are managed via Doppler (https://doppler.com)
# Use: doppler secrets get <KEY> --project <project> --config dev --plain
# Or:  doppler run --project <project> --config dev -- <command>
