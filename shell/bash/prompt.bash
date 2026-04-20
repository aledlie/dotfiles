# Bash prompt configuration

# Colors — cache `tput` output per-TERM to avoid 12 forks at every shell start.
_tput_cache_dir="${DOTFILES_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles}"
[[ -d "$_tput_cache_dir" ]] || mkdir -p "$_tput_cache_dir"
_tput_cache="$_tput_cache_dir/tput-colors.${TERM:-unknown}.sh"

if [[ -s "$_tput_cache" ]]; then
    source "$_tput_cache"
elif tput setaf 1 &> /dev/null; then
    tput sgr0
    {
        printf 'bold=%q\n'   "$(tput bold)"
        printf 'reset=%q\n'  "$(tput sgr0)"
        # Solarized colors, taken from http://git.io/solarized-colors.
        printf 'black=%q\n'  "$(tput setaf 0)"
        printf 'blue=%q\n'   "$(tput setaf 33)"
        printf 'cyan=%q\n'   "$(tput setaf 37)"
        printf 'green=%q\n'  "$(tput setaf 64)"
        printf 'orange=%q\n' "$(tput setaf 166)"
        printf 'purple=%q\n' "$(tput setaf 125)"
        printf 'red=%q\n'    "$(tput setaf 124)"
        printf 'violet=%q\n' "$(tput setaf 61)"
        printf 'white=%q\n'  "$(tput setaf 15)"
        printf 'yellow=%q\n' "$(tput setaf 136)"
    } > "$_tput_cache"
    source "$_tput_cache"
else
    bold=''
    reset="\e[0m"
    black="\e[1;30m"
    blue="\e[1;34m"
    cyan="\e[1;36m"
    green="\e[1;32m"
    orange="\e[1;33m"
    purple="\e[1;35m"
    red="\e[1;31m"
    violet="\e[1;35m"
    white="\e[1;37m"
    yellow="\e[1;33m"
fi
unset _tput_cache_dir _tput_cache

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
    userStyle="${red}";
else
    userStyle="${yellow}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
    hostStyle="${bold}${red}";
else
    hostStyle="${green}";
fi;

# Set the terminal title and prompt.
PS1="\[\033]0;\W\007\]"; # working directory base name
PS1+="\[${bold}\]\n"; # newline
PS1+="\[${userStyle}\]\u"; # username
PS1+="\[${white}\]@";
PS1+="\[${hostStyle}\]\h"; # host
PS1+="\[${white}\]: ";
PS1+="\[${blue}\]\w"; # working directory full path
if command -v __git_ps1 >/dev/null 2>&1; then
    PS1+="\[${red}\]\$(__git_ps1 ' (%s)')"; # Git repository details
fi
PS1+="\n";
PS1+="\[${white}\]\$ \[${reset}\]"; # `$` (and reset color)
export PS1;

PS2="\[${yellow}\]→ \[${reset}\]";
export PS2;
