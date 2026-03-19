# -------------------- Convenience Aliases - all archs --------------- #

# Listing variants (ls alias and LS_COLORS set in common.sh via dircolors)
# ---- eza (ls replacement) ----
EZA_BASE="eza --icons --group-directories-first --git"
alias ls="$EZA_BASE"
alias ll="$EZA_BASE -lh"
alias la="$EZA_BASE -lha"
alias lt="$EZA_BASE --tree"
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
alias jobs="cd ~/code/jobs"
alias integrity-ai="cd ~/code/is-public-sites/IntegrityStudioLandingPage"
alias obtool="cd ~/.claude/mcp-servers/observability-toolkit"
alias obtool-ui="cd ~/.claude/mcp-servers/observability-toolkit/dashboard"
alias tcad="cd ~/code/is-public-sites/tcad-scraper"
alias blog="cd ~/code/PersonalSite"
alias reports="cd ~/reports"
alias ast="cd ~/code/ast-grep-mcp"

# Doppler shorthand
alias dp="doppler secrets --project integrity-studio --config dev --"

# MCP server quick toggle
alias mcp-webresearch='claude mcp add open-webresearch -s user -- docker run -i ghcr.io/rinaldowouterson/mcp-open-webresearch:latest'

# IP addresses
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

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

# URL-encode strings
alias urlencode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus(sys.argv[1]))"'

# HTTP method aliases
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
	alias "$method"="lwp-request -m '$method'"
done

# macOS specific aliases
if [[ "$ARCH" == "macos" ]]; then
    # Volume control
    alias stfu="osascript -e 'set volume output muted true'"
    alias pumpitup="osascript -e 'set volume 7'"
    alias c="tr -d '\n' | pbcopy"

   # Kill Chrome renderer tabs
    alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

    # Lock screen
    alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

    # Hash fallbacks
    command -v md5sum > /dev/null || alias md5sum="md5"
    command -v sha1sum > /dev/null || alias sha1sum="shasum"

    # Merge PDF files
    alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'

    # PlistBuddy
    alias plistbuddy="/usr/libexec/PlistBuddy"

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

# ---- bat fix & clipboard - Ubuntu & linux safe ----
command -v batcat >/dev/null && alias bat='batcat'
command -v xclip >/dev/null && alias c="tr -d '\n' | xclip -selection clipboard"
command -v xsel >/dev/null && alias c="tr -d '\n' | xsel --clipboard"
