#!/bin/bash
#
# Personal Bash aliases and functions for Linux.
# More aliases are defined in the Ubuntu default .bashrc file.
# I use the default .profile, .bashrc, and .bash_logout files from /etc/skel.

alias ll='ls -alhF'
alias df='df -Thx squashfs'
alias free='free -h'
alias last='last -a'

# This is needed for signing git commits.
if [[ -f ~/.gnupg/pubring.gpg ]]; then
    GPG_TTY=$(tty); export GPG_TTY
fi

# Use the pager specified in /etc/alternatives, which is usually `less`.
[[ -x $(command -v pager) ]] && alias more=pager

# shellcheck disable=SC2009
psg() {
    ps wwaux | grep --color=always "$@" | grep -v grep
}

# shellcheck disable=SC2046
agent() {
    eval $(ssh-agent -s)
    ssh-add
}

# shellcheck disable=SC2164
if [[ -d ~/dotfiles ]]; then
    if [[ -f ~/dotfiles/.gitignore ]]; then
        dots() {
            (cd ~/dotfiles && git status)
        }
    else
        dots() {
            (cd ~/dotfiles && git pull && ./makesymlinks.sh)
        }
    fi
fi

if [[ -x $(command -v apt) ]]; then
    upgrade() {
        sudo apt update && sudo apt full-upgrade "$@"
        [[ -f /var/run/reboot-required ]] &&
            echo "$(tput smso)Reboot required$(tput rmso)"
    }
fi

if [[ -x $(command -v curl) ]]; then
    myip() {
        curl -4 icanhazip.com
        if [[ $(ip -6 route show default) ]]; then
            curl -6 icanhazip.com
        fi
    }
fi

if [[ ${TMUX} ]]; then
    tssh() {
        local host
        host=${1#*@}
        tmux new-window -n "${host%%.*}" ssh "$1"
    }
fi

# shellcheck disable=SC1091 disable=SC2034
if [[ -x $(command -v git) && -f /usr/lib/git-core/git-sh-prompt ]]; then
    . /usr/lib/git-core/git-sh-prompt
    GIT_PS1_SHOWCOLORHINTS=1
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    PROMPT_COMMAND='__git_ps1 "\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]" "\\\$ " "(%s)"'
fi
