# Shell aliases

# Platform-specific color flags
if [[ "$PLATFORM" == "macos" ]]; then
    colorflag="-G"
    # Use GNU ls if available (installed via brew install coreutils)
    if command -v gls >/dev/null 2>&1; then
        alias ls='gls --color=auto'
    else
        alias ls='ls -G'
    fi
else
    colorflag="--color=auto"
    alias ls='ls --color=auto'
fi

# Basic aliases
alias ll='ls -al'
alias la='ls -A'
alias l='ls -CF'

# Enable aliases to be sudo'ed
alias sudo='sudo '

# macOS specific aliases
if [[ "$PLATFORM" == "macos" ]]; then
    # System update
    alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update'

    # Applications
    alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

    # Network
    alias localip="ipconfig getifaddr en0"
    alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

    # Network monitoring
    alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
    alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
fi

# IP addresses
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Git aliases (if not using git aliases)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Development
alias serve='python -m http.server 8000'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

#Authentication
alias doppler="doppler secrets --project integrity-studio --config dev --"
