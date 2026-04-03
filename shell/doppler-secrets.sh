# Doppler secret registry — lazy-loaded, never exported on startup.
# Requires: doppler_get (from functions.sh), load_doppler_cache (already called)
#
# Usage:
#   secret GITHUB_TOKEN                          # one-shot read (no export)
#   GITHUB_TOKEN=$(secret GITHUB_TOKEN) git push # inline for a single command
#   doppler_export GITHUB_TOKEN STRIPE_API_KEY   # export specific vars
#   doppler_export_all                           # export everything (rare)
#
# Note: secrets with raw embedded newlines (e.g. PEM keys) are truncated by
# command substitution. Escaped \n literals in JSON values are unaffected.

# zsh-only: associative arrays and typeset -gA are not available in bash
[[ -n "${ZSH_VERSION:-}" ]] || return 0

# Guard: cache must be loaded before this file is useful
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
