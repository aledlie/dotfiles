## ----------------- Base values ----------------- ##
# Leviathan (macOS) architecture
export ARCH="$(uname -m)"

# Doppler project names
export DOPPLER_PROJECT_INTEGRITY="integrity-studio"
export DOPPLER_PROJECT_ANALYTICS="analyticsbot"
export DOPPLER_PROJECT_PERSONAL="personal-info"
export DOPPLER_PROJECT_ACCOUNTING="accounting"
export DOPPLER_PROJECT_ATX="atx-movement"
export DOPPLER_PROJECT_BOTTLENECK="bottleneck"
export DOPPLER_PROJECT_FINANCIAL="financial-hub"
export DOPPLER_PROJECT_LEGAL="legal"
export DOPPLER_PROJECT_PROPERTY="property"
export DOPPLER_CONFIG_DEFAULT="dev"
export DOPPLER_CONFIG_PRODUCTION="production"
# Sentry org-level values
export SENTRY_DISPLAY_NAME="integrity"
export SENTRY_ORG_SLUG="integrity-jq"
export SENTRY_ORG="integrity-jq"
export SENTRY_ORG_ID=4510317437124608
# Global config values for OTEL-based obtool-ingest
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
export OTEL_EXPORTER_OTLP_COMPRESSION="gzip"
export OTEL_EXPORTER_OTLP_TIMEOUT="5000"
export OTEL_SERVICE_NAME="claude-code-hooks"
export OTEL_RESOURCE_ATTRIBUTES="deployment.environment=development,service.version=1.0.0,user.name=alyshia"
# Claude Code directories (global for hooks in any directory)
export CLAUDE_CONFIG_DIR="$HOME/.claude"
export CLAUDE_LOGS_DIR="$CLAUDE_CONFIG_DIR/logs"
export CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME}"
export CLAUDE_TELEMETRY_DIR="$CLAUDE_CONFIG_DIR/telemetry"

# ------------------ Doppler secrets (lazy-loaded) -------------- #
# Secrets are NOT exported on startup. Use these patterns instead:
#   secret GITHUB_TOKEN                        # one-shot read (no export)
#   GITHUB_TOKEN=$(secret GITHUB_TOKEN) git push  # inline for a single command
#   doppler_export GITHUB_TOKEN STRIPE_API_KEY # export specific vars
#   doppler_export_all                         # export everything (rare)
# See _DOPPLER_ALL_SECRETS in doppler-secrets.sh for the full list of available names.

# -------------------- Convenience Aliases ---------------- #

# LS_COLORS for GNU ls (colorflag and ls alias are set in common.sh)
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

# Listing variants (uses ls alias from common.sh)
alias l="ls -lF $colorflag"
alias ll="ls -lv --group-directories-first"
alias lm="ll |more"
alias lr="ll -r"
alias la="ll -laf"
alias tree="tree -Csuh"

# Enable aliases to be sudo'ed
alias sudo='sudo '

# Python shortcut
alias python=python3

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias home="cd ~"
alias -- -="cd -"

# Shortcuts
alias dropbox="cd ~/Dropbox\ \(Personal\)"
alias downloads="cd ~/Downloads"
alias desktop="cd ~/Desktop"
alias code="cd ~/code"
alias h="history"

# Common project paths
alias jobs="~/code/jobs"
alias integrity-ai="~/code/is-public-sites/IntegrityStudioLandingPage"
alias obtool="~/.claude/mcp-servers/observability-toolkit"
alias obtool-ui="~/.claude/mcp-servers/observability-toolkit/dashboard"
alias tcad="~/code/is-public-sites/tcad-scraper"
alias blog="~/code/PersonalSite"
alias reports="~/reports"
alias ast="~/code/ast-grep-mcp"

# Doppler shorthand
alias dp="doppler secrets --project integrity-studio --config dev --"

# IP addresses
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Clipboard
alias c="tr -d '\n' | pbcopy"

# Cleanup
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Intuitive map function
alias map="xargs -n1"

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Reload shell
alias reload="exec $SHELL -l"

# Volume control
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 7'"

# Kill Chrome renderer tabs
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Lock screen
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# OS X fallbacks
command -v md5sum > /dev/null || alias md5sum="md5"
command -v sha1sum > /dev/null || alias sha1sum="shasum"

# URL-encode strings
alias urlencode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus(sys.argv[1]))"'

# Merge PDF files
alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'

# PlistBuddy
alias plistbuddy="/usr/libexec/PlistBuddy"

# HTTP method aliases
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
	alias "$method"="lwp-request -m '$method'"
done

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

    # Trash and system logs
    alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

    # Finder visibility
    alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
    alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
    alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

    # LaunchServices cleanup
    alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

    # Spotlight
    alias spoton="sudo mdutil -a -i on"
fi
