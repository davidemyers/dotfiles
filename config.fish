# config.fish
#
# Install fish 4 on Ubuntu Server 24.04 LTS with:
# sudo add-apt-repository -y ppa:fish-shell/release-4 && sudo apt install -y --no-install-recommends fish
#
# As of Ubuntu Server 25.04 fish 4 is part of the standard repositories.
#

if status is-interactive

    # Modify the fish greeting.
    set -g fish_greeting fish, version $version

    # Need to set EDITOR in order to edit command lines using alt-e.
    set -gx EDITOR nano

    # Wait a bit longer to read "escape" as "alt".
    set -g fish_escape_delay_ms 500

    # Truncate fewer directory names in prompts.
    set -g fish_prompt_pwd_full_dirs 3 # default: 1

    # Tweak some colors in the default prompt.
    # #0088FF is a luminance-boosted version of Duke Royal Blue #00539B.
    # https://brand.duke.edu/colors https://htmlcolorcodes.com
    set -g fish_color_user 08F brgreen # default: brgreen
    set -g fish_color_host 08F brcyan # default: normal
    set -g fish_color_host_remote 08F brcyan # default: yellow
    # Can't abide the red comments in the default theme.
    set -g fish_color_comment brblack # default: red

    # Show more detail in the git prompt.
    set -g __fish_git_prompt_show_informative_status no
    set -g __fish_git_prompt_use_informative_chars yes
    set -q __fish_git_prompt_showcolorhints yes # Doesn't work?
    set -g __fish_git_prompt_showuntrackedfiles yes
    set -g __fish_git_prompt_showdirtystate yes

    # Define different functions based on the OS.
    switch (uname)

        case Linux
            # Functions specific to (Ubuntu) Linux.

            # Set a more modern default PATH.
            set -gx PATH /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /snap/bin

            # Prepend ~/bin to PATH if it exists.
            fish_add_path --path ~/bin

            # I prefer 24-hour time on a server.
            set -gx LC_TIME C.UTF-8

            # If NUT is installed set a variable to suppress SSL warnings from upsc.
            if command -q upsc
                set -gx NUT_QUIET_INIT_SSL TRUE
            end

            # If we're on a serial console we're probably using screen.
            if test $TERM = vt220
                set -gx TERM screen-256color
            end

            # This is needed for signing git commits.
            if test -f ~/.gnupg/pubring.gpg
                set -gx GPG_TTY (tty)
            end

            function df --description 'alias df df -Th -x squashfs -x tmpfs -x devtmpfs -x fuse.snapfuse -x efivarfs'
                command df -Th -x squashfs -x tmpfs -x devtmpfs -x fuse.snapfuse -x efivarfs $argv
            end

            function free --description 'alias free free -ht'
                command free -ht $argv
            end

            function last --description 'alias last last -a'
                command last -a $argv
            end

            function p1ng --wraps='ping -c1' --description 'alias p1ng ping -c1'
                ping -c1 $argv
            end

            # Work around color problems in btop.
            if command -q btop; and test "$TERM" = xterm-256color
                function btop --description 'alias btop btop -lc'
                    command btop -lc $argv
                end
            end

            if test -d ~/.dotfiles
                function dots --description 'Make sure .dotfiles are current'
                    pushd ~/.dotfiles
                    if test -f .gitignore
                        # This is the master copy, just print status.
                        git status
                    else
                        git pull
                        ./makesymlinks.sh
                    end
                    popd
                end
            end

            if command -q journalctl
                function logs --description 'Print filtered list of most recent system log entries'
                    SYSTEMD_COLORS=1 journalctl --boot --no-pager --system | \
                    grep -E -v  -e 'CRON' \
                                -e 'systemd.*Started' \
                                -e 'systemd.*Starting' \
                                -e 'systemd.*Finished' \
                                -e 'systemd.*Deactivated' \
                                -e 'systemd.*Consumed' \
                                -e 'INFO.*ubuntupro.timer' \
                                -e 'sanoid.*INFO' | \
                        tail -$LINES
                end
            end

            # Functions to simplify package management.
            if command -q apt
                function _do_apt_update --description 'Update the apt package list unless recently updated'
                    if not test -e /var/cache/apt/pkgcache.bin;
                        or test (math (date +%s) - (stat -c %Y /var/cache/apt/pkgcache.bin)) -gt 600
                        sudo apt update
                    end
                end

                function _check_for_reboot --description 'Print a notice if a reboot is pending'
                    if test -e /run/reboot-required
                        echo Reboot required
                    end
                end

                function update --description 'Update the apt package list'
                    _do_apt_update
                    apt list --upgradable
                    _check_for_reboot
                end

                function upgrade --description 'Upgrade packages'
                    _do_apt_update
                    sudo apt upgrade $argv
                    _check_for_reboot
                end

                function aptlog --description 'Tail the apt history log'
                    tail --lines=$LINES /var/log/apt/history.log
                end
            end

            if set -q TMUX
                function tssh --description 'Open new SSH connections in new tmux windows'
                    set -l destination
                    for destination in $argv
                        tmux new-window -n (string replace -r '(\w+@)?(\w+)(\.\w+)*' '$2' $destination) ssh $destination
                    end
                end
                function pis --description 'tssh into all of my Raspberry Pis at once'
                    tssh pi chronos cerberus stargate capsule walnut peanut
                end
            end

        case Darwin
            # Functions specific to macOS.

            # Set up environment variables for Homebrew.
            if test -x /opt/homebrew/bin/brew
                eval (/opt/homebrew/bin/brew shellenv fish)
            end

            function df --description 'alias df df -H'
                command df -H $argv
            end

            function kif --description 'alias kif mosh --family=inet kif.myersnet.net -- bin/start-tmux'
                mosh --family=inet kif.myersnet.net -- bin/start-tmux $argv
            end

    end

    # Functions not specific to the OS.

    function more --wraps=less --description 'alias more less'
        less $argv
    end

    function psg --description 'grep the output of ps'
        ps wwaux | grep --color=always $argv | grep -v grep
    end

    function myip --description 'Print public IP addresses'
        curl -4 icanhazip.com
        curl -6 icanhazip.com
    end

    if command -q speedtest
        function st --wraps=speedtest --description 'alias st speedtest'
            speedtest $argv
        end
    end

end
