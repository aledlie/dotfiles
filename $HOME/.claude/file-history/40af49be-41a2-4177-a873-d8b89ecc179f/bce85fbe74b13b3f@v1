# Common shell configuration shared between bash and zsh

# ---------- shell quality-of-life ----------
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export HISTSIZE=50000
export HISTFILESIZE=100000
export SAVEHIST=50000
# Platform detection
export ARCH="${ARCH:-$(uname -m)}"

# Enable color support for GNU ls if available
if ls --color=auto >/dev/null 2>&1; then
  alias _plain_ls='ls --color=auto'
else
  alias _plain_ls='ls -G'
fi

# helpful aliases & colors
[[ -f "$SHELL_DIR/aliases.sh" ]] && source "$SHELL_DIR/aliases.sh"

# Load git prompt if available
if [[ -f "$DOTFILES_DIR/git/git-prompt.sh" ]]; then
    source "$DOTFILES_DIR/git/git-prompt.sh"
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWSTASHSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1
    export GIT_PS1_SHOWUPSTREAM="auto"
fi

# ---------- otel config  ----------
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
export OTEL_EXPORTER_OTLP_COMPRESSION="gzip"
export OTEL_EXPORTER_OTLP_TIMEOUT="5000"
export OTEL_SERVICE_NAME="claude-code-hooks"
export OTEL_RESOURCE_ATTRIBUTES="deployment.environment=development,service.version=1.0.0,user.name=alyshia"

# ---------- dev dependency sanity ----------

# Prepend to PATH only if the entry is not already present
_path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}
# Add Homebrew to PATH (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    _path_prepend "/opt/homebrew/bin"
    _path_prepend "/opt/homebrew/sbin"
fi

# add local bin to PATH
_path_prepend "$HOME/.local/bin"

# Dart/Flutter pub cache (Flutter installed via Homebrew)
_path_prepend "$HOME/.pub-cache/bin"

# add rustup to PATH
_path_prepend "$HOME/.cargo/bin"

# Use nvm instead of brew default for node and typescript
export NVM_DIR="$HOME/.nvm"
_nvm_sh="/opt/homebrew/opt/nvm/nvm.sh"
[ -s "$_nvm_sh" ] && . "$_nvm_sh"
unset _nvm_sh

# chruby configuration - auto-switch Ruby versions
if [[ "$OSTYPE" == "darwin"* ]]; then
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

# Python via pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && _path_prepend "$PYENV_ROOT/bin"

# Initialize pyenv (shell name detected automatically)
if command -v pyenv >/dev/null 2>&1; then
    _pyenv_shell="${ZSH_VERSION:+zsh}"
    _pyenv_shell="${_pyenv_shell:-bash}"
    _pyenv_init_cmd="$(pyenv init - "$_pyenv_shell")"
    # Avoid startup warnings when shims are not writable.
    if [[ -d "$PYENV_ROOT/shims" && ! -w "$PYENV_ROOT/shims" ]]; then
        _pyenv_init_cmd="$(printf '%s\n' "$_pyenv_init_cmd" | sed '/^command pyenv rehash$/d')"
    fi
    eval "$_pyenv_init_cmd"
    unset _pyenv_shell _pyenv_init_cmd
fi

# ---------- secret management quality-of-life ----------

# list of available doppler projects
export PROJECT_INTEGRITY="integrity-studio"
export PROJECT_ANALYTICS="analyticsbot"
export PROJECT_PERSONAL="personal-info"
export PROJECT_ACCOUNTING="accounting"
export PROJECT_ATX="atx-movement"
export PROJECT_BOTTLENECK="bottleneck"
export PROJECT_FINANCIAL="financial-hub"
export PROJECT_LEGAL="legal"
export PROJECT_PROPERTY="property"
export CONFIG_DEV="dev"
export CONFIG_PRODUCTION="production"
DEFAULT_PROJECT="$PROJECT_INTEGRITY"
DEFAULT_CONFIG="$CONFIG_DEV"
SHELL_DIR="$DOTFILES_DIR/shell"

# pull secrets from doppler with default project and dev configuration into cache for faster reads
[[ -f "$SHELL_DIR/functions.sh" ]] && source "$SHELL_DIR/functions.sh"
if command -v doppler >/dev/null 2>&1 && typeset -f load_doppler_cache >/dev/null 2>&1; then
  load_doppler_cache "$DEFAULT_PROJECT" "$DEFAULT_CONFIG" 2>/dev/null || printf '[dotfiles] warning: doppler cache load failed\n' >&2
fi
[[ -f "$SHELL_DIR/doppler-secrets.sh" ]] && source "$SHELL_DIR/doppler-secrets.sh"

# doppler cache is no longer needed after secrets have been loaded to process.env by doppler-secrets.sh
unload_doppler_cache
