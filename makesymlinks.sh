#!/bin/bash
#
# Create symbolic links from the home directory to the files in this directory.
#

DOTFILES="${HOME}/dotfiles"
FILES="bash_aliases tmux.conf"

for FILE in ${FILES}
do

	SOURCE="${DOTFILES}/${FILE}"
	TARGET="${HOME}/.${FILE}"

	if [[ -f ${SOURCE} && ! -h ${TARGET} ]]
	then
	
		if [[ -f ${TARGET} ]]
		then
			mv "${TARGET}" "${TARGET}.old"
		fi

	ln -s "${SOURCE}" "${TARGET}"
	
	fi
	
done
