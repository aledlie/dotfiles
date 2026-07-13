# Convenience aliases (ls colors set in common.sh via dircolors)

# ---------- eza / ls fallbacks ----------
if command -v eza >/dev/null 2>&1; then
  EZA_BASE='eza --icons --group-directories-first'
  alias ls="$EZA_BASE"
  alias l="$EZA_BASE -lh"
  alias ll="$EZA_BASE -lh"
  alias la="$EZA_BASE -lha"
  alias lt="$EZA_BASE --tree"
else
  alias ls='_plain_ls'
  alias l='_plain_ls -lh'
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

# Resolve the bat binary once (Debian ships it as batcat); reused by fzf preview.
if command -v bat >/dev/null 2>&1; then
  _bat_cmd='bat'
elif command -v batcat >/dev/null 2>&1; then
  _bat_cmd='batcat'
  alias bat='batcat'
fi
[[ -n "$_bat_cmd" ]] && alias cat="$_bat_cmd --paging=never"

# ---------- fzf ----------

if command -v fzf >/dev/null 2>&1; then
  # Better previews if bat/batcat is available
  if [[ -n "$_bat_cmd" ]]; then
    export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --preview \"$_bat_cmd --style=numbers --color=always --line-range=:200 {}\""
  else
    export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
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

# Python: defer to pyenv shims (set up in common.sh) instead of pinning a version.

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

ips() {
  ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, ""); print }'
}

alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias map="xargs -n1"
alias week='date +%V'
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'
alias reload='exec "$SHELL" -l'
# URL-encode strings (python)
alias urlencode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus(sys.argv[1]))"'

GET()     { lwp-request -m GET     "$@"; }
HEAD()    { lwp-request -m HEAD    "$@"; }
POST()    { lwp-request -m POST    "$@"; }
PUT()     { lwp-request -m PUT     "$@"; }
DELETE()  { lwp-request -m DELETE  "$@"; }
TRACE()   { lwp-request -m TRACE   "$@"; }
OPTIONS() { lwp-request -m OPTIONS "$@"; }

# macOS specific aliases
if [[ "$OSTYPE" == darwin* ]]; then
    # Volume control
    alias stfu="osascript -e 'set volume output muted true'"
    alias pumpitup="osascript -e 'set volume 7'"
    c() { tr -d '\n' | pbcopy; }

   # Kill Chrome renderer tabs
    chromekill() { ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill; }

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
    alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install -g npm@latest; npm update -g; sudo gem update --system; sudo gem update'

    # Applications
    alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

    # Network
    alias localip="ipconfig getifaddr en0"
    alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

    # Network monitoring
    alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
    httpdump() { sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E 'Host\: .*|GET /.*'; }

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
elif command -v xclip >/dev/null 2>&1; then
    c() { tr -d '\n' | xclip -selection clipboard; }
elif command -v xsel >/dev/null 2>&1; then
    c() { tr -d '\n' | xsel --clipboard; }
fi

# Explicit Wireshark tshark alias (removed from PATH for security).
# Only alias when the macOS bundle exists, so on Linux a real tshark on PATH
# is not shadowed by a nonexistent path.
[[ -x '/Applications/Wireshark.app/Contents/MacOS/tshark' ]] && \
    alias tshark='/Applications/Wireshark.app/Contents/MacOS/tshark'

unset _bat_cmd
