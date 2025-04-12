#!/usr/bin/env bash
#
# Create symbolic links from the home directory to the files in this directory.
#
# To set up a new system, run:
#
# git clone https://github.com/davidemyers/dotfiles.git .dotfiles
# ~/.dotfiles/makesymlinks.sh
#

# Determine whether this is Linux or macOS.
OS=$(uname)

# The directory containing the files below. Probably a git clone.
DOTFILES="${HOME}/.dotfiles"

# The list of files to create links to, without leading dots.
case $OS in
  Linux )
    FILES="bash_aliases bash_profile nanorc tmux.conf"
    ;;
  Darwin )
    FILES="nanorc tmux.conf"
    ;;
  *)
    printf "%s: Unknown OS: %s\n" "${0##*/}" "$OS"
    exit 1
    ;;
esac

for file in ${FILES}; do

    SOURCE="${DOTFILES}/${file}"
    TARGET="${HOME}/.${file}"

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

# Handle config.fish specially.
SOURCE="${DOTFILES}/config.fish"
TARGET="${HOME}/.config/fish/config.fish"

# Make sure the file exists in the source directory and there's not already
# a symbolic link in the home directory.
if [[ -f ${SOURCE} && ! -h ${TARGET} ]]; then

    # If there's a plain (non-link) file in the home directory back it up first.
    if [[ -f ${TARGET} ]]; then
        mv "${TARGET}" "${TARGET}.old"
    fi

    # Create the link.
    # shellcheck disable=SC2174
    mkdir -m 0700 -p "$(dirname "${TARGET}")"
    ln -s "${SOURCE}" "${TARGET}"

fi
