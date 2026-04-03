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
export CONFIG_PRODUCTION="production"

# Dynamically populate DOPPLER_PROJECT_* variables from doppler projects (with background refresh)
# This runs in both zsh and bash
if command -v doppler >/dev/null 2>&1; then
  if ! command -v jq >/dev/null 2>&1; then
    printf 'doppler-secrets.sh: warning: doppler found but jq missing; project variables unavailable\n' >&2
  else
    _doppler_cache="$HOME/.cache/doppler-projects.txt"
    mkdir -p "$(dirname "$_doppler_cache")" 2>/dev/null

    # Load from cache (if exists), export immediately
    if [ -f "$_doppler_cache" ]; then
      while IFS= read -r _assignment; do
        [ -z "$_assignment" ] && continue
        export "$_assignment"
      done < "$_doppler_cache"
    fi

    # Refresh cache in background (non-blocking)
    (
      _new_cache=$(doppler projects --json 2>/dev/null | jq -r '.[] | "DOPPLER_PROJECT_\(.name | gsub("-";"_") | ascii_upcase)=\(.name)"')
      if [ -n "$_new_cache" ]; then
        printf '%s\n' "$_new_cache" > "$_doppler_cache"
      fi
    ) &

    unset _assignment _doppler_cache
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

  # Use typeset for zsh, declare for bash
  if command -v typeset > /dev/null 2>&1 && [ -n "${ZSH_VERSION:-}" ]; then
    typeset -gA DOPPLER_CACHE
    typeset -g DOPPLER_CACHE_PROJECT
    typeset -g DOPPLER_CACHE_CONFIG
  elif command -v declare > /dev/null 2>&1; then
    # Only use declare -g if bash (not sh/dash)
    if [ -n "${BASH_VERSION:-}" ]; then
      declare -gA DOPPLER_CACHE
      declare -g DOPPLER_CACHE_PROJECT
      declare -g DOPPLER_CACHE_CONFIG
    fi
  fi

  DOPPLER_CACHE=()

  local json doppler_err jq_err
  doppler_err=$(mktemp) || return 1
  jq_err=$(mktemp) || { rm -f "$doppler_err"; return 1; }
  trap 'rm -f "$doppler_err" "$jq_err"' RETURN

  if ! json=$(doppler secrets download \
      --no-file \
      --format json \
      --project "$project" \
      --config "$config" 2>"$doppler_err"); then
    printf 'load_doppler_cache: doppler failed (%s/%s): %s\n' \
      "$project" "$config" "$(cat "$doppler_err")" >&2
    return 1
  fi

  local parsed
  if ! parsed=$(jq -r 'to_entries[] | [.key, (.value // "")] | @tsv' <<< "$json" 2>"$jq_err"); then
    printf 'load_doppler_cache: jq parse failed: %s\n' "$(cat "$jq_err")" >&2
    return 1
  fi

  while IFS=$'\t' read -r k v; do
    [[ -n "$k" ]] || continue
    DOPPLER_CACHE[$k]="$v"
  done <<< "$parsed"

  if [[ ${#DOPPLER_CACHE[@]} -eq 0 ]]; then
    printf 'load_doppler_cache: warning: 0 secrets loaded for %s/%s\n' \
      "$project" "$config" >&2
    return 1
  fi

  DOPPLER_CACHE_PROJECT="$project"
  DOPPLER_CACHE_CONFIG="$config"
}

# Check current doppler cache status
doppler_cache_info() {
  echo "Project: ${DOPPLER_CACHE_PROJECT:-none}"
  echo "Config:  ${DOPPLER_CACHE_CONFIG:-none}"
  echo "Secrets: $((${#DOPPLER_CACHE[@]:-0}))"
}

# Read a doppler key from cache
# Returns exit 1 when key is missing and no default is provided.
doppler_get() {
  local key="$1"
  local default="${2-}"

  [[ -z "$key" ]] && {
    printf 'doppler_get: key required\n' >&2
    return 1
  }

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

# debug
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

# zsh-only: associative arrays and typeset -gA are not available in bash
[[ -n "${ZSH_VERSION:-}" ]] || return 0

# Guard: cache must be loaded before secret functions are useful
if [[ -z "${DOPPLER_CACHE_PROJECT:-}" ]]; then
  printf 'doppler-secrets.sh: cache not loaded; run load_doppler_cache first\n' >&2
  return 1
fi

# Env var name -> doppler key name (only non-identity mappings needed)
typeset -gA _DOPPLER_SECRET_NAMES
_DOPPLER_SECRET_NAMES=(
  [OTEL_INGEST_ROUTE]=OBTOOL_INGEST_ROUTE
  [OTEL_INGEST_URL]=OBTOOL_INGEST_URL
  [OTEL_INGEST_PREVIEW_URL]=OBTOOL_INGEST_PREVIEW_URL
  [OTEL_API_KEY]=OBTOOL_API_KEY
)

# Reverse mapping: doppler key name -> env var alias (built from _DOPPLER_SECRET_NAMES)
typeset -gA _DOPPLER_REVERSE_NAMES
_DOPPLER_REVERSE_NAMES=()
local _env _dop
for _env _dop in "${(@kv)_DOPPLER_SECRET_NAMES}"; do
  _DOPPLER_REVERSE_NAMES[$_dop]="$_env"
done
unset _env _dop

# All available secret names — derived from DOPPLER_CACHE keys at source time.
# Filters out Doppler metadata keys (DOPPLER_PROJECT, DOPPLER_CONFIG, DOPPLER_ENVIRONMENT).
typeset -ga _DOPPLER_ALL_SECRETS
_DOPPLER_ALL_SECRETS=()
local _k
for _k in "${(@k)DOPPLER_CACHE}"; do
  [[ "$_k" == DOPPLER_* ]] && continue
  _DOPPLER_ALL_SECRETS+=("$_k")
done
unset _k

# Standard configs for multi-config operations
typeset -ga _DOPPLER_CONFIGS
_DOPPLER_CONFIGS=("dev" "staging" "production")

# Get a secret value without exporting (reads from cache)
# Returns exit code 1 if the secret is empty or missing.
secret() {
  if [[ ! "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    printf 'secret: invalid identifier: %s\n' "$1" >&2
    return 1
  fi
  local key="${_DOPPLER_SECRET_NAMES[$1]:-$1}"
  local val="${DOPPLER_CACHE[$key]}"
  if [[ -z "$val" ]]; then
    val="${(P)1}"
  fi
  if [[ -z "$val" ]]; then
    printf 'secret: %s not found\n' "$1" >&2
    return 1
  fi
  printf '%s' "$val"
}

# Export specific secrets into the environment
doppler_export() {
  local var key val failed=0
  for var in "$@"; do
    if [[ ! "$var" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      printf 'doppler_export: invalid identifier: %s\n' "$var" >&2
      return 1
    fi
    key="${_DOPPLER_SECRET_NAMES[$var]:-$var}"
    val="${DOPPLER_CACHE[$key]}"
    if [[ -z "$val" ]]; then
      printf 'doppler_export: %s not found in cache\n' "$var" >&2
      (( failed++ ))
      continue
    fi
    export "$var"="$val"
  done
  if (( failed > 0 )); then
    printf 'doppler_export: %d secrets not found\n' "$failed" >&2
    return 1
  fi
}

# Export all cached secrets (backward-compat escape hatch)
# Exports each Doppler key under its env alias if one exists, otherwise under its own name.
doppler_export_all() {
  local failed=0
  local doppler_key env_name val
  for doppler_key in "${_DOPPLER_ALL_SECRETS[@]}"; do
    env_name="${_DOPPLER_REVERSE_NAMES[$doppler_key]:-$doppler_key}"
    val="${DOPPLER_CACHE[$doppler_key]}"
    if [[ -z "$val" ]]; then
      printf 'doppler_export_all: %s not found in cache (skipped)\n' "$doppler_key" >&2
      (( failed++ ))
      continue
    fi
    export "$env_name"="$val"
  done
  if (( failed > 0 )); then
    printf 'doppler_export_all: %d secrets skipped\n' "$failed" >&2
  fi
}

# Copy a secret key-value pair from one project to another across all three configs
# Usage: doppler_copy_secret <key> <source-project> <target-project>
doppler_copy_secret() {
  local key="$1" source_project="$2" target_project="$3"
  local config value failed=0

  # Validate parameters
  if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || [[ -z "$source_project" || -z "$target_project" ]]; then
    printf 'doppler_copy_secret: invalid key, source-project, or target-project\n' >&2
    return 1
  fi

  # Fetch values from source for all configs, then parallelize sets to target
  local -a values=() pids=()
  local i
  for config in "${_DOPPLER_CONFIGS[@]}"; do
    if value=$(doppler secrets get "$key" --project "$source_project" --config "$config" --plain 2>/dev/null); then
      values+=("$value")
      # Spawn set in background
      doppler secrets set "$key" "$value" --project "$target_project" --config "$config" &
      pids+=($!)
    else
      printf 'doppler_copy_secret: %s not found in %s/%s\n' "$key" "$source_project" "$config" >&2
      (( failed++ ))
      values+=("")
    fi
  done

  # Wait for all background jobs
  for i in "${pids[@]}"; do wait "$i" || (( failed++ )); done

  if (( failed > 0 )); then
    printf 'doppler_copy_secret: %d operation(s) failed\n' "$failed" >&2
    return 1
  fi
}
