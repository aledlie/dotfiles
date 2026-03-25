# Custom shell functions

# Load Doppler values into cache
# both bash/zsh friendly
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

# Directory size function - finds directory sizes and lists them for the current directory
dirsize() {
    find . -maxdepth 1 -type d -print0 | xargs -0 du -sh | \
    grep -E ' [0-9.]*[MG]' | sort -h -k1
}


# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find process by name
findproc() {
    ps aux | grep -v grep | grep -i "$1"
}

# Quick backup of a file
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Git functions
git_current_branch() {
    git branch --show-current 2>/dev/null
}

# mkdir and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Create and switch to new git branch
newbranch() {
    [[ -n "$1" ]] || { echo "Usage: newbranch <name>" >&2; return 1; }
    git checkout -b "$1"
}
