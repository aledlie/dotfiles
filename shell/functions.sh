# Custom shell functions (non-Doppler utility functions)

dirsize() {
    # Anchor on the size field: BSD du right-pads it ("772M" has no leading
    # space, " 12M" does) and GNU du doesn't pad at all, so a bare ' [0-9.]*[MG]'
    # silently drops entries. Match from line start instead.
    find . -maxdepth 1 -type d -print0 | xargs -0 du -sh | \
    grep -E '^ *[0-9.]+[MG]' | sort -h -k1
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
  mkdir -p "$1" && cd "$1" || return
}

# Create and switch to new git branch
newbranch() {
    [[ -n "$1" ]] || { echo "Usage: newbranch <name>" >&2; return 1; }
    git checkout -b "$1"
}
