# Zsh prompt configuration

# Enable parameter expansion, command substitution and arithmetic expansion in prompts
setopt PROMPT_SUBST

# Colors
autoload -U colors && colors

# Define color variables for easier use.
# typeset -g (not local): this file is sourced at top level, and PROMPT_SUBST
# re-expands these at each prompt — they must outlive the sourcing scope.
typeset -g user_color="%{$fg[yellow]%}"
typeset -g host_color="%{$fg[green]%}"
typeset -g dir_color="%{$fg[blue]%}"
typeset -g git_color="%{$fg[red]%}"
typeset -g reset_color="%{$reset_color%}"

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
        local branch=$(git branch --show-current 2>/dev/null)
        if [[ -n "$branch" ]]; then
            echo " ($branch)"
        fi
    fi
}

# Build the prompt
PROMPT='${user_color}%n${reset_color}@${host_color}%m${reset_color}:${dir_color}%~${reset_color}${git_color}$(git_prompt_info)${reset_color}$ '
