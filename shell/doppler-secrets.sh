# Doppler secret registry — provides project variables, cache loading, and secret access.
#
# Secrets for the default project/config are fetched into DOPPLER_CACHE lazily,
# on the first read by any helper below (see _doppler_ensure_cache), not at shell
# start — the fetch is a synchronous network call and most shells never read one.
#
# Usage:
#   load_doppler_cache PROJECT CONFIG           # load secrets into DOPPLER_CACHE
#   secret GITHUB_TOKEN                         # one-shot read (no export)
#   GITHUB_TOKEN=$(secret GITHUB_TOKEN) git push # inline for a single command
#   doppler_export GITHUB_TOKEN STRIPE_API_KEY  # export specific vars
#   doppler_export_all                          # export everything (rare)
#
# zsh only: secret, doppler_export, doppler_export_all, doppler_copy_secret are
# defined in shell/zsh/doppler-secrets.zsh (zsh-only parameter expansions). A
# bash shell sourcing this file gets load_doppler_cache, doppler_get, and the
# doppler_cache_* helpers, but not those.
#
# Note: values pass through jq @tsv (which escapes \ tab newline CR) and are
# unescaped on load, so multi-line secrets (e.g. PEM keys) round-trip intact.
# Reading one via $(secret X) still strips trailing newlines, as any command
# substitution does.

# ---------- Doppler constants ----------
export CONFIG_DEV="dev"
export CONFIG_STAGING="staging"
export CONFIG_PRODUCTION="production"

# Public aliases used by tests and external consumers
export DOPPLER_CONFIG_DEFAULT="$CONFIG_DEV"
export DOPPLER_CONFIG_PRODUCTION="$CONFIG_PRODUCTION"

# Cache TTL for the background refresh of DOPPLER_PROJECT_* variables
_DOPPLER_CACHE_TTL_SECONDS=3600

# Env var alias -> Doppler key name, one ALIAS=KEY per line. Only non-identity
# mappings are listed. This is the single source of truth: doppler_get resolves
# through it here (so bash gets aliases too), and shell/zsh/doppler-secrets.zsh
# derives both _DOPPLER_SECRET_NAMES and _DOPPLER_REVERSE_NAMES from it.
_DOPPLER_SECRET_ALIASES='OTEL_INGEST_ROUTE=OBTOOL_INGEST_ROUTE
OTEL_INGEST_URL=OBTOOL_INGEST_URL
OTEL_INGEST_PREVIEW_URL=OBTOOL_INGEST_PREVIEW_URL
OTEL_API_KEY=OBTOOL_API_KEY'

# Validate identifier is a valid shell variable name
# Pattern: starts with letter or underscore, followed by alphanumeric or underscore
_is_valid_identifier() {
  [[ $1 =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
}

# Resolve an env-var alias to its Doppler key name; prints the input unchanged
# when no alias exists. Plain loop + case so it works on bash 3.2 (no assoc arrays).
_doppler_resolve_key() {
  local _pair
  while IFS= read -r _pair; do
    case "$_pair" in
      "$1="*) printf '%s\n' "${_pair#*=}"; return 0 ;;
    esac
  done <<< "$_DOPPLER_SECRET_ALIASES"
  printf '%s\n' "$1"
}

# Dynamically populate DOPPLER_PROJECT_* variables from doppler projects (with background refresh)
# This runs in both zsh and bash
if command -v doppler >/dev/null 2>&1; then
  if ! command -v jq >/dev/null 2>&1; then
    printf 'doppler-secrets.sh: warning: doppler found but jq missing; project variables unavailable\n' >&2
  else
    _doppler_cache="$HOME/.cache/doppler-projects.txt"
    mkdir -p "$(dirname "$_doppler_cache")" 2>/dev/null

    if [ -f "$_doppler_cache" ]; then
      while IFS= read -r _assignment; do
        # Only accept well-formed DOPPLER_PROJECT_* rows — the cache file is
        # ordinary user-writable state; never export arbitrary NAME=VALUE
        # lines (a corrupt/tampered line could set PATH etc. in every shell).
        case "$_assignment" in
          DOPPLER_PROJECT_*=*) ;;
          *) continue ;;
        esac
        _is_valid_identifier "${_assignment%%=*}" || continue
        export "$_assignment"
      done < "$_doppler_cache"
    fi

    # Refresh cache in background (only if >1h old or missing)
    # Skip if already checked this session to avoid repeated time/stat calls
    if [ -z "${_DOPPLER_CACHE_CHECKED:-}" ]; then
      _DOPPLER_CACHE_CHECKED=1
      _cache_mtime=$(stat -f%m "$_doppler_cache" 2>/dev/null || stat -c%Y "$_doppler_cache" 2>/dev/null) || _cache_mtime=0
      if [ "$(( ${EPOCHSECONDS:-$(date +%s)} - _cache_mtime ))" -gt "$_DOPPLER_CACHE_TTL_SECONDS" ]; then
        # Background refresh; suppress job-control notifications.
        # `& disown` backgrounds + disowns in both bash and zsh. zsh's `&|`
        # would do the same in one token, but it's a *parse-time* syntax error
        # in bash — and bash sources this file, so a runtime ZSH_VERSION guard
        # can't shield it. disown's stderr is redirected in case the shell
        # lacks the builtin.
        (
          _new_cache=$(doppler projects --json 2>/dev/null | jq -r '.[] | "DOPPLER_PROJECT_\(.name | gsub("-";"_") | ascii_upcase)=\(.name)"')
          if [ -n "$_new_cache" ]; then
            # Write-then-rename: a plain `>` truncates in place, so a shell
            # starting mid-write could read a partial project list and keep it
            # for the rest of its session. rename(2) is atomic within a dir.
            _tmp_cache="$_doppler_cache.$$"
            if printf '%s\n' "$_new_cache" > "$_tmp_cache" 2>/dev/null; then
              mv -f "$_tmp_cache" "$_doppler_cache" 2>/dev/null
            fi
            rm -f "$_tmp_cache" 2>/dev/null
          fi
        ) &
        disown 2>/dev/null || true
      fi
    fi

    unset _assignment _doppler_cache _cache_mtime _new_cache
  fi
fi

# Set defaults (these reference dynamically populated DOPPLER_PROJECT_* variables)
DEFAULT_PROJECT="${DOPPLER_PROJECT_INTEGRITY_STUDIO:-integrity-studio}"
DEFAULT_CONFIG="$CONFIG_DEV"

# Load Doppler secrets into cache (both bash/zsh compatible)
load_doppler_cache() {
  # Defaults must match what the startup fetch at the bottom of this file passes,
  # otherwise a bare `load_doppler_cache` silently targets a different project.
  local project="${1:-$DEFAULT_PROJECT}"
  local config="${2:-$DEFAULT_CONFIG}"

  if [ "${DOPPLER_CACHE_PROJECT:-}" = "$project" ] && [ "${DOPPLER_CACHE_CONFIG:-}" = "$config" ]; then
    return
  fi

  if [ -n "${ZSH_VERSION:-}" ]; then
    typeset -gA DOPPLER_CACHE
    typeset -g DOPPLER_CACHE_PROJECT DOPPLER_CACHE_CONFIG
  elif [ -n "${BASH_VERSION:-}" ]; then
    # Bash 4+ required for associative arrays and `declare -g`.
    if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
      printf 'load_doppler_cache: bash %s too old (need 4+); use zsh or install modern bash via Homebrew\n' \
        "$BASH_VERSION" >&2
      return 1
    fi
    declare -gA DOPPLER_CACHE
    declare -g DOPPLER_CACHE_PROJECT DOPPLER_CACHE_CONFIG
  fi

  local json doppler_err jq_err
  doppler_err=$(mktemp) || return 1
  jq_err=$(mktemp) || { rm -f "$doppler_err"; return 1; }

  if ! json=$(doppler secrets download \
      --no-file \
      --format json \
      --project "$project" \
      --config "$config" 2>"$doppler_err"); then
    printf 'load_doppler_cache: doppler failed (%s/%s): %s\n' \
      "$project" "$config" "$(<"$doppler_err")" >&2
    rm -f "$doppler_err" "$jq_err"
    return 1
  fi

  local parsed
  if ! parsed=$(jq -r 'to_entries[] | [.key, (.value // "")] | @tsv' <<< "$json" 2>"$jq_err"); then
    printf 'load_doppler_cache: jq parse failed: %s\n' "$(<"$jq_err")" >&2
    rm -f "$doppler_err" "$jq_err"
    return 1
  fi

  rm -f "$doppler_err" "$jq_err"

  # Guard: empty parse would wipe a good cache — bail before resetting.
  if [[ -z "${parsed//[[:space:]]/}" ]]; then
    printf 'load_doppler_cache: warning: 0 secrets loaded for %s/%s\n' \
      "$project" "$config" >&2
    return 1
  fi

  DOPPLER_CACHE=()
  local k v
  while IFS=$'\t' read -r k v; do
    [[ -n "$k" ]] || continue
    # Undo @tsv escaping (\\ \t \n \r) so multi-line values round-trip.
    # %b interprets exactly those; @tsv doubled every literal backslash, so
    # no other %b escape can fire from original content.
    printf -v v '%b' "$v"
    DOPPLER_CACHE[$k]="$v"
  done <<< "$parsed"

  DOPPLER_CACHE_PROJECT="$project"
  DOPPLER_CACHE_CONFIG="$config"

  _rebuild_doppler_all_secrets
}

# Bash 3.2 stub — real zsh version defined after the bash-exit guard below.
# (bash parser can't handle ${(@k)...} syntax, even inside a function body.)
_rebuild_doppler_all_secrets() { :; }

# Populate DOPPLER_CACHE on first read instead of at shell start.
#
# Sourcing this file used to call load_doppler_cache unconditionally, which runs
# a synchronous `doppler secrets download` — measured 241-676ms, network-bound.
# Nothing carried that across a process boundary: DOPPLER_CACHE is a shell
# associative array, and DOPPLER_CACHE_PROJECT/_CONFIG are `typeset -g`, global
# but NOT exported. So every new shell paid it again, including every `zsh -c`
# in a script that never reads a secret at all.
#
# The latch records the attempt, not the outcome. Without it a failed download
# (offline, expired auth) would retry on every subsequent `secret` call, turning
# one slow shell into a uniformly slow one. Callers that want a retry after
# fixing the cause can run `load_doppler_cache` directly, as the message says.
#
# CAVEAT for scripts: `v=$(secret X)` runs in a subshell, so the fetch it triggers
# dies with that subshell and the parent still holds nothing. Reading N secrets
# that way costs N fetches — measured 831ms for three, against 327ms for one
# `_doppler_ensure_cache` followed by the same three. Call this function once up
# front if a script reads more than one secret; zsh/zshrc does exactly that.
_doppler_ensure_cache() {
  [ -n "${_DOPPLER_LOAD_ATTEMPTED:-}" ] && return 0
  _DOPPLER_LOAD_ATTEMPTED=1
  command -v doppler >/dev/null 2>&1 || return 0
  # Skipped on bash <4: load_doppler_cache needs associative arrays, and the
  # guard keeps macOS system-bash startup quiet.
  if [ -n "${ZSH_VERSION:-}" ] || [ "${BASH_VERSINFO[0]:-0}" -ge 4 ]; then
    # Errors are intentionally not suppressed — load_doppler_cache prints
    # actionable diagnostics (auth, jq, empty parse) a generic warning would mask.
    load_doppler_cache "$DEFAULT_PROJECT" "$DEFAULT_CONFIG" || \
      printf '[dotfiles] doppler cache not loaded; run `load_doppler_cache` after fixing the above\n' >&2
  fi
}

# Check current doppler cache status
doppler_cache_info() {
  _doppler_ensure_cache
  echo "Project: ${DOPPLER_CACHE_PROJECT:-none}"
  echo "Config:  ${DOPPLER_CACHE_CONFIG:-none}"
  echo "Secrets: ${#DOPPLER_CACHE[@]}"
}

# Read a doppler key from cache
# Accepts either the Doppler key name or its env-var alias (see
# _DOPPLER_SECRET_ALIASES) — same resolution zsh's `secret` does.
# Returns exit 1 when key is missing and no default is provided.
doppler_get() {
  _doppler_ensure_cache
  local key="$1"
  local default="${2-}"

  if [[ -z "$key" ]]; then
    # Empty key: return default if provided, otherwise error.
    if [[ $# -ge 2 ]]; then
      printf '%s\n' "$default"
      return 0
    fi
    printf 'doppler_get: key required\n' >&2
    return 1
  fi

  key=$(_doppler_resolve_key "$key")

  [[ -n "${DOPPLER_CACHE[$key]+set}" ]] && {
    printf '%s\n' "${DOPPLER_CACHE[$key]}"
    return
  }

  # Key missing — return default if provided, otherwise signal failure
  if [[ $# -ge 2 ]]; then
    printf '%s\n' "$default"
    return 0
  fi
  return 1
}

doppler_cache_has() {
  _doppler_ensure_cache
  local key="$1"

  if [[ -n "${DOPPLER_CACHE[$key]+set}" ]]; then
    echo "found: $key"
  else
    echo "missing: $key"
  fi
}

# UNSAFE: prints raw secret value — only use interactively for debugging
doppler_cache_debug() {
  local key="$1"

  # Guard: only allow on interactive terminal to prevent accidental secret leakage
  if [[ ! -t 1 ]]; then
    printf '[doppler_cache_debug] stdout is not a terminal; refusing to print secrets\n' >&2
    return 1
  fi

  if [[ -n "${DOPPLER_CACHE[$key]+set}" ]]; then
    echo "found key: $key"
    echo "value length: ${#DOPPLER_CACHE[$key]}"
    printf 'value: [%s]\n' "${DOPPLER_CACHE[$key]}"
  else
    echo "missing key: $key"
  fi
}

# Clear the in-memory Doppler cache (secrets remain in any already-exported env vars)
unload_doppler_cache() {
  DOPPLER_CACHE=()
  unset DOPPLER_CACHE_PROJECT DOPPLER_CACHE_CONFIG
  # Must mirror load_doppler_cache — otherwise _DOPPLER_ALL_SECRETS keeps the
  # old key list and doppler_export_all warns once per stale key.
  _rebuild_doppler_all_secrets
}


# zsh-only helpers live in shell/zsh/ — bash can't parse their syntax.
if [[ -n "${ZSH_VERSION:-}" ]] && [[ -f "${SHELL_DIR:-$HOME/dotfiles/shell}/zsh/doppler-secrets.zsh" ]]; then
  source "${SHELL_DIR:-$HOME/dotfiles/shell}/zsh/doppler-secrets.zsh"
fi

# No fetch at shell start. Every reader calls _doppler_ensure_cache first, so the
# `doppler secrets download` happens on the first secret actually read and not at
# all in a shell that reads none — which is most of them, every `zsh -c` in a
# script included. See _doppler_ensure_cache for why nothing could be carried
# across a process boundary to make the old eager load a one-time cost.
