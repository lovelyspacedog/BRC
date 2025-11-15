#!/usr/bin/env bash

readonly __POKEFETCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__POKEFETCH_DIR/_DEPENDENCY_CHECK.sh"

pokefetch() {
    if ! ensure_commands_present --caller "pokefetch" pokemon-colorscripts fastfetch head sed mv; then
        return 123
    fi

    pokemon-colorscripts -r 1-4 >/tmp/pokefetch.txt
    local pokemon_name
    pokemon_name="$(head -n 1 /tmp/pokefetch.txt)"
    sed '1d' /tmp/pokefetch.txt >/tmp/pokefetch.txt2
    mv /tmp/pokefetch.txt2 /tmp/pokefetch.txt
    fastfetch --logo-height 5 --logo /tmp/pokefetch.txt
    echo "[ ${pokemon_name^} ] Joins The Battle!"
    echo
    return
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pokefetch "$@"
    exit $?
fi