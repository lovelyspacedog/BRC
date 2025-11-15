#!/usr/bin/env bash
# Combined basic helper functions from basics.sh, basics-files.sh, and basics-system.sh

readonly __BASICS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__BASICS_DIR/_DEPENDENCY_CHECK.sh"

# Functions ----------------------------------------------------------------

# INDEX:
# - backup()
# - backup_all()
# - calc()
# - cdd()
# - cd()
# - cpuinfo()
# - cpx()
# - genpassword()
# - h()
# - mkcd()
# - n()
# - pwd()
# - silent()
# - swap()
# - update()
# - woof()
# - xx()
# - zd()

# Backup a single file to filename.bak.TIMESTAMP
backup() {
    if ! ensure_commands_present --caller "backup" cp date; then
        return 123
    fi

    [[ ! -f "$1" ]] && {
        echo "Error: '$1' does not exist"
        return 1
    }
    local timestamp
    timestamp=$(date +%Y%m%d%H%M%S)
    cp "$1" "$1.bak.$timestamp"
    echo "Backup created: $1.bak.$timestamp"
    return 0
}

# Backup every regular file in the current directory
backup_all() {
    local count=0
    for file in *; do
        if [[ -f "$file" ]]; then
            backup "$file"
        fi
    done
    return 0
}

# Arithmetic helper with decimal support
calc() {
    if ! ensure_commands_present --caller "calc" bc; then
        return 123
    fi

    [[ -z "$1" ]] && {
        echo "Usage: calc <expression>" >&2
        echo "Example: calc '2 + 3.5 * 4'" >&2
        return 1
    }

    local result
    if result=$(echo "scale=10; $1" | bc 2>/dev/null); then
        # Remove trailing zeros and decimal point if not needed
        echo "$result" | sed -e 's/\.0*$//' -e 's/\.$//'
        return 0
    else
        echo "Error: Invalid expression: $1" >&2
        return 1
    fi
}

# cd to a directory and list contents if it exists
cdd() {
    if ! ensure_commands_present --caller "cdd" ls; then
        return 123
    fi

    [[ -d "$1" ]] && {
        if ! builtin cd "$1"; then
            echo "Error: Failed to cd to '$1'" >&2
            return 1
        fi
        echo "📁 $(pwd)"
        if command -v eza >/dev/null 2>&1; then
            eza -lh --group-directories-first --icons=auto
        else
            ls -Al --color=auto
        fi
        return 0
    }
    echo "Error: Directory '$1' does not exist" >&2
    return 1
}

# cd to home directory if no arguments are provided (overridden by zoxide alias when enabled)
cd() {
    if [[ $# -eq 0 ]]; then
        builtin cd "$HOME"
    else
        builtin cd "$@"
    fi
}

# Show current CPU usage and top processes
cpuinfo() {
    if ! ensure_commands_present --caller "cpuinfo" top grep awk cut ps head; then
        return 123
    fi

    echo "CPU Usage:"
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
    echo -e "\nTop CPU Processes:"
    ps aux --sort=-%cpu | head -10
    return 0
}

# Compile and run a C++ file quickly
cpx() {
    if ! ensure_commands_present --caller "cpx" g++; then
        return 123
    fi

    local arg="$1"
    [[ -z "$1" ]] && arg="main.cpp"
    [[ -f "$arg" ]] || {
        printf "ERR: File %s does not exist.\n\n" "$arg"
        return 1
    }
    g++ "$arg"
    ./"a.out"
    printf "\nExit Code: %s\n" "$?"
    rm -f ./"a.out"
    return 0
}

# Generate a random password (default length 16)
genpassword() {
    if ! ensure_commands_present --caller "genpassword" tr head xargs; then
        return 123
    fi

    local length=16
    local special=false
    local charset="A-Za-z0-9_"

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --special|-s)
                special=true
                charset='A-Za-z0-9_!@#$%^&*()+=\-\[\]{}|;:,.<>?'
                ;;
            *)
                if [[ "$arg" =~ ^[0-9]+$ ]]; then
                    length="$arg"
                fi
                ;;
        esac
    done

    tr -dc "$charset" </dev/urandom | head -c ${length} | xargs
    return 0
}

# Quick history viewer (optionally filtered)
h() {
    if ! ensure_commands_present --caller "h" grep; then
        return 123
    fi

    [[ -z "$1" ]] && {
        history
        return 0
    }
    [[ "${1^^}" == "--EDIT" || "${1^^}" == "-E" ]] && {
        if ! ensure_commands_present --caller "h edit" nvim; then
            return 123
        fi
        nvim ~/.bash_history
        return 0
    }
    history | grep -i "$1"
    return 0
}

# Create a directory and enter it
mkcd() {
    if ! mkdir -p "$1"; then
        printf "ERR: Failed to create directory '%s'\n" "$1"
        return 1
    fi
    if ! builtin cd "$1"; then
        printf "ERR: Failed to cd to '%s'\n" "$1"
        return 2
    fi
    echo "📁 $(pwd)"
    if command -v eza >/dev/null 2>&1; then
        eza -lh --group-directories-first --icons=auto
    else
        ls -Al --color=auto
    fi
    return 0
}

# Open the current directory (or target) in nvim
n() {
    if ! ensure_commands_present --caller "n" nvim; then
        return 123
    fi

    if [[ "$#" -eq 0 ]]; then
        nvim .
    else
        nvim "$@"
    fi
}

# Copy the current directory to the clipboard if the first argument is "c" or "C"
pwd() {
    [[ -n "$1" && "${1:0:1}" =~ [Cc] ]] && {
        if ! ensure_commands_present --caller "pwd clipboard" wl-copy; then
            return 123
        fi
        wl-copy <<<"$(builtin pwd)"
        return 0
    }
    builtin pwd "$@"
    return 0
}

# Run a command silently (no output to stdout or stderr)
silent() { "$@" >/dev/null 2>&1; }

# Swap two filenames safely
swap() {
    if ! ensure_commands_present --caller "swap" mv; then
        return 123
    fi

    [[ ! -f "$1" ]] && {
        echo "Error: '$1' does not exist"
        return 1
    }
    [[ ! -f "$2" ]] && {
        echo "Error: '$2' does not exist"
        return 1
    }
    local TMPFILE=tmp.$$
    if mv "$1" "$TMPFILE" && mv "$2" "$1" && mv "$TMPFILE" "$2"; then
        echo "Successfully swapped '$1' and '$2'"
        return 0
    else
        echo "Error: Failed to swap '$1' and '$2'"
        return 1
    fi
}

# Run system updates via yay, flatpak, and topgrade with bitmask exit code
update() {
    if ! ensure_commands_present --caller "update" sudo; then
        return 123
    fi

    sudo true
    if ! sudo -n true 2>/dev/null; then
        echo "Error: Cannot run update without sudo privileges."
        return 2
    fi

    local yay_fail=0
    local flatpak_fail=0
    local topgrade_fail=0

    if command -v yay >/dev/null 2>&1; then
        yay -Syu --sudoloop --noconfirm || yay_fail=1
    else
        echo "Warning: yay not found; skipping AUR updates."
        yay_fail=1
    fi

    if command -v flatpak >/dev/null 2>&1; then
        flatpak update --assumeyes || flatpak_fail=1
    else
        echo "Warning: flatpak not found; skipping Flatpak updates."
        flatpak_fail=1
    fi

    if command -v topgrade >/dev/null 2>&1; then
        topgrade --yes --disable pacdef pacstall flatpak || topgrade_fail=1
    else
        echo "Warning: topgrade not found; skipping system-wide updates."
        topgrade_fail=1
    fi

    local result=$((yay_fail * 100 + flatpak_fail * 10 + topgrade_fail))
    return $result
}

# Send a desktop notification
woof() {
    if ! ensure_commands_present --caller "woof" notify-send; then
        return 123
    fi

    notify-send -i "/home/tony/.local/share/icons/datadog-white-48.png" "$@"
}

# Start a new kitty session in the background, thus reopening the terminal.
xx() {
    if ! ensure_commands_present --caller "xx" nohup kitty; then
        return 123
    fi

    nohup kitty >/dev/null 2>&1 &
    disown
    exit 0
}

# cd to a directory and list contents if it exists using zoxide
zd() {
    if ! ensure_commands_present --caller "zd" zoxide z; then
        cdd "$@"
        return $?
    fi

    if z "$@"; then
        echo "📁 $(pwd)"
        if command -v eza >/dev/null 2>&1; then
            eza -lh --group-directories-first --icons=auto
        else
            ls -Al --color=auto
        fi
        return 0
    else
        echo "Error: Failed to cd to '$@' using zoxide" >&2
        return 1
    fi
}

# Script entrypoint --------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -z "$1" ]]; then
        if ! ensure_commands_present --caller "new-basic-functions" awk; then
            exit 123
        fi

        echo "Available basic functions:"
        awk -F'(' '/^[[:space:]]*[[:alnum:]_-]+\(\)/ {
            name=$1
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
            print "  " name
        }' "${BASH_SOURCE[0]}"
        exit 0
    fi

    func="$1"
    shift
    if declare -F "$func" >/dev/null 2>&1; then
        "$func" "$@"
        exit $?
    else
        echo "Function '$func' not found."
        exit 1
    fi
fi
