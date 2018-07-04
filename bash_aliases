# Personal Bash aliases and functions for Linux.
# More aliases are defined in the Ubuntu default .bashrc file.

alias ll='ls -alhF'
alias df='df -Th'
alias free='free -h'
alias last='last -a'

# Use the pager specified in /etc/alternatives
if [ -x /usr/bin/pager ]
then
	alias more=pager
fi

psg() {
	ps wwaux | grep --color=always ${1} | grep -v grep
}

if [ -x /usr/bin/apt ]
then
	upgrade() {
		sudo apt update && sudo apt full-upgrade $*
		if [ -f /var/run/reboot-required ]
		then
			echo "$(tput smso)Reboot required$(tput rmso)"
		fi
	}
fi
