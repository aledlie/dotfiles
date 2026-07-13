# zsh-only Doppler helpers. Sourced by shell/doppler-secrets.sh in zsh.
# Uses zsh-specific parameter expansions (${(@k)...}, ${(@kv)...}) and
# associative arrays (typeset -gA) that bash cannot parse.

# Rebuild the _DOPPLER_ALL_SECRETS list from current DOPPLER_CACHE keys.
# Filters out Doppler metadata keys (DOPPLER_PROJECT, DOPPLER_CONFIG, DOPPLER_ENVIRONMENT).
_rebuild_doppler_all_secrets() {
  typeset -ga _DOPPLER_ALL_SECRETS
  _DOPPLER_ALL_SECRETS=()
  local _k
  for _k in "${(@k)DOPPLER_CACHE}"; do
    [[ "$_k" == DOPPLER_* ]] && continue
    _DOPPLER_ALL_SECRETS+=("$_k")
  done
}

# Startup secret fetch lives in shell/doppler-secrets.sh (shared with bash);
# it runs after this file is sourced, so the real _rebuild_doppler_all_secrets
# above is in place before the cache is populated.

# Env var name -> doppler key name (only non-identity mappings needed)
# Note: per-key assignment avoids a zsh -n parse warning with compound [KEY]=VALUE literals.
typeset -gA _DOPPLER_SECRET_NAMES
_DOPPLER_SECRET_NAMES[OTEL_INGEST_ROUTE]=OBTOOL_INGEST_ROUTE
_DOPPLER_SECRET_NAMES[OTEL_INGEST_URL]=OBTOOL_INGEST_URL
_DOPPLER_SECRET_NAMES[OTEL_INGEST_PREVIEW_URL]=OBTOOL_INGEST_PREVIEW_URL
_DOPPLER_SECRET_NAMES[OTEL_API_KEY]=OBTOOL_API_KEY

# Reverse mapping: doppler key name -> env var alias (built from _DOPPLER_SECRET_NAMES)
typeset -gA _DOPPLER_REVERSE_NAMES
_DOPPLER_REVERSE_NAMES=()
typeset _env _dop
for _env _dop in "${(@kv)_DOPPLER_SECRET_NAMES}"; do
  _DOPPLER_REVERSE_NAMES[$_dop]="$_env"
done
unset _env _dop

_rebuild_doppler_all_secrets

# Standard configs for multi-config operations
typeset -ga _DOPPLER_CONFIGS
_DOPPLER_CONFIGS=("$CONFIG_DEV" "$CONFIG_STAGING" "$CONFIG_PRODUCTION")

# Get a secret value without exporting (reads from cache)
# Returns exit code 1 only if the key is absent from the cache; a key that is
# present with an empty value prints nothing and returns 0. (doppler_export, by
# contrast, treats an empty value as not-found.)
secret() {
  if ! _is_valid_identifier "$1"; then
    printf 'secret: invalid identifier: %s\n' "$1" >&2
    return 1
  fi
  local key="${_DOPPLER_SECRET_NAMES[$1]:-$1}"
  if [[ -n "${DOPPLER_CACHE[$key]+set}" ]]; then
    printf '%s' "${DOPPLER_CACHE[$key]}"
    return 0
  fi
  printf 'secret: %s not found\n' "$1" >&2
  return 1
}

# Export specific secrets into the environment
doppler_export() {
  local var key val failed=0
  for var in "$@"; do
    if ! _is_valid_identifier "$var"; then
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

  if ! _is_valid_identifier "$key" || [[ -z "$source_project" || -z "$target_project" ]]; then
    printf 'doppler_copy_secret: invalid key, source-project, or target-project\n' >&2
    return 1
  fi

  local -a pids=()
  local pid
  for config in "${_DOPPLER_CONFIGS[@]}"; do
    if value=$(doppler secrets get "$key" --project "$source_project" --config "$config" --plain 2>/dev/null); then
      doppler secrets set "$key" "$value" --project "$target_project" --config "$config" &
      pids+=($!)
    else
      printf 'doppler_copy_secret: %s not found in %s/%s\n' "$key" "$source_project" "$config" >&2
      (( failed++ ))
    fi
  done

  for pid in "${pids[@]}"; do wait "$pid" || (( failed++ )); done

  if (( failed > 0 )); then
    printf 'doppler_copy_secret: %d operation(s) failed\n' "$failed" >&2
    return 1
  fi
}
