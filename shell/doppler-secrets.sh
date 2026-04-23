# Doppler secret registry — provides project variables, cache loading, and secret access.
#
# Usage:
#   load_doppler_cache PROJECT CONFIG           # load secrets into DOPPLER_CACHE
#   secret GITHUB_TOKEN                         # one-shot read (no export)
#   GITHUB_TOKEN=$(secret GITHUB_TOKEN) git push # inline for a single command
#   doppler_export GITHUB_TOKEN STRIPE_API_KEY  # export specific vars
#   doppler_export_all                          # export everything (rare)
#
# Note: secrets with raw embedded newlines (e.g. PEM keys) are truncated by
# command substitution. Escaped \n literals in JSON values are unaffected.

# ---------- Doppler constants ----------
export CONFIG_DEV="dev"
export CONFIG_STAGING="staging"
export CONFIG_PRODUCTION="production"

# Public aliases used by tests and external consumers
export DOPPLER_CONFIG_DEFAULT="$CONFIG_DEV"
export DOPPLER_CONFIG_PRODUCTION="$CONFIG_PRODUCTION"

# Cache TTL for the background refresh of DOPPLER_PROJECT_* variables
_DOPPLER_CACHE_TTL_SECONDS=3600

# Validate identifier is a valid shell variable name
# Pattern: starts with letter or underscore, followed by alphanumeric or underscore
_is_valid_identifier() {
  [[ $1 =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
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
        [ -z "$_assignment" ] && continue
        export "$_assignment"
      done < "$_doppler_cache"
    fi

    # Refresh cache in background (only if >1h old or missing)
    # Skip if already checked this session to avoid repeated time/stat calls
    if [ -z "${_DOPPLER_CACHE_CHECKED:-}" ]; then
      _DOPPLER_CACHE_CHECKED=1
      _cache_mtime=$(stat -f%m "$_doppler_cache" 2>/dev/null || stat -c%Y "$_doppler_cache" 2>/dev/null) || _cache_mtime=0
      if [ "$(( ${EPOCHSECONDS:-$(date +%s)} - _cache_mtime ))" -gt "$_DOPPLER_CACHE_TTL_SECONDS" ]; then
        (
          _new_cache=$(doppler projects --json 2>/dev/null | jq -r '.[] | "DOPPLER_PROJECT_\(.name | gsub("-";"_") | ascii_upcase)=\(.name)"')
          if [ -n "$_new_cache" ]; then
            printf '%s\n' "$_new_cache" > "$_doppler_cache"
          fi
        ) &
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
  local project="${1:-integrity-studio}"
  local config="${2:-dev}"

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
  while IFS=$'\t' read -r k v; do
    [[ -n "$k" ]] || continue
    DOPPLER_CACHE[$k]="$v"
  done <<< "$parsed"

  DOPPLER_CACHE_PROJECT="$project"
  DOPPLER_CACHE_CONFIG="$config"

  _rebuild_doppler_all_secrets
}

# Bash 3.2 stub — real zsh version defined after the bash-exit guard below.
# (bash parser can't handle ${(@k)...} syntax, even inside a function body.)
_rebuild_doppler_all_secrets() { :; }

# Check current doppler cache status
doppler_cache_info() {
  echo "Project: ${DOPPLER_CACHE_PROJECT:-none}"
  echo "Config:  ${DOPPLER_CACHE_CONFIG:-none}"
  echo "Secrets: ${#DOPPLER_CACHE[@]}"
}

# Read a doppler key from cache
# Returns exit 1 when key is missing and no default is provided.
doppler_get() {
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
}


# zsh-only helpers live in shell/zsh/ — bash can't parse their syntax.
if [[ -n "${ZSH_VERSION:-}" ]] && [[ -f "${SHELL_DIR:-$HOME/dotfiles/shell}/zsh/doppler-secrets.zsh" ]]; then
  source "${SHELL_DIR:-$HOME/dotfiles/shell}/zsh/doppler-secrets.zsh"
fi
