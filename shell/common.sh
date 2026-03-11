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

# Prepend to PATH only if the entry is not already present
_path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

# Common exports
export EDITOR=vim
export HISTSIZE=1000
export HISTFILESIZE=2000

# Add Homebrew to PATH (macOS)
if [[ "$PLATFORM" == "macos" ]]; then
    _path_prepend "/opt/homebrew/sbin"
    _path_prepend "/opt/homebrew/bin"
fi

#add local bin to PATH
_path_prepend "$HOME/.local/bin"

# Dart/Flutter pub cache (Flutter installed via Homebrew)
export PATH="$PATH:$HOME/.pub-cache/bin"

# Use nvm instead of brew default for node and typescript
unset NPM_CONFIG_PREFIX
unset npm_config_prefix
export NVM_DIR="$HOME/.nvm"
if command -v brew >/dev/null 2>&1; then
  _nvm_prefix="$(brew --prefix nvm 2>/dev/null)"
  if [[ -n "$_nvm_prefix" ]]; then
    _nvm_sh="${_nvm_prefix}/nvm.sh"
    [ -s "$_nvm_sh" ] && . "$_nvm_sh"
  fi
  unset _nvm_prefix _nvm_sh
fi

# custom GO setup
export GOPATH="$HOME/code-env/go"
_path_prepend "$GOPATH/bin"

# custom Rust configuration
export RUSTUP_HOME="$HOME/code-env/rust/rustup"
export CARGO_HOME="$HOME/code-env/rust/cargo"
_path_prepend "$CARGO_HOME/bin"

# custom Ruby configuration via chruby
export BUNDLE_USER_CONFIG="$HOME/code-env/ruby/bundle/config"
# chruby configuration - auto-switch Ruby versions
if [[ "$PLATFORM" == "macos" ]]; then
  _chruby_sh="/opt/homebrew/opt/chruby/share/chruby/chruby.sh"
  _chruby_auto="/opt/homebrew/opt/chruby/share/chruby/auto.sh"
  [[ -f "$_chruby_sh" ]] && source "$_chruby_sh"
  [[ -f "$_chruby_auto" ]] && source "$_chruby_auto"
  # Set default Ruby version (chruby manages GEM_HOME/GEM_PATH)
  if command -v chruby >/dev/null 2>&1; then
    chruby ruby-3.4.4 2>/dev/null || echo "[dotfiles] warning: ruby-3.4.4 not found, skipping chruby" >&2
  fi
  unset _chruby_sh _chruby_auto
fi

# python macOS support
# macOS specific path config for python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && _path_prepend "$PYENV_ROOT/bin"

if command -v pyenv >/dev/null 2>&1; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(pyenv init - zsh)"
  elif [ -n "$BASH_VERSION" ]; then
    eval "$(pyenv init - bash)"
  else
    eval "$(pyenv init -)"
  fi
fi

# Platform-specific color flags
if [[ "$PLATFORM" == "macos" ]]; then
    colorflag="-G"
    # Use GNU ls if available (installed via brew install coreutils)
    if command -v gls >/dev/null 2>&1; then
        alias ls='gls --color=auto'
    else
        alias ls='ls -G'
    fi
else
    colorflag="--color=auto"
    alias ls='ls --color=auto'
fi

# Ensure Python builds can find Homebrew Tcl/Tk
if [[ "$PLATFORM" == "macos" ]] && command -v brew >/dev/null 2>&1; then
  _tcl_tk_prefix="$(brew --prefix tcl-tk 2>/dev/null)"
  if [[ -n "$_tcl_tk_prefix" ]]; then
    export LDFLAGS="-L${_tcl_tk_prefix}/lib ${LDFLAGS:-}"
    export CPPFLAGS="-I${_tcl_tk_prefix}/include ${CPPFLAGS:-}"
    export PKG_CONFIG_PATH="${_tcl_tk_prefix}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
  fi
  unset _tcl_tk_prefix
fi

# Load additional modules
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[[ -f "$DOTFILES_DIR/shell/functions.sh" ]] && source "$DOTFILES_DIR/shell/functions.sh"

# Secrets are managed via Doppler (https://doppler.com) and can be accessed via doppler_get [key_name]
# to avoid reads every time, load the default values (--project integrity-studio --config dev) into cache
if command -v doppler >/dev/null 2>&1 && typeset -f load_doppler_cache >/dev/null 2>&1; then
  load_doppler_cache
fi
# To change doppler projects or configs: load_doppler_cache [project] [config]
# For a list of doppler projects, see ~/dotfiles/shell/aliases.sh
# to check current doppler cache loaded, run doppler_cache_info

[[ -f "$DOTFILES_DIR/shell/aliases.sh" ]] && source "$DOTFILES_DIR/shell/aliases.sh"
