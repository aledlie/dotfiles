# -------------------- Convenience Aliases - all archs --------------- #

# Listing variants (ls alias and LS_COLORS set in common.sh via dircolors)
# ---- eza (ls replacement) ----
EZA_BASE="eza --icons --group-directories-first --git"
alias ls="$EZA_BASE"
alias ll="$EZA_BASE -lh"
alias la="$EZA_BASE -lha"
alias lt="$EZA_BASE --tree"
alias tree="tree -Csuh"

# ---------- eza / ls fallbacks ----------

if command -v eza >/dev/null 2>&1; then
  EZA_BASE='eza --icons --group-directories-first'
  alias ls="$EZA_BASE"
  alias ll="$EZA_BASE -lh"
  alias la="$EZA_BASE -lha"
  alias lt="$EZA_BASE --tree"
else
  alias ls='_plain_ls'
  alias ll='_plain_ls -lh'
  alias la='_plain_ls -lha'
  # tree fallback: prefer tree, otherwise use find
  if command -v tree >/dev/null 2>&1; then
    alias lt='tree -C'
  else
    alias lt='find . -print'
  fi
fi

# ---------- bat / cat fallbacks ----------

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
  # Only alias bat if batcat exists to avoid undefined command
  alias bat='batcat'
fi

# ---------- fzf ----------

if command -v fzf >/dev/null 2>&1; then
  # Load fzf shell integration if present
  [ -f ~/.fzf.bash ] && . ~/.fzf.bash
  [ -f ~/.fzf.zsh ] && . ~/.fzf.zsh

  # Better previews if bat/batcat is available
  if command -v bat >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range=:200 {}'"
  elif command -v batcat >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --preview 'batcat --style=numbers --color=always --line-range=:200 {}'"
  else
    export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --preview 'sed -n \"1,200p\" {}'"
  fi

  # Fuzzy cd into subdirectories
  fcd() {
    local dir
    dir="$(find . -type d 2>/dev/null | fzf)" && cd "$dir"
  }

  # Fuzzy open file in editor
  fe() {
    local file
    file="$(find . -type f 2>/dev/null | fzf)" && "$EDITOR" "$file"
  }
else
  # Sensible non-fzf fallbacks
  fcd() {
    printf '%s\n' "fzf is not installed"
    return 1
  }

  fe() {
    printf '%s\n' "fzf is not installed"
    return 1
  }
fi

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

# handy extras
alias dp="doppler secrets --project integrity-studio --config dev --" # get doppler value
alias grep='grep --color=auto 2>/dev/null || grep' # pretty grpe

# ips function - extract IPv4/IPv6 addresses (must be function, not alias with pipes)
ips() {
  ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, ""); print }'
}

alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias map="xargs -n1"
alias week='date +%V'
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'
alias reload='exec /opt/homebrew/bin/zsh -l' # reload shell
# URL-encode strings (python)
alias urlencode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus(sys.argv[1]))"'

# HTTP method functions - must be functions, not aliases (aliases can't contain pipes safely)
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
	eval "${method}() { lwp-request -m '${method}' \"\$@\"; }"
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

# ---- clipboard - Ubuntu & linux safe ----
command -v xclip >/dev/null && alias c="tr -d '\n' | xclip -selection clipboard"
command -v xsel >/dev/null && alias c="tr -d '\n' | xsel --clipboard"
