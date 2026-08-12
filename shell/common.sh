# Common shell configuration shared between bash and zsh

# Validate required environment
[[ -n "$DOTFILES_DIR" ]] || { printf '[dotfiles] DOTFILES_DIR is unset\n' >&2; return 1; }
[[ -n "$SHELL_DIR" ]] || { printf '[dotfiles] SHELL_DIR is unset\n' >&2; return 1; }

# ---------- platform detection ----------
case "$OSTYPE" in
  darwin*)  export PLATFORM="macos"  ;;
  linux*)   export PLATFORM="linux"  ;;
  *)        export PLATFORM="$OSTYPE" ;;
esac

# ---------- otel config  ----------
export OTEL_DEBUG=1
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
export OTEL_EXPORTER_OTLP_COMPRESSION="gzip"
export OTEL_EXPORTER_OTLP_TIMEOUT="5000"
export OTEL_SERVICE_NAME="claude-code-hooks"
export OTEL_RESOURCE_ATTRIBUTES="deployment.environment=development,service.version=1.0.0,user.name=${USER}"

# ---------- Sentry ----------
export SENTRY_DISPLAY_NAME="integrity"
export SENTRY_ORG_SLUG="integrity-jq"

# ---------- shell quality-of-life ----------
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export HISTSIZE=50000
export HISTFILESIZE=100000
export SAVEHIST=50000

# Enable color support for GNU ls if available (-d . so the probe never
# lists a large working directory at shell start)
if ls --color=auto -d . >/dev/null 2>&1; then
  alias _plain_ls='ls --color=auto'
else
  alias _plain_ls='ls -G'
fi

# Cache dir for expensive shell-init evaluations (dircolors, pyenv init, tput).
export DOTFILES_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
[[ -d "$DOTFILES_CACHE_DIR" ]] || mkdir -p "$DOTFILES_CACHE_DIR"

# Load dircolors if available (GNU coreutils, not on macOS by default).
# Cache the eval output; regenerate when the source file changes.
if [[ -f "$SHELL_DIR/dircolors" ]] && command -v dircolors >/dev/null 2>&1; then
  _dircolors_cache="$DOTFILES_CACHE_DIR/dircolors.sh"
  if [[ ! -s "$_dircolors_cache" || "$SHELL_DIR/dircolors" -nt "$_dircolors_cache" ]]; then
    dircolors "$SHELL_DIR/dircolors" > "$_dircolors_cache"
  fi
  source "$_dircolors_cache"
  unset _dircolors_cache
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

# Prepend to PATH, forcing position: an entry already present is MOVED to the
# front rather than skipped.
#
# The previous guard only tested presence, so it could add a directory but never
# reposition one. That made it unable to survive macOS login shells: this file is
# sourced from zshenv, and /etc/zprofile's path_helper runs afterwards and hoists
# /etc/paths to the front, demoting every entry below. Re-running the old helper
# was a no-op — the entries were still *present* — so .local/bin, .cargo/bin,
# $GOPATH/bin and .pub-cache/bin all sat below /usr/bin, and only pyenv was
# rescued (by a separate `pyenv init` re-eval in zsh/zshrc).
_path_prepend() {
  [ -d "$1" ] || return 0
  PATH=":$PATH:"
  PATH="${PATH//":$1:"/:}"
  PATH="${PATH#:}"
  PATH="${PATH%:}"
  export PATH="$1:$PATH"
}

# Every PATH entry this repo owns, in ASCENDING priority — _path_prepend puts the
# last call at the front. Grouped so macOS login shells can re-run the whole set
# after path_helper; see the call in zsh/zshrc. Callers must have exported GOPATH
# and PYENV_ROOT first (the body is only evaluated when invoked).
_dotfiles_hoist_path() {
  _path_prepend "$HOME/.local/bin"
  _path_prepend "$HOME/.pub-cache/bin"
  _path_prepend "$HOME/.cargo/bin"
  _path_prepend "$GOPATH/bin"
  _path_prepend "$PYENV_ROOT/bin"
  _path_prepend "$PYENV_ROOT/shims"
}

# add rustup to PATH
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_HOME="$HOME/.cargo"

# add go to PATH
export GOPATH="$HOME/code/go"

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
  unset _chruby_sh _chruby_auto
fi


# Python via pyenv
export PYENV_ROOT="$HOME/.pyenv"

# Now that GOPATH and PYENV_ROOT are set, lay down the full PATH. _path_prepend
# skips directories that do not exist, so absent entries cost nothing.
_dotfiles_hoist_path

if command -v pyenv >/dev/null 2>&1; then
  _pyenv_shell=""
  [[ -n "${ZSH_VERSION:-}" ]] && _pyenv_shell="zsh"
  [[ -n "${BASH_VERSION:-}" ]] && _pyenv_shell="bash"
  if [[ -n "$_pyenv_shell" ]]; then
    _pyenv_bin="$(command -v pyenv)"
    _pyenv_cache="$DOTFILES_CACHE_DIR/pyenv-init.$_pyenv_shell.sh"
    # Regenerate when pyenv binary is newer than cache.
    if [[ ! -s "$_pyenv_cache" || "$_pyenv_bin" -nt "$_pyenv_cache" ]]; then
      _pyenv_init_out="$(pyenv init - "$_pyenv_shell")"
      # Avoid startup warnings when shims are not writable.
      if [[ -d "$PYENV_ROOT/shims" && ! -w "$PYENV_ROOT/shims" ]]; then
        _pyenv_init_out="$(printf '%s\n' "$_pyenv_init_out" | grep -v '^command pyenv rehash$')"
      fi
      printf '%s\n' "$_pyenv_init_out" > "$_pyenv_cache"
      unset _pyenv_init_out
    fi
    source "$_pyenv_cache"
    unset _pyenv_bin _pyenv_cache
  fi
  unset _pyenv_shell
fi

command -v direnv >/dev/null 2>&1 && {
  if [[ -n "${ZSH_VERSION:-}" ]]; then eval "$(direnv hook zsh)"
  elif [[ -n "${BASH_VERSION:-}" ]]; then eval "$(direnv hook bash)"
  fi
}


# _path_prepend and _dotfiles_hoist_path deliberately stay defined. They used to
# be unset here as hygiene, which left every later PATH repair to hand-roll its
# own mechanism — zsh/zshrc grew three (a pmk filter using zsh array syntax, a
# `pyenv init` re-eval, a `brew shellenv` block) for one job. Keeping the helper
# available is what lets zsh/zshrc re-run the same ordering after path_helper
# instead of reimplementing it.

[[ -f "$SHELL_DIR/doppler-secrets.sh" ]] && source "$SHELL_DIR/doppler-secrets.sh"
[[ -f "$SHELL_DIR/functions.sh" ]] && source "$SHELL_DIR/functions.sh"
