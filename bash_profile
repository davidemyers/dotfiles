#!/bin/bash
#
# ~/.bash_profile
#
# Additional shell customization is done in .bash_aliases, which is called
# from .bashrc, which is called from .profile, which is called below.
#

# Switch to the Fish shell if present and desired.
if [[ -f ~/.go_fish && -x /usr/bin/fish ]]; then
    exec -a fish -l /usr/bin/fish
fi

# Set the base PATH to something more modern than the default from /etc/environment.
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/snap/bin"

# When .bash_profile is present .profile is ignored, so source it.
# shellcheck disable=SC1091
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
