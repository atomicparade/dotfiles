# Bash options
HISTCONTROL=ignoredups  # Ignore duplicate entries
HISTSIZE=1000           # 1000 lines
shopt -s histappend     # Append to history file
shopt -s checkwinsize   # Tell Bash to check the window size after each command

# Aliases
alias ls='ls -hF --color=auto'

if uname -a | grep MINGW >/dev/null 2>&1; then
    # Allow Python to run in Git Bash
    alias python='winpty python'
fi

if command -v bc &>/dev/null; then
    alias bc='bc -l'
fi

if command -v xclip &>/dev/null; then
    alias xclip='xclip -selection clipboard'
fi

# Start ssh-agent
if command -v "ssh-agent" &>/dev/null; then
    # Is ssh-agent running? Count ps aux lines that contain ssh-agent
    # (This code should work on both Windows and *nix)
    if [ `ps aux | grep ssh-agent | grep -v grep | wc -l` = "0" ]; then
        echo "running ssh-agent"
        # ssh-agent is not running; run it
        if ssh-agent >"$HOME/.ssh_agent_info" 2>/dev/null; then
            # Set $SSH_AGENT_PID and $SSH_AUTH_SOCK
            source "$HOME/.ssh_agent_info" >/dev/null 2>&1
        fi
    else
        # ssh-agent is already running...
        if [ "$SSH_AGENT_PID" == "" ] && [ -f .ssh_agent_info ]; then
            # ...and there is a file that contains the process information...
            # ...and $SSH_AGENT_PID is not set

            # Set $SSH_AGENT_PID and $SSH_AUTH_SOCK
            source .ssh_agent_info >/dev/null 2>&1
        fi
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
