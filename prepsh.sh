#!/usr/bin/env bash

readonly __PREPSH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__PREPSH_DIR/_DEPENDENCY_CHECK.sh"

prepsh() {
    local arg="$1"  
    [[ -z "$1" ]] && arg="main.sh"
    [[ "$arg" != *.sh ]] && arg="$arg.sh"
    [[ -f "$arg" ]] && {
        printf "Can't create %s, file already exists\n" "$arg"
        return 1
    }
    if ! ensure_commands_present --caller "prepsh" chmod; then
        return 123
    fi
    echo "#!/usr/bin/env bash" >"$arg"
    chmod +x "$arg"
    printf "Would you like to edit the file? (y/n): "
    read -n 1 -r ans
    if [[ $ans =~ ^[Yy]$ ]]; then
        local editor="${EDITOR:-nvim}"
        if ! ensure_commands_present --caller "prepsh edit" "$editor"; then
            return 123
        fi
        "$editor" "$arg"
        return 0
    fi
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    prepsh "$@"
    exit $?
fi