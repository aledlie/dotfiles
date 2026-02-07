# Shell aliases

# Doppler project names
export DOPPLER_PROJECT_STUDIO="integrity-studio"
export DOPPLER_PROJECT_ANALYTICS="analyticsbot"
export DOPPLER_PROJECT_TAILSCALE="tailscale-mcp"
export DOPPLER_PROJECT_PERSONAL="personal-info"
export DOPPLER_PROJECT_ACCOUNTING="accounting"
export DOPPLER_PROJECT_ATX="atx-movement"
export DOPPLER_PROJECT_BOTTLENECK="bottleneck"
export DOPPLER_PROJECT_FINANCIAL="financial-hub"
export DOPPLER_PROJECT_LEGAL="legal"
export DOPPLER_PROJECT_PROPERTY="property"
export DOPPLER_CONFIG_DEFAULT="dev"

# Doppler secret key names (project: tailscale-mcp)
export DOPPLER_KEY_TAILSCALE_API="TAILSCALE_API_KEY"
export DOPPLER_KEY_TAILSCALE_TAILNET="TAILSCALE_TAILNET"

# Doppler secret key names (project: analyticsbot)
export DOPPLER_KEY_SIGNOZ_INGESTION="SIGNOZ_INGESTION_KEY"
export DOPPLER_KEY_SIGNOZ_API="SIGNOZ_API_KEY"
export DOPPLER_KEY_LANGTRACE="LANGTRACE_API_KEY"
export DOPPLER_KEY_META_ACCESS="META_ACCESS_TOKEN"
export DOPPLER_KEY_GOOGLE_EMAIL="GOOGLE_CLIENT_EMAIL"
export DOPPLER_KEY_GOOGLE_PRIVKEY="GOOGLE_PRIVATE_KEY"
export DOPPLER_KEY_GA_PROPERTY="GA_PROPERTY_ID"
export DOPPLER_KEY_RESEND="RESEND_API_KEY"

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
