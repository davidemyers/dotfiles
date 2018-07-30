# Personal Bash aliases and functions for Linux.
# More aliases are defined in the Ubuntu default .bashrc file.
# I use the default .profile, .bashrc, and .bash_logout files from /etc/skel.

alias ll='ls -alhF'
alias df='df -Th'
alias free='free -h'
alias last='last -a'

# Use the pager specified in /etc/alternatives, which is usually `less`.
[[ -x /usr/bin/pager ]] && alias more=pager

psg() {
	ps wwaux | grep --color=always "${*}" | grep -v grep
}

agent() {
	eval $(ssh-agent -s)
	ssh-add
}

if [[ -d ~/dotfiles ]]
then
	if [[ -f ~/dotfiles/.git/packed-refs ]]
	then
		dots() {(cd ~/dotfiles; git pull)}
	else
		dots() {(cd ~/dotfiles; git status)}
	fi
fi

if [[ -x /usr/bin/apt ]]
then
	upgrade() {
		sudo apt update && sudo apt full-upgrade "${*}"
		if [[ -f /var/run/reboot-required ]]
		then
			echo "$(tput smso)Reboot required$(tput rmso)"
		fi
	}
fi
