#!/bin/bash
#
# Personal Bash aliases and functions for Linux.
# More aliases are defined in the Ubuntu default .bashrc file.
# I use the default .profile, .bashrc, and .bash_logout files from /etc/skel.

alias ll='ls -alhF'
alias df='df -Th'
alias free='free -h'
alias last='last -a'

# This is needed for signing git commits.
if [[ -f ~/.gnupg/pubring.gpg ]]; then
    GPG_TTY=$(tty); export GPG_TTY
fi

# Use the pager specified in /etc/alternatives, which is usually `less`.
[[ -x /usr/bin/pager ]] && alias more=pager

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

if [[ -x /usr/bin/apt ]]; then
    upgrade() {
        sudo apt update && sudo apt full-upgrade "$@"
        [[ -f /var/run/reboot-required ]] &&
            echo "$(tput smso)Reboot required$(tput rmso)"
    }
fi

if [[ ${TMUX} ]]; then
    tssh() {
        local host
        host=${1#*@}
        tmux new-window -n "${host%%.*}" ssh "$1"
    }
fi
