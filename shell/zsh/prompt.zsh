# Zsh prompt configuration

# Enable parameter expansion, command substitution and arithmetic expansion in prompts
setopt PROMPT_SUBST

# Colors
autoload -U colors && colors

# Define color variables for easier use
local user_color="%{$fg[yellow]%}"
local host_color="%{$fg[green]%}"
local dir_color="%{$fg[blue]%}"
local git_color="%{$fg[red]%}"
local reset_color="%{$reset_color%}"

# Highlight the user name when logged in as root
if [[ "${USER}" == "root" ]]; then
    user_color="%{$fg_bold[red]%}"
fi

# Highlight the hostname when connected via SSH
if [[ -n "${SSH_TTY}" ]]; then
    host_color="%{$fg_bold[red]%}"
fi

# Git prompt function
git_prompt_info() {
    if command -v __git_ps1 >/dev/null 2>&1; then
        __git_ps1 " (%s)"
    elif git rev-parse --git-dir >/dev/null 2>&1; then
        local branch=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
        if [[ -n "$branch" ]]; then
            echo " ($branch)"
        fi
    fi
}

# Build the prompt
PROMPT='${user_color}%n${reset_color}@${host_color}%m${reset_color}:${dir_color}%~${reset_color}${git_color}$(git_prompt_info)${reset_color}$ '

# Right prompt with timestamp (optional)
# RPROMPT='%{$fg[grey]%}%D{%H:%M:%S}%{$reset_color%}'
[[ -d /bin ]] && export PATH=/bin:/Users/alyshialedlie/.gem/ruby/3.4.4/bin:/Users/alyshialedlie/.rubies/ruby-3.4.4/lib/ruby/gems/3.4.0/bin:/Users/alyshialedlie/.rubies/ruby-3.4.4/bin:/Users/alyshialedlie/.local/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/Users/alyshialedlie/.local/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/X11/bin:/opt/homebrew/bin:/Users/alyshialedlie/.local/bin
export PYENV_ROOT=/Users/alyshialedlie/.pyenv
export PYENV_ROOT=/Users/alyshialedlie/.pyenv
