## ----------------- Base values ----------------- ##
# Leviathan (macOS) architecture
export ARCH="amd64"

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
# OpenTelemetry (global for hooks in any directory)
export CLAUDE_TELEMETRY_DIR="$CLAUDE_CONFIG_DIR/telemetry"

# ------------------ Doppler secrets -------------- #

# Anthropic
export ANTHROPIC_API_KEY="$(doppler_get "ANTHROPIC_API_KEY")"
export CLAUDE_API_KEY_ADMIN="$(doppler_get "CLAUDE_API_KEY_ADMIN")"
export CLAUDE_API_KEY_SUDO="$(doppler_get "CLAUDE_API_KEY_SUDO")"
# Google Analytics4 and Meta/Facebook Marketing API (for meta-ads MCP server)
export META_ACCESS_TOKEN="$(doppler_get "META_ACCESS_TOKEN")"
export GOOGLE_ANALYTICS_MEASUREMENT_ID="$(doppler_get "GOOGLE_ANALYTICS_MEASUREMENT_ID")"
export GTM_CONTAINER_ID="$(doppler_get "GTM_CONTAINER_ID")"
# Google OAUTH
export GOOGLE_CLIENT_EMAIL="$(doppler_get "GOOGLE_CLIENT_EMAIL")"
export GOOGLE_PRIVATE_KEY="$(doppler_get "GOOGLE_PRIVATE_KEY")"
export GOOGLE_OAUTH_CLIENT_ID_CALENDAR="$(doppler_get "GOOGLE_OAUTH_CLIENT_ID_CALENDAR")"
export GOOGLE_OAUTH_CLIENT_SECRET_CALENDAR="$(doppler_get "GOOGLE_OAUTH_CLIENT_SECRET_CALENDAR")"
export GOOGLE_TAG_MANAGER_CONTAINER_ID="$(doppler_get "GOOGLE_TAG_MANAGER_CONTAINER_ID")"
# Resend Email API (for resend MCP server)
export RESEND_API_KEY="$(doppler_get "RESEND_API_KEY")"
export LANGTRACE_ACCESS_TOKEN="$(doppler_get "LANGTRACE_ACCESS_TOKEN")"
export LANGTRACE_API_KEY="$(doppler_get "LANGTRACE_API_KEY")"
# Obtool-ingest
export OTEL_INGEST_ROUTE="$(doppler_get "OBTOOL_INGEST_ROUTE")"
export OTEL_INGEST_URL="$(doppler_get "OBTOOL_INGEST_URL")"
export OTEL_INGEST_PREVIEW_URL="$(doppler_get "OBTOOL_INGEST_PREVIEW_URL")"
export OTEL_API_KEY="$(doppler_get "OBTOOL_API_KEY")"
# SENTRY values for (by default) integrity-studio projects
export SENTRY_DSN="$(doppler_get "SENTRY_DSN")"
export SENTRY_AUTH_TOKEN="$(doppler_get "SENTRY_AUTH_TOKEN")"
export SENTRY_API_TOKEN="$(doppler_get "SENTRY_API_TOKEN")"
export SENTRY_TOKEN="$(doppler_get "SENTRY_TOKEN")"
export SENTRY_TOKEN_HEADER="$(doppler_get "SENTRY_TOKEN_HEADER")"
export FILE_SYSTEM_SENTRY_DSN="$(doppler_get "FILE_SYSTEM_SENTRY_DSN")"
export VITE_SENTRY_DSN="$(doppler_get "VITE_SENTRY_DSN")"
export DOPPLER_DSN="$(doppler_get "DOPPLER_DSN")"
# Facebook/Meta
export FB_ANALYTICS_APP_ID="$(doppler_get "FB_ANALYTICS_APP_ID")"
export FB_APP_ID="$(doppler_get "FB_APP_ID")"
export FB_APP_SECRET="$(doppler_get "FB_APP_SECRET")"
export FB_PIXEL_ID="$(doppler_get "FB_PIXEL_ID")"
export FB_REDIRECT_URI="$(doppler_get "FB_REDIRECT_URI")"
# Google
export GCLOUD_RW_API_KEY="$(doppler_get "GCLOUD_RW_API_KEY")"
export GEMINI_API_KEY="$(doppler_get "GEMINI_API_KEY")"
export GOOGLE_ANALYTICS_API_SECRET="$(doppler_get "GOOGLE_ANALYTICS_API_SECRET")"
export GMAIL_APP_CLIENT_ID="$(doppler_get "GMAIL_APP_CLIENT_ID")"
export GMAIL_APP_SECRET="$(doppler_get "GMAIL_APP_SECRET")"
export GOOGLE_AUTH_CLIENT_SECRET_JSON_2="$(doppler_get "GOOGLE_AUTH_CLIENT_SECRET_JSON_2")"
export GOOGLE_CALENDAR_ACCESS_TOKEN="$(doppler_get "GOOGLE_CALENDAR_ACCESS_TOKEN")"
export GOOGLE_CALENDAR_REFRESH_TOKEN="$(doppler_get "GOOGLE_CALENDAR_REFRESH_TOKEN")"
export GOOGLE_MAPS_API_KEY="$(doppler_get "GOOGLE_MAPS_API_KEY")"
export GOOGLE_OAUTH_AUTH_PROVIDER_X509_CERT_URL="$(doppler_get "GOOGLE_OAUTH_AUTH_PROVIDER_X509_CERT_URL")"
export GOOGLE_OAUTH_CLIENT_ID_PERSONAL="$(doppler_get "GOOGLE_OAUTH_CLIENT_ID_PERSONAL")"
export GOOGLE_OAUTH_CLIENT_ID_SCHEDULER="$(doppler_get "GOOGLE_OAUTH_CLIENT_ID_SCHEDULER")"
export GOOGLE_OAUTH_CLIENT_SECRET="$(doppler_get "GOOGLE_OAUTH_CLIENT_SECRET")"
export GOOGLE_OAUTH_CLIENT_SECRET_PERSONAL="$(doppler_get "GOOGLE_OAUTH_CLIENT_SECRET_PERSONAL")"
export GOOGLE_OAUTH_CLIENT_SECRET_SCHEDULER="$(doppler_get "GOOGLE_OAUTH_CLIENT_SECRET_SCHEDULER")"
export GOOGLE_OAUTH_PROJECT_ID="$(doppler_get "GOOGLE_OAUTH_PROJECT_ID")"
export GOOGLE_OAUTH_REDIRECT_URIS="$(doppler_get "GOOGLE_OAUTH_REDIRECT_URIS")"
export GOOGLE_OAUTH_TOKEN_URI="$(doppler_get "GOOGLE_OAUTH_TOKEN_URI")"
export GOOGLE_PUBLIC_KEY="$(doppler_get "GOOGLE_PUBLIC_KEY")"
# HubSpot
export HUBSPOT_ACCOUNT_ID="$(doppler_get "HUBSPOT_ACCOUNT_ID")"
export HUBSPOT_DEV_KEY="$(doppler_get "HUBSPOT_DEV_KEY")"
export HUBSPOT_PAT="$(doppler_get "HUBSPOT_PAT")"
# JWT
export JWT_SECRET="$(doppler_get "JWT_SECRET")"
# Linked
export LINKEDIN_API_KEY="$(doppler_get "LINKEDIN_API_KEY")"
export LINKEDIN_CLIENT_ID="$(doppler_get "LINKEDIN_CLIENT_ID")"
export LINKEDIN_CLIENT_SECRET="$(doppler_get "LINKEDIN_CLIENT_SECRET")"
# Supabase
export NEXT_PUBLIC_SUPABASE_ANON_KEY="$(doppler_get "NEXT_PUBLIC_SUPABASE_ANON_KEY")"
export NEXT_PUBLIC_SUPABASE_URL="$(doppler_get "NEXT_PUBLIC_SUPABASE_URL")"
# NPM
export NPM_TOKEN="$(doppler_get "NPM_TOKEN")"
# OpenAI
export CODEX_API_KEY="$(doppler_get "CODEX_API_KEY")"
export OPEN_AI_ADMIN_KEY="$(doppler_get "OPEN_AI_ADMIN_KEY")"
export OPEN_AI_KEY="$(doppler_get "OPEN_AI_KEY")"
export OPENAI_ACCESS_TOKEN="$(doppler_get "OPENAI_ACCESS_TOKEN")"
export OPENAI_API_KEY="$(doppler_get "OPENAI_API_KEY")"
export OPENAI_REFRESH_TOKEN="$(doppler_get "OPENAI_REFRESH_TOKEN")"
# Playwright
export PLAYWRIGHT_BROWSERS_PATH="$(doppler_get "PLAYWRIGHT_BROWSERS_PATH")"
# Porkbun
export PORKBUN_API_KEY="$(doppler_get "PORKBUN_API_KEY")"
export PORKBUN_SECRET_API_KEY="$(doppler_get "PORKBUN_SECRET_API_KEY")"
# Supabase (React)
export REACT_APP_SUPABASE_ANON_KEY="$(doppler_get "REACT_APP_SUPABASE_ANON_KEY")"
export REACT_APP_SUPABASE_URL="$(doppler_get "REACT_APP_SUPABASE_URL")"
# Render-hosted REDIS
export REDIS_HOST="$(doppler_get "REDIS_HOST")"
export REDIS_PORT="$(doppler_get "REDIS_PORT")"
export REDIS_URL="$(doppler_get "REDIS_URL")"
# Render
export RENDER_API_KEY="$(doppler_get "RENDER_API_KEY")"
export RENDER_JOBS_API_KEY="$(doppler_get "RENDER_JOBS_API_KEY")"
# SSH
export SSH_PUBLIC_KEY_ED25519="$(doppler_get "SSH_PUBLIC_KEY_ED25519")"
# Stripe
export STRIPE_API_KEY="$(doppler_get "STRIPE_API_KEY")"
# Supabase
export SUPABASE_ACCESS_TOKEN="$(doppler_get "SUPABASE_ACCESS_TOKEN")"
export SUPABASE_DB_PASSWORD="$(doppler_get "SUPABASE_DB_PASSWORD")"
export SUPABASE_JWT_SECRET="$(doppler_get "SUPABASE_JWT_SECRET")"
export SUPABASE_SERVICE_KEY="$(doppler_get "SUPABASE_SERVICE_KEY")"
export SUPABASE_SERVICE_ROLE_KEY="$(doppler_get "SUPABASE_SERVICE_ROLE_KEY")"
export SUPABASE_URL="$(doppler_get "SUPABASE_URL")"
# Vite
export VITE_ANALYTICSBOT_API_URL="$(doppler_get "VITE_ANALYTICSBOT_API_URL")"
export VITE_ANALYTICSBOT_PROJECT_ID="$(doppler_get "VITE_ANALYTICSBOT_PROJECT_ID")"
export VITE_AUTH0_AUDIENCE="$(doppler_get "VITE_AUTH0_AUDIENCE")"
export VITE_AUTH0_CLIENT_ID="$(doppler_get "VITE_AUTH0_CLIENT_ID")"
export VITE_AUTH0_CLIENT_SECRET="$(doppler_get "VITE_AUTH0_CLIENT_SECRET")"
export VITE_AUTH0_DOMAIN="$(doppler_get "VITE_AUTH0_DOMAIN")"
export VITE_SUPABASE_ANON_KEY="$(doppler_get "VITE_SUPABASE_ANON_KEY")"
export VITE_SUPABASE_URL="$(doppler_get "VITE_SUPABASE_URL")"
# TCAD
export TCAD_WORKER_URL="$(doppler_get "TCAD_WORKER_URL")"
# Cloudflare
export CLOUDFLARE_ACCOUNT_ID="$(doppler_get "CLOUDFLARE_ACCOUNT_ID")"
export CLOUDFLARE_API_TOKEN="$(doppler_get "CLOUDFLARE_API_TOKEN")"
export CLOUDFLARE_GLOBAL_API_KEY="$(doppler_get "CLOUDFLARE_GLOBAL_API_KEY")"
export CLOUDFLARE_KV_NAMESPACE_ID="$(doppler_get "CLOUDFLARE_KV_NAMESPACE_ID")"
export CLOUDFLARE_OAUTH_TOKEN="$(doppler_get "CLOUDFLARE_OAUTH_TOKEN")"
export CLOUDFLARE_PAGES_DEPLOY_TOKEN="$(doppler_get "CLOUDFLARE_PAGES_DEPLOY_TOKEN")"
export CLOUDFLARE_PAGES_GITHUB_TOKEN="$(doppler_get "CLOUDFLARE_PAGES_GITHUB_TOKEN")"
export CLOUDFLARE_PAGES_TOKEN="$(doppler_get "CLOUDFLARE_PAGES_TOKEN")"
export CLOUDFLARE_REFRESH_TOKEN="$(doppler_get "CLOUDFLARE_REFRESH_TOKEN")"
export CLOUDFLARE_WORKER_TOKEN="$(doppler_get "CLOUDFLARE_WORKER_TOKEN")"
export CLOUDFLARE_ZONE_ID="$(doppler_get "CLOUDFLARE_ZONE_ID")"
export DEV_WORKER_URL="$(doppler_get "DEV_WORKER_URL")"
# Discord
export DISCORD_BOT_TOKEN="$(doppler_get "DISCORD_BOT_TOKEN")"
export DISCORD_CLIENT_ID="$(doppler_get "DISCORD_CLIENT_ID")"
export DISCORD_CLIENT_TOKEN="$(doppler_get "DISCORD_CLIENT_TOKEN")"
export DISCORD_TOKEN="$(doppler_get "DISCORD_TOKEN")"
# Misc
export COOKIE_SECRET="$(doppler_get "COOKIE_SECRET")"
# GitHub
export GITHUB_TOKEN="$(doppler_get "GITHUB_TOKEN")"

# -------------------- Convenience Aliases ---------------- #

# Color output for ls
colorflag="-G"
alias ls='gls --color=auto'
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

# Listing variants
alias l="ls -lF ${colorflag}"
alias ll="gls -lv --group-directories-first"
alias lm="ll --color |more"
alias lr="ll -r --color"
alias la="ll -laf --color"
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
alias doppler="doppler secrets --project integrity-studio --config dev --"

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
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

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
