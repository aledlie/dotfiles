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

# ---------- PATH ----------
# Laid down here, before everything below that resolves a tool through PATH: the
# GNU-ls probe, dircolors, pyenv and direnv all do. bash/bash_profile used to
# hoist Homebrew itself for exactly that reason, before sourcing bashrc; doing it
# here instead means bash and zsh share one implementation rather than two.

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
# after path_helper; see the call in zsh/zprofile.
_dotfiles_hoist_path() {
  _path_prepend "$HOME/.local/bin"
  _path_prepend "$HOME/.pub-cache/bin"
  _path_prepend "$HOME/.cargo/bin"
  _path_prepend "$GOPATH/bin"
  # Homebrew. `brew shellenv` sets HOMEBREW_PREFIX/MANPATH/INFOPATH/fpath as well
  # as PATH, so it is evaluated rather than hand-prepended — but it spawns brew and
  # costs ~71ms, and this function is deliberately re-run on macOS login shells.
  # So: evaluate once, then reposition the bin dirs cheaply on every later call.
  # Must precede the pyenv shims below — brew ships its own python3, and this
  # machine needs pyenv-built interpreters (brew's are broken by the libexpat ABI
  # on macOS 26).
  if [ -z "${HOMEBREW_PREFIX:-}" ] && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  _path_prepend "${HOMEBREW_PREFIX:-/opt/homebrew}/sbin"
  _path_prepend "${HOMEBREW_PREFIX:-/opt/homebrew}/bin"
  _path_prepend "$PYENV_ROOT/bin"
  _path_prepend "$PYENV_ROOT/shims"
}

export RUSTUP_HOME="$HOME/.rustup"
export CARGO_HOME="$HOME/.cargo"
export GOPATH="$HOME/code/go"
export PYENV_ROOT="$HOME/.pyenv"

_dotfiles_hoist_path

# ---------- otel config  ----------
export OTEL_DEBUG=1
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
export OTEL_EXPORTER_OTLP_COMPRESSION="gzip"
export OTEL_EXPORTER_OTLP_TIMEOUT="5000"
# OTEL_SERVICE_NAME is deliberately NOT exported here. A global export hands
# the file shipper's identity ("claude-code-hooks") to every process on the
# machine — and traces from that exact service name are the ONLY signal that
# proves the shipper is alive (see ~/.claude/CLAUDE.md), so any other process
# inheriting it corrupts stall detection silently. The hooks don't need the
# export: hooks/lib/otel/service-identity.ts falls back to the same name in code.
# Anything else that needs a service name must set it in its own env
# (e.g. the observability-toolkit MCP server pins its own in ~/.claude.json).
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
#
# Accept the g-prefixed name too. Homebrew's coreutils installs GNU tools as
# gdircolors/gls and only exposes the unprefixed names through a gnubin shim dir
# that is deliberately not on PATH (it would shadow every BSD counterpart). So
# `command -v dircolors` alone never matched on this machine and the whole block
# was skipped in silence — LS_COLORS went unset, and this repo's dircolors file
# had no effect on eza, which is what `ls` actually resolves to (see aliases.sh).
_dircolors_bin="$(command -v dircolors || command -v gdircolors || true)"
if [[ -f "$SHELL_DIR/dircolors" && -n "$_dircolors_bin" ]]; then
  _dircolors_cache="$DOTFILES_CACHE_DIR/dircolors.sh"
  if [[ ! -s "$_dircolors_cache" || "$SHELL_DIR/dircolors" -nt "$_dircolors_cache" ]]; then
    "$_dircolors_bin" "$SHELL_DIR/dircolors" > "$_dircolors_cache"
  fi
  source "$_dircolors_cache"
  unset _dircolors_cache
fi
unset _dircolors_bin

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

# nvm, loaded on first use rather than at shell start.
#
# Sourcing nvm.sh costs ~82ms — the largest single item in shell startup — and
# with --no-use it activates no version, so `node` and `npm` resolve to Homebrew
# regardless (verified: both are /opt/homebrew/bin, despite nvm having v24.14.0
# and v24.19.0 installed and a `default` alias set). The old comment here claimed
# "use nvm instead of brew default for node", which --no-use has never actually
# done. That 82ms therefore bought only the `nvm` function itself.
#
# So define a stub that replaces itself on first call. --no-use is preserved, so
# invoking nvm still does not silently change which node is on PATH; run
# `nvm use <version>` to do that deliberately. Nothing else depends on nvm.sh
# being sourced eagerly — no .nvmrc chpwd hook is installed, and no other file in
# this repo references it.
#
# _NVM_SH is deliberately NOT unset: the stub dereferences it when it fires.
export NVM_DIR="$HOME/.nvm"
_NVM_SH="/opt/homebrew/opt/nvm/nvm.sh"
if [ -s "$_NVM_SH" ]; then
  nvm() {
    unset -f nvm            # drop the stub first, so the real one can define itself
    . "$_NVM_SH" --no-use
    nvm "$@"
  }
fi

# chruby configuration - auto-switch Ruby versions (skip in non-interactive shells)
if [[ "$OSTYPE" == "darwin"* ]] && [[ -t 0 ]]; then
  _chruby_sh="/opt/homebrew/opt/chruby/share/chruby/chruby.sh"
  _chruby_auto="/opt/homebrew/opt/chruby/share/chruby/auto.sh"
  [[ -f "$_chruby_sh" ]] && source "$_chruby_sh"
  [[ -f "$_chruby_auto" ]] && source "$_chruby_auto"
  unset _chruby_sh _chruby_auto
fi


# Python via pyenv (PYENV_ROOT and the shims are set up in the PATH section above)
if command -v pyenv >/dev/null 2>&1; then
  _pyenv_shell=""
  [[ -n "${ZSH_VERSION:-}" ]] && _pyenv_shell="zsh"
  [[ -n "${BASH_VERSION:-}" ]] && _pyenv_shell="bash"
  if [[ -n "$_pyenv_shell" ]]; then
    _pyenv_bin="$(command -v pyenv)"
    _pyenv_cache="$DOTFILES_CACHE_DIR/pyenv-init.$_pyenv_shell.sh"
    # Regenerate when the pyenv binary changes, OR when this file does. The flags
    # below are baked into the generated output, so editing them has to invalidate
    # the cache; keying on the binary alone would leave a stale cache silently in
    # place across exactly that kind of change.
    if [[ ! -s "$_pyenv_cache" || "$_pyenv_bin" -nt "$_pyenv_cache" \
          || "$SHELL_DIR/common.sh" -nt "$_pyenv_cache" ]]; then
      # --no-rehash: `pyenv init -` emits `command pyenv rehash`, which rebuilds
      # every shim on each shell start — 66ms of this block's 79.5ms, 83% of it.
      # Rehash is only needed after a new interpreter or a package that installs a
      # console script, and `pyenv install` rehashes on its own.
      #
      # TRADE-OFF: after `pip install` of something with an entry point, its shim
      # will not exist until you run `pyenv rehash` yourself.
      #
      # This also replaces a grep that stripped the same line, but only when the
      # shims dir was unwritable — warning suppression that left the 66ms in place
      # whenever it was writable, which is the normal case and was so here.
      _pyenv_init_out="$(pyenv init - --no-rehash "$_pyenv_shell")"
      printf '%s\n' "$_pyenv_init_out" > "$_pyenv_cache"
      unset _pyenv_init_out
    fi
    source "$_pyenv_cache"
    unset _pyenv_bin _pyenv_cache
  fi
  unset _pyenv_shell
fi

# direnv hook, cached like dircolors and pyenv init above — `direnv hook <shell>`
# spawns direnv (~7ms) to emit text that only changes when direnv itself does.
# Keyed on the binary's mtime, the same invalidation pyenv-init uses.
#
# The generated hook hard-codes the absolute path of the direnv that produced it,
# so a cache built against a different install would keep calling the old one.
# Only one direnv exists here (/opt/homebrew/bin), and a brew upgrade rewrites the
# binary and so invalidates this. If a second install ever appears on PATH, key
# the cache on the resolved path rather than just its mtime.
if command -v direnv >/dev/null 2>&1; then
  _direnv_shell=""
  [[ -n "${ZSH_VERSION:-}" ]] && _direnv_shell="zsh"
  [[ -n "${BASH_VERSION:-}" ]] && _direnv_shell="bash"
  if [[ -n "$_direnv_shell" ]]; then
    _direnv_bin="$(command -v direnv)"
    _direnv_cache="$DOTFILES_CACHE_DIR/direnv-hook.$_direnv_shell.sh"
    if [[ ! -s "$_direnv_cache" || "$_direnv_bin" -nt "$_direnv_cache" ]]; then
      direnv hook "$_direnv_shell" > "$_direnv_cache"
    fi
    source "$_direnv_cache"
    unset _direnv_bin _direnv_cache
  fi
  unset _direnv_shell
fi


# _path_prepend and _dotfiles_hoist_path deliberately stay defined. They used to
# be unset here as hygiene, which left every later PATH repair to hand-roll its
# own mechanism — zsh/zshrc grew three (a pmk filter using zsh array syntax, a
# `pyenv init` re-eval, a `brew shellenv` block) for one job. Keeping the helper
# available is what lets zsh/zprofile re-run the same ordering after path_helper
# instead of reimplementing it.

[[ -f "$SHELL_DIR/doppler-secrets.sh" ]] && source "$SHELL_DIR/doppler-secrets.sh"
[[ -f "$SHELL_DIR/functions.sh" ]] && source "$SHELL_DIR/functions.sh"
