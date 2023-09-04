#!/bin/bash
#
# ~/.bash_profile
#
# Set the base PATH to something more modern than the default from /etc/environment.
# Additional shell customization is done in .bash_aliases.
#
# When this file is present .profile is ignored, so source it.
#

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/snap/bin"

# shellcheck disable=SC1091
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi
