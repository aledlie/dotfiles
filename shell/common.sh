# Common shell configuration shared between bash and zsh

# Validate required environment
[[ -n "$DOTFILES_DIR" ]] || { printf '[dotfiles] DOTFILES_DIR is unset\n' >&2; return 1; }
[[ -n "$SHELL_DIR" ]] || { printf '[dotfiles] SHELL_DIR is unset\n' >&2; return 1; }

# ---------- otel config  ----------
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
export OTEL_EXPORTER_OTLP_COMPRESSION="gzip"
export OTEL_EXPORTER_OTLP_TIMEOUT="5000"
export OTEL_SERVICE_NAME="claude-code-hooks"
export OTEL_RESOURCE_ATTRIBUTES="deployment.environment=development,service.version=1.0.0,user.name=${USER}"

# ---------- shell quality-of-life ----------
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export HISTSIZE=50000
export HISTFILESIZE=100000
export SAVEHIST=50000

# Enable color support for GNU ls if available
if ls --color=auto >/dev/null 2>&1; then
  alias _plain_ls='ls --color=auto'
else
  alias _plain_ls='ls -G'
fi

# Load dircolors if available (GNU coreutils, not on macOS by default)
if [[ -f "$SHELL_DIR/dircolors" ]] && command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors "$SHELL_DIR/dircolors")"
fi

# helpful aliases & colors
[[ -f "$SHELL_DIR/aliases.sh" ]] && source "$SHELL_DIR/aliases.sh"

# Load git prompt if available
[[ -f "$DOTFILES_DIR/git/git-prompt.sh" ]] && {
  source "$DOTFILES_DIR/git/git-prompt.sh"
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWSTASHSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_SHOWUPSTREAM="auto"
}

# ---------- dev dependency sanity ----------

# Prepend to PATH only if the entry is not already present
_path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

# add local bin to PATH
_path_prepend "$HOME/.local/bin"

# Dart/Flutter pub cache (Flutter installed via Homebrew)
_path_prepend "$HOME/.pub-cache/bin"

# add rustup to PATH
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_HOME="$HOME/.cargo"
_path_prepend "$HOME/.cargo/bin"

# add go to PATH
export GOPATH="$HOME/code/go"
_path_prepend "$GOPATH/bin"

# Use nvm instead of brew default for node and typescript
export NVM_DIR="$HOME/.nvm"
_nvm_sh="/opt/homebrew/opt/nvm/nvm.sh"
[ -s "$_nvm_sh" ] && . "$_nvm_sh" --no-use
unset _nvm_sh

# chruby configuration - auto-switch Ruby versions (skip in non-interactive shells)
if [[ "$OSTYPE" == "darwin"* ]] && [[ -t 0 ]]; then
  _chruby_sh="/opt/homebrew/opt/chruby/share/chruby/chruby.sh"
  _chruby_auto="/opt/homebrew/opt/chruby/share/chruby/auto.sh"
  [[ -f "$_chruby_sh" ]] && source "$_chruby_sh"
  [[ -f "$_chruby_auto" ]] && source "$_chruby_auto"
  # Set default Ruby version (chruby manages GEM_HOME/GEM_PATH)
  if command -v chruby >/dev/null 2>&1; then
    if ! chruby ruby-3.4.4 >/dev/null 2>&1; then
      echo "[dotfiles] warning: ruby-3.4.4 not found, skipping chruby" >&2
    fi
  fi
  unset _chruby_sh _chruby_auto
fi


# Python via pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && _path_prepend "$PYENV_ROOT/bin"
[[ -d "$PYENV_ROOT/shims" ]] && _path_prepend "$PYENV_ROOT/shims"


# Shell-specific pyenv initialization is in bash/bashrc and zsh/zshrc

# All _path_prepend calls must precede this line
unset -f _path_prepend

# ---------- secret management quality-of-life ----------

# Dynamically populate project variables from doppler projects (with background refresh)
if command -v doppler >/dev/null 2>&1; then
  if ! command -v jq >/dev/null 2>&1; then
    printf '[dotfiles] warning: doppler found but jq missing; project variables unavailable\n' >&2
  else
    _doppler_cache="$HOME/.cache/doppler-projects.txt"
    mkdir -p "$(dirname "$_doppler_cache")" 2>/dev/null

    # Load from cache (if exists), export immediately
    if [[ -f "$_doppler_cache" ]]; then
      while IFS= read -r _assignment; do
        [[ -z "$_assignment" ]] && continue
        export "$_assignment"
      done < "$_doppler_cache"
    fi

    # Refresh cache in background (non-blocking)
    (
      _new_cache=$(doppler projects --json 2>/dev/null | jq -r '.[] | "DOPPLER_PROJECT_\(.name | gsub("-";"_") | ascii_upcase)=\(.name)"')
      if [[ -n "$_new_cache" ]]; then
        printf '%s\n' "$_new_cache" > "$_doppler_cache"
      fi
    ) &

    unset _assignment _doppler_cache
  fi
fi

# Config variants
export CONFIG_DEV="dev"
export CONFIG_PRODUCTION="production"
DEFAULT_PROJECT="${DOPPLER_PROJECT_INTEGRITY_STUDIO:-integrity-studio}"
DEFAULT_CONFIG="$CONFIG_DEV"

# pull secrets from doppler with default project and dev configuration into cache for faster reads
[[ -f "$SHELL_DIR/functions.sh" ]] && source "$SHELL_DIR/functions.sh"
if command -v doppler >/dev/null 2>&1 && typeset -f load_doppler_cache >/dev/null 2>&1; then
  load_doppler_cache "$DEFAULT_PROJECT" "$DEFAULT_CONFIG" 2>/dev/null || printf '[dotfiles] warning: doppler cache load failed\n' >&2
fi
[[ -f "$SHELL_DIR/doppler-secrets.sh" ]] && source "$SHELL_DIR/doppler-secrets.sh"
