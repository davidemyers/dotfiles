#!/bin/bash
#
# ~/.bash_aliases
#
# Personal Bash aliases and functions for Ubuntu Linux.
# More aliases are defined in the Ubuntu default .bashrc file.
# I use the default .profile, .bashrc, and .bash_logout files from /etc/skel.
#

# I prefer 24-hour time on a server.
export LC_TIME="C.UTF-8"

# Some handy aliases.
alias ll='ls -alhF'
alias df='df -Th -x squashfs -x tmpfs -x devtmpfs -x fuse.snapfuse -x efivarfs'
alias free='free -ht'
alias last='last -a'
alias more='less'
alias p1ng='ping -c1'

# This is needed for signing git commits.
if [[ -f ~/.gnupg/pubring.gpg ]]; then
    GPG_TTY=$(tty); export GPG_TTY
fi

# Function to grep the output of ps. In living color.
# shellcheck disable=SC2009
psg() {
    ps wwaux | grep --color=always "$@" | grep -v grep
}

# Function to make sure my dotfiles are current.
# shellcheck disable=SC2164
if [[ -d ~/.dotfiles ]]; then
    if [[ -f ~/.dotfiles/.gitignore ]]; then
        dots() {
            (cd ~/.dotfiles && git status)
        }
    else
        dots() {
            (cd ~/.dotfiles && git pull && ./makesymlinks.sh)
        }
    fi
fi

# Functions to simplify package management.
if command -v apt > /dev/null; then
    # Update the package cache if it's over 10 minutes old.
    _do_apt_update() {
        if [[ ! -e /var/cache/apt/pkgcache.bin ||
            $(( $(date +%s) - $(stat -c %Y /var/cache/apt/pkgcache.bin) )) -gt 600 ]]; then
            sudo apt update
        fi
    }
    # Print a notice if a reboot is pending.
    _check_for_reboot() {
        if [[ -f /var/run/reboot-required ]]; then
            echo "$(tput smso)Reboot required$(tput rmso)"
        fi
    }
    # List upgradable packages.
    update() {
        _do_apt_update
        apt list --upgradable
        _check_for_reboot
    }
    # Upgrade packages.
    upgrade() {
        _do_apt_update
        sudo NEEDRESTART_MODE=l apt upgrade "$@"
        _check_for_reboot
    }
    # View the most recent package activities.
    aptlog() {
        tail --lines=${LINES} /var/log/apt/history.log
    }
fi

# Function to determine the public IP address(es) of the system.
if command -v curl > /dev/null; then
    myip() {
        curl -4 icanhazip.com
        if [[ $(ip -6 route show default) ]]; then
            curl -6 icanhazip.com
        fi
    }
fi

# Function to print the most recent system log entries.
if command -v journalctl > /dev/null; then
    logs() {
        SYSTEMD_COLORS=1 journalctl --boot --no-pager --system | \
        grep -E -v  -e 'CRON' \
                    -e 'systemd.*Started' \
                    -e 'systemd.*Starting' \
                    -e 'systemd.*Finished' \
                    -e 'systemd.*Deactivated' \
                    -e 'systemd.*Consumed' \
                    -e 'INFO.*ubuntupro.timer' \
                    -e 'sanoid.*INFO' | \
            tail -${LINES}
    }
fi

# Function to open a new SSH session in a new tmux window.
# Usage: tssh me@example.com
if [[ ${TMUX} ]]; then
    tssh() {
        local hostname destination
        for destination in "$@"; do
            hostname=${destination#*@}
            tmux new-window -n "${hostname%%.*}" ssh "${destination}"
        done
    }
fi

# Customize the command prompt to show git status when in a git directory.
# Based on the default Ubuntu Linux color prompt.
# shellcheck disable=SC1091 disable=SC2034
if command -v git > /dev/null && [[ -f /usr/lib/git-core/git-sh-prompt ]]; then
    . /usr/lib/git-core/git-sh-prompt
    GIT_PS1_SHOWCOLORHINTS=1
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    PROMPT_COMMAND='__git_ps1 "\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]" "\\\$ " "(%s)"'
fi

# Show a summary of system health.
# This will typically be overridden with a system-specific version in ~/.bash_aliases.local.
sup() {
    uptime
    echo
    landscape-sysinfo --sysinfo-plugins=Disk,Memory
    echo
    if [[ $(systemd --version | awk '/^systemd/ { print $2 }') -ge 255 ]]; then
        systemctl status --failed
    fi
}

# Load any aliases and functions specific to this system.
# shellcheck disable=SC1090
if [[ -f ~/.bash_aliases.local ]]; then
    . ~/.bash_aliases.local
fi
