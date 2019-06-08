#!/bin/bash
#
# Personal Bash aliases and functions for Ubuntu Linux.
# More aliases are defined in the Ubuntu default .bashrc file.
# I use the default .profile, .bashrc, and .bash_logout files from /etc/skel.
#

# Some handy aliases.
alias ll='ls -alhF'
alias df='df -Thx squashfs'
alias free='free -ht'
alias last='last -a'

# This is needed for signing git commits.
if [[ -f ~/.gnupg/pubring.gpg ]]; then
    GPG_TTY=$(tty); export GPG_TTY
fi

# Use the pager specified in /etc/alternatives, which is usually `less`.
[[ -x $(command -v pager) ]] && alias more=pager

# Function to grep the output of ps. In living color.
# shellcheck disable=SC2009
psg() {
    ps wwaux | grep --color=always "$@" | grep -v grep
}

# Function to make sure my dotfiles are current.
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

# Function to upgrade packages with a single command.
if [[ -x $(command -v apt) ]]; then
    upgrade() {
        sudo apt update && sudo apt full-upgrade "$@"
        [[ -f /var/run/reboot-required ]] &&
            echo "$(tput smso)Reboot required$(tput rmso)"
    }
fi

# Function to determine the public IP address(es) of the system.
if [[ -x $(command -v curl) ]]; then
    myip() {
        curl -4 icanhazip.com
        if [[ $(ip -6 route show default) ]]; then
            curl -6 icanhazip.com
        fi
    }
fi

# Function to open a new SSH session in a new tmux window.
# Usage: tssh me@example.com
if [[ ${TMUX} ]]; then
    tssh() {
        local host
        host=${1#*@}
        tmux new-window -n "${host%%.*}" ssh "$1"
    }
fi

# Customize the command prompt to show git status when in a git directory.
# Based on the default Ubuntu Linux color prompt.
# shellcheck disable=SC1091 disable=SC2034
if [[ -x $(command -v git) && -f /usr/lib/git-core/git-sh-prompt ]]; then
    . /usr/lib/git-core/git-sh-prompt
    GIT_PS1_SHOWCOLORHINTS=1
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    PROMPT_COMMAND='__git_ps1 "\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]" "\\\$ " "(%s)"'
fi
