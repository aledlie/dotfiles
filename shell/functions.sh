# Custom shell functions

# Load Doppler values into cache
# both bash/zsh friendly
load_doppler_cache() {
  local project="${1:-integrity-studio}"
  local config="${2:-dev}"

  if [[ "${DOPPLER_CACHE_PROJECT:-}" == "$project" && "${DOPPLER_CACHE_CONFIG:-}" == "$config" ]]; then
    return
  fi

  if [[ -n "${ZSH_VERSION:-}" ]]; then
    typeset -gA DOPPLER_CACHE
    typeset -g DOPPLER_CACHE_PROJECT
    typeset -g DOPPLER_CACHE_CONFIG
  else
    declare -gA DOPPLER_CACHE
    declare -g DOPPLER_CACHE_PROJECT
    declare -g DOPPLER_CACHE_CONFIG
  fi

  DOPPLER_CACHE=()

  while IFS=$'\t' read -r k v; do
    DOPPLER_CACHE[$k]="$v"
  done < <(
    doppler secrets download \
      --no-file \
      --format json \
      --project "$project" \
      --config "$config" |
    jq -r 'to_entries[] | [.key, (.value // "")] | @tsv'
  )

  DOPPLER_CACHE_PROJECT="$project"
  DOPPLER_CACHE_CONFIG="$config"
}

# Check current doppler cache status
doppler_cache_info() {
  echo "Project: ${DOPPLER_CACHE_PROJECT:-none}"
  echo "Config:  ${DOPPLER_CACHE_CONFIG:-none}"
  echo "Secrets: ${#DOPPLER_CACHE[@]}"
}

# Read a doppler key from cache
doppler_get() {
  local key="$1"
  local default="$2"

  [[ -z "$key" ]] && {
    printf '%s\n' "$default"
    return
  }

  [[ -v "DOPPLER_CACHE[$key]" && -n "${DOPPLER_CACHE[$key]}" ]] && {
    printf '%s\n' "${DOPPLER_CACHE[$key]}"
    return
  }

  printf '%s\n' "$default"
}

# debug
doppler_cache_has() {
  local key="$1"

  if [[ -n "${DOPPLER_CACHE[$key]+x}" ]]; then
    echo "found: $key"
  else
    echo "missing: $key"
  fi
}

doppler_cache_debug() {
  local key="$1"

  if [[ -v "DOPPLER_CACHE[$key]" ]]; then
    echo "found key: $key"
    echo "value length: ${#DOPPLER_CACHE[$key]}"
    printf 'value: [%s]\n' "${DOPPLER_CACHE[$key]}"
  else
    echo "missing key: $key"
  fi
}
# Directory size function - finds directory sizes and lists them for the current directory
dirsize() {
    local tmpfile
    tmpfile=$(mktemp) || return 1
    trap 'rm -f "$tmpfile"' RETURN
    du -shx * .[a-zA-Z0-9_]* 2>/dev/null | \
    grep -E '^ *[0-9.]*[MG]' | sort -n > "$tmpfile"
    grep -E '^ *[0-9.]*M' "$tmpfile"
    grep -E '^ *[0-9.]*G' "$tmpfile"
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
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
    ps aux | grep -i "$1" | grep -v grep
}

# Quick backup of a file
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Weather function (requires curl)
weather() {
    local city="${1:-}"
    if [ -n "$city" ]; then
        if [[ "$city" =~ [^[:alpha:][:digit:]\ ,.\-] ]]; then
            echo "[dotfiles] weather: invalid city name" >&2
            return 1
        fi
        curl -s "wttr.in/${city// /+}"
    else
        curl -s "wttr.in"
    fi
}

# Git functions
git_current_branch() {
    git branch 2>/dev/null | grep '^*' | colrm 1 2
}

# Quick git commit
qcommit() {
    git add -A && git commit -m "$1"
}

# Create and switch to new git branch
newbranch() {
    git checkout -b "$1"
}
