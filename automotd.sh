#!/usr/bin/env bash

readonly __AUTOMOTD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__AUTOMOTD_DIR/_DEPENDENCY_CHECK.sh"

if ! ensure_commands_present --caller "automotd" fortune jq; then
    exit 123
fi

[ -f $HOME/motd.time ] || {
    printf "%s" "0" > $HOME/motd.time
}

motd_time=$(cat $HOME/motd.time)

# If the difference between current time and motd_time is greater than 1 day, then update motd_time
if [[ $(( $(date +%s) - motd_time )) -gt 86400 ]]; then
    motd_time=$(date +%s)
    printf "%s" "$motd_time" > $HOME/motd.time

    if [[ ! -f $HOME/motd.txt ]]; then
        cat <<EOF > $HOME/motd.txt
Your daily fortune:

$(fortune)
--------------------------------
Type motd shoo to remove the message of the day file.
EOF
    fi
fi