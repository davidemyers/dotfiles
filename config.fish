# config.fish
#
# Install fish 4.x on Ubuntu Server 24.04 LTS with:
# sudo add-apt-repository ppa:fish-shell/release-4 && sudo apt install -y fish
#
# Most environment variables are set by my login shell before fish starts.
#
if status is-interactive

    # Don't display the fish greeting.
    set -g fish_greeting

    # Need to set EDITOR in order to edit command lines using alt-e.
    set -g EDITOR nano

    # Wait a bit longer to read "escape" as "alt".
    set -g fish_escape_delay_ms 500

    # Truncate fewer directory names in prompts.
    set -g fish_prompt_pwd_full_dirs 3   # default: 1
    # Tweak some colors in the default prompt.
    set -g fish_color_host brcyan        # default: normal
    set -g fish_color_host_remote brcyan # default: yellow
    # Can't abide the red comments in the default theme.
    set -g fish_color_comment brblack    # default: red
    # Show more detail in the git prompt.
    set -g __fish_git_prompt_show_informative_status no
    set -g __fish_git_prompt_use_informative_chars yes
    set -q __fish_git_prompt_showcolorhints yes # Doesn't work?
    set -g __fish_git_prompt_showuntrackedfiles yes
    set -g __fish_git_prompt_showdirtystate yes

    switch (uname)

        # Functions specific to Linux.
        case Linux
            # Need to prepend ~/bin to PATH since we start fish before this
            # gets added in ~/.profile for bash.
            fish_add_path ~/bin

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
                if test -f ~/.dotfiles/.gitignore
                    function dots --description 'Make sure .dotfiles are current'
                        pushd ~/.dotfiles
                        git status
                        popd
                    end
                else
                    function dots  --description 'Make sure .dotfiles are current'
                        pushd ~/.dotfiles
                        git pull
                        ./makesymlinks.sh
                        popd
                    end
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
                function _do_apt_update --description 'Update apt package list unless recently updated'
                    if not test -e /var/cache/apt/pkgcache.bin;
                    or test (math (date +%s) - (stat -c %Y /var/cache/apt/pkgcache.bin)) -gt 600
                        sudo apt update
                    end
                end

                function _check_for_reboot --description 'Print a notice if a reboot is pending'
                    if test -e /run/reboot-required
                        echo "Reboot required"
                    end
                end

                function update --description 'Update the apt package list'
                    _do_apt_update
                    apt list --upgradable
                    _check_for_reboot
                end

                function upgrade --description 'Upgrade packages'
                    _do_apt_update
                    sudo apt upgrade
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
                function pis --description 'Log into all of my Raspberry Pis at once'
                    tssh pi chronos cerberus stargate capsule walnut peanut
                end
            end

        # Functions specific to macOS.
        case Darwin
            # This is handled by the default ls function.
            # set -g CLICOLOR TRUE

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
