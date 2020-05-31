#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Bash options
HISTCONTROL=ignoredups  # Ignore duplicate entries
HISTSIZE=1000           # 1000 lines
shopt -s histappend     # Append to history file
shopt -s checkwinsize   # Tell Bash to check the window size after each command

# Aliases
alias ls='ls -hF --color=auto'
alias psg='ps o user,pid,cmd | head -1; ps xo user,pid,cmd | grep -v grep | grep'
alias xclip='xclip -selection clipboard'

if [ -d "$HOME/bin" ]; then
    PATH="$PATH:$HOME/bin"
fi

# Start ssh-agent
if type "ssh-agent" &>/dev/null; then # Ensure ssh-agent exists
    if ! pgrep -u "$USER" ssh-agent >/dev/null 2>/dev/null; then
        ssh-agent >"$HOME/.start-ssh-agent"
    fi
    if [[ "$SSH_AGENT_PID" == "" ]]; then
        eval "$(<$HOME/.start-ssh-agent)"
    fi
fi

# PS1=
# username@host cwd (with abbreviated $HOME)
#     git: branch name in blue
#     git: unfilled red circle, if there are untracked files
#     git: red circle, if there are uncommited changes
#     git: green circle, if there are committed changes
# dollar sign

# Colours: https://unix.stackexchange.com/a/124409

_set_ps1() {
    if [[ "$TERM" =~ 256color ]]; then
        local c1='\[\033[38;5;039m\]' # blue
        local c2='\[\033[38;5;160m\]' # red
        local c3='\[\033[38;5;034m\]' # green
        local c4='\[\033[38;5;247m\]' # grey
    else
        local c1='\[\033[33m\]' # yellow/brown
        local c2='\[\033[31m\]' # red
        local c3='\[\033[32m\]' # green
        local c4='\[\033[37m\]' # grey
    fi

    local c0='\[\033[0m\]'

    export PS1="\
\\u@\\h \\w\
$c1\$(_get_git_branch)\
$c4\$(_get_git_no_untracked)\
$c2\$(_get_git_untracked)\
$c4\$(_get_git_no_uncommitted)\
$c2\$(_get_git_uncommitted)\
$c4\$(_get_git_no_committed)\
$c3\$(_get_git_committed)$c0\
\\$ "
}

_get_git_branch() {
    # Print branch name, if any
    local branch=`git branch 2>/dev/null | grep '^*' | cut -d' ' -f2-`
    [[ -n "$branch" ]] && echo -n " $branch"
}

_get_git_no_untracked() {
    # Empty circle
    local character="\xE2\x97\x8B"

    # Ensure we are in a git repo
    if git b &>/dev/null; then
        # Print the character if there AREN'T any untracked files
        if ! git status 2>/dev/null | grep -q 'Untracked files' 2>/dev/null; then
            echo -e " $character"
        fi
    fi
}

_get_git_untracked() {
    # Empty circle
    local character="\xE2\x97\x8B"

    # Print the character if there ARE untracked files
    if git status 2>/dev/null | grep -q 'Untracked files' 2>/dev/null; then
        echo -e " $character"
    fi
}

_get_git_no_uncommitted() {
    # Filled circle
    local character="\xE2\x97\x8F"

    # Ensure we are in a git repo
    if git b &>/dev/null; then
        # Print the character if there AREN'T any unstaged changes
        if ! git status 2>/dev/null | grep -q 'Changes not staged for commit' &>/dev/null; then
            echo -e "$character"
        fi
    fi
}

_get_git_uncommitted() {
    # Filled circle
    local character="\xE2\x97\x8F"

    # Print the character if there ARE unstaged changes
    if git status 2>/dev/null | grep -q 'Changes not staged for commit' 2>/dev/null; then
        echo -e "$character"
    fi
}

_get_git_no_committed(){
    # Filled circle
    local character="\xE2\x97\x8F"

    # Ensure we are in a git repo
    if git b &>/dev/null; then
        # Print the character if there AREN'T any changes that have been added for commit
        if ! git status 2>/dev/null | grep -q 'Changes to be committed' &>/dev/null; then
            echo -e "$character"
        fi
    fi
}

_get_git_committed() {
    # Filled circle
    local character="\xE2\x97\x8F"

    # Print the character if there ARE changes that have been added for commit
    if git status 2>/dev/null | grep -q 'Changes to be committed' 2>/dev/null; then
        echo -e "$character"
    fi
}

_set_ps1
