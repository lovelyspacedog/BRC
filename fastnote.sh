#!/usr/bin/env bash

readonly __FASTNOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__FASTNOTE_DIR/_DEPENDENCY_CHECK.sh"

# Confirm if the argument is a positive number or zero.
is_pos_num() {
    [[ "$1" =~ ^[0-9]+$ ]] && [[ "$1" -ge 0 ]]
    return $?
}

fastnote() {
    [[ ! -d "$HOME/.fastnotes" ]] && {
        if ! ensure_commands_present --caller "fastnote (init)" mkdir; then
            return 123
        fi
        if ! mkdir -p "$HOME/.fastnotes"; then
            echo "Error: Failed to create fastnotes directory."
            return 1
        fi
    }
    local arg="${1:-0}"
    if [[ "${arg,,}" == "list" ]]; then
        if ! ensure_commands_present --caller "fastnote list" basename sed; then
            return 123
        fi
        shopt -s nullglob
        local files=("$HOME"/.fastnotes/notes_*.txt)
        shopt -u nullglob
        if (( ${#files[@]} == 0 )); then
            echo "No notes found."
            return 0
        fi
        echo "Available notes:"
        for file in "${files[@]}"; do
            basename "${file%.txt}" | sed 's/^notes_/  note /'
        done
        return 0
    fi
    if [[ "${arg,,}" == "clear" ]]; then
        if ! ensure_commands_present --caller "fastnote clear" rm; then
            return 123
        fi
        shopt -s nullglob
        local files=("$HOME"/.fastnotes/notes_*.txt)
        shopt -u nullglob
        if (( ${#files[@]} == 0 )); then
            echo "No notes found."
            return 0
        fi
        echo "This will delete all ${#files[@]} note(s)."
        echo -n "Are you sure? [y/N]: "
        read -r response
        if [[ ! "${response,,}" =~ ^y(es)?$ ]]; then
            echo "Cancelled."
            return 0
        fi
        local deleted=0
        for file in "${files[@]}"; do
            if rm -f "$file"; then
                ((deleted++))
            fi
        done
        if (( deleted == ${#files[@]} )); then
            echo "Deleted all ${deleted} note(s)."
            return 0
        else
            echo "Error: Failed to delete some notes. Deleted ${deleted} of ${#files[@]}."
            return 1
        fi
    fi
    local digit action
    if ! is_pos_num "$arg"; then
        echo "Invalid argument."
        echo "Note number must be a positive number or zero."
        return 1
    fi
    digit="$arg"
    action="${2:-open}"

    local notes_file="$HOME/.fastnotes/notes_$digit.txt"

    if [[ "${action,,}" == d* ]]; then
        if ! ensure_commands_present --caller "fastnote delete" rm; then
            return 123
        fi
        if [[ -f "$notes_file" ]]; then
            rm -f "$notes_file" && {
                echo "Deleted note $digit."
                return 0
            }
            echo "Error: Failed to delete note $digit."
            return 1
        else
            echo "Note $digit does not exist."
            return 1
        fi
    fi

    [[ ! -f "$notes_file" ]] && {
        echo "Note file does not exist."
        echo "Creating note file..."
        if ! ensure_commands_present --caller "fastnote create" touch; then
            return 123
        fi
        if ! touch "$notes_file"; then
            echo "Error: Failed to create note file."
            return 1
        fi
    }
    local editor="${EDITOR:-nvim}"
    if ! ensure_commands_present --caller "fastnote open" "$editor"; then
        return 123
    fi
    if ! "$editor" "$notes_file"; then
        echo "Error: Failed to open note file."
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    fastnote "$@"
fi