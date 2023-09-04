#!/bin/bash
#
# Create symbolic links from the home directory to the files in this directory.
#
# To set up a new system, run:
#
# git clone https://github.com/davidemyers/dotfiles.git .dotfiles
# ~/.dotfiles/makesymlinks.sh
#

# The list of files to create links to.
FILES="bash_aliases bash_profile tmux.conf"

# The directory containing the files above. Probably a git clone.
DOTFILES="${HOME}/.dotfiles"

for FILE in ${FILES}; do

    SOURCE="${DOTFILES}/${FILE}"
    TARGET="${HOME}/.${FILE}"

    # Make sure the file exists in the source directory and there's not already
    # a symbolic link in the home directory.
    if [[ -f ${SOURCE} && ! -h ${TARGET} ]]; then

        # If there's a plain (non-link) file in the home directory back it up first.
        if [[ -f ${TARGET} ]]; then
            mv "${TARGET}" "${TARGET}.old"
        fi

        # Create the link.
        ln -s "${SOURCE}" "${TARGET}"

    fi

done
