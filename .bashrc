# Only run in interactive shells
# Prevents scp from failing
[[ $- != *i* ]] && return

# Bash options
HISTCONTROL=ignoredups  # Ignore duplicate entries
HISTSIZE=1000           # 1000 lines
shopt -s histappend     # Append to history file
shopt -s checkwinsize   # Tell Bash to check the window size after each command

# Aliases
alias ls='ls -hF --color=auto'
alias rsync='rsync -avhz'

# Coloured man pages
command -v most &>/dev/null && export PAGER=most

if uname -a | grep MINGW &>/dev/null; then
    # Allow Python to run in Git Bash
    alias python='winpty python'
    alias venv_activate='source .venv/Scripts/activate'
else
    alias venv_activate='source .venv/bin/activate'
fi

if command -v bc &>/dev/null; then
    alias bc='bc -l'
fi

if command -v xclip &>/dev/null; then
    alias xclip='xclip -selection clipboard'
fi

NVM_DIR=".nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"  # This loads nvm

    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# Start ssh-agent
if command -v "ssh-agent" &>/dev/null; then
    # Is ssh-agent running? Count ps aux lines that contain ssh-agent
    # (This code should work on both Windows and *nix)
    if [ `ps aux | grep ssh-agent | grep -v grep | wc -l` = "0" ]; then
        # ssh-agent is not running; run it
        ssh-agent &>.ssh_agent_info
    fi

    if [ "$SSH_AGENT_PID" == "" ] && [ -f .ssh_agent_info ]; then
        # Set $SSH_AGENT_PID and $SSH_AUTH_SOCK
        source .ssh_agent_info &>/dev/null
    fi
fi

# https://www.ditig.com/256-colors-cheat-sheet

_set_ps1() {
    if [[ "$TERM" =~ 256color ]]; then
        local c1='\[\033[38;5;044m\]' # DarkTurquoise
        local c2='\[\033[38;5;160m\]' # Red3
        local c3='\[\033[38;5;034m\]' # Green3
        local c4='\[\033[38;5;247m\]' # Grey62
    else
        local c1='\[\033[36m\]' # Cyan
        local c2='\[\033[31m\]' # Red
        local c3='\[\033[32m\]' # Green
        local c4='\[\033[37m\]' # Grey
    fi

    local c0='\[\033[0m\]' # Default colour

    export PS1="\
$c1\u@\h \
$c0\w \
$c1\$(_get_git_branch)\
$c4\$(_get_git_no_untracked)\
$c2\$(_get_git_untracked)\
$c4\$(_get_git_no_uncommitted)\
$c2\$(_get_git_uncommitted)\
$c4\$(_get_git_no_committed)\
$c3\$(_get_git_committed)\
$c0\\$ "
}

_get_git_branch() {
    # Print branch name, if any
    local branch=`git branch 2>/dev/null | grep '^*' | cut -d' ' -f2-`
    [[ -n "$branch" ]] && echo -n "$branch"
}

_get_git_no_untracked() {
    # Empty circle
    local character="\xE2\x97\x8B"

    # Ensure we are in a git repo
    if git b &>/dev/null; then
        # Print the character if there AREN'T any untracked files
        if ! git status 2>/dev/null | grep -q 'Untracked files' &>/dev/null; then
            # Space in front to separate it from the branch name
            echo -e " $character"
        fi
    fi
}

_get_git_untracked() {
    # Empty circle
    local character="\xE2\x97\x8B"

    # Print the character if there ARE untracked files
    if git status 2>/dev/null | grep -q 'Untracked files' &>/dev/null; then
        # Space in front to separate it from the branch name
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
    if git status 2>/dev/null | grep -q 'Changes not staged for commit' &>/dev/null; then
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
    if git status 2>/dev/null | grep -q 'Changes to be committed' &>/dev/null; then
        echo -e "$character"
    fi
}

_set_ps1

TMUX_SESSION_NAME=""

# Only launch tmux if it is found and a session name has been specified
if command -v tmux &>/dev/null && [[ -n "$TMUX_SESSION_NAME" ]]; then
    # Create tmux session if it doesn't exist
    if ! tmux has-session &>/dev/null; then
        tmux new-session -d -s "$TMUX_SESSION_NAME"
    fi

    # Attach only if not already attached
    if [[ -z "$TMUX" ]]; then
        # Switch to tmux - log out upon detaching from tmux
        exec tmux attach -t "$TMUX_SESSION_NAME"
    fi
fi
