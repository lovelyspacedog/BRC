#!/usr/bin/env bash

readonly __BASHRC_HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__BASHRC_HELPER_DIR/_DEPENDENCY_CHECK.sh"

# Open ~/.bashrc or list aliases
# Previously in basics-system.sh
bashrc() {
    [[ "${1^^}" == ALIAS ]] && {
        if ! ensure_commands_present --caller "bashrc alias" cat; then
            return 123
        fi
        if [[ -f "${BASH_SOURCE%/*}/_ALIASES.sh" ]]; then
            cat "${BASH_SOURCE%/*}/_ALIASES.sh"
        else
            echo "_ALIASES.sh not found."
        fi
        return 0
    }
    if ! ensure_commands_present --caller "bashrc edit" nvim; then
        return 123
    fi
    nvim ~/.bashrc
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    bashrc "$@"
    exit $?
fi