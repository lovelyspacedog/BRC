#!/usr/bin/env bash
# Combined basic helper functions from basics.sh, basics-files.sh, and basics-system.sh

readonly __BASICS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__BASICS_DIR/_DEPENDENCY_CHECK.sh"

# Functions ----------------------------------------------------------------

# INDEX:
# - backdoc()
# - backup()
# - backup_all()
# - brcversion()
# - brcupdate()
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

# Run backup on file, then move the backup to ~/Documents/Backups/
# Can also be used as backup function with --store or -s flag
backdoc() {
    if ! ensure_commands_present --caller "backdoc" cp date mkdir basename; then
        return 123
    fi

    local file="$1"
    [[ ! -f "$file" ]] && {
        echo "Error: '$file' does not exist"
        return 1
    }

    [[ ! -d "$HOME/Documents/Backups" ]] && {
        mkdir -p "$HOME/Documents/Backups" || {
            echo "Error: Failed to create '$HOME/Documents/Backups'"
            echo "Backup not performed."
            return 1
        }
    }

    local timestamp
    local filename
    timestamp=$(date +%Y%m%d%H%M%S)
    filename=$(basename "$file")
    cp "$file" "$HOME/Documents/Backups/$filename.bak.$timestamp" || {
        echo "Error: Failed to create backup of '$file'"
        echo "Backup not performed."
        return 2
    }
    
    printf "Backup created at: %s\n" "$HOME/Documents/Backups/$filename.bak.$timestamp"
    return 0
}

# Backup a single file to filename.bak.TIMESTAMP
# Use --store or -s flag to backup to ~/Documents/Backups/ via backdoc()
backup() {
    # Check for --store or -s flag
    if [[ "${1:-}" == "--store" || "${1:-}" == "-s" ]]; then
        shift
        if [[ -z "${1:-}" ]]; then
            echo "Error: No file specified for backup --store"
            return 1
        fi
        backdoc "$@"
        return $?
    fi

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

# Show the version of BRC
brcversion() {
    if ! ensure_commands_present --caller "brcversion" jq; then
        return 123
    fi

    local version
    version=$(jq -r '.VERSION' "$HOME/BASHRC/settings.json")
    echo "BRC version: $version"
    return 0

}

# Check if a BRC update is available
brcupdate() {
    if ! ensure_commands_present --caller "brcupdate" curl jq; then
        return 123
    fi

    # Parse arguments for silent flag
    local silent=false
    local ignore_this_version=false
    for arg in "$@"; do
        case "$arg" in
            --silent|-s)
                silent=true
                ;;
            --ignore-this-version|--ignore)
                ignore_this_version=true
                ;;
            *)
                # Ignore unknown arguments
                ;;
        esac
    done

    local installed_settings="$HOME/BASHRC/settings.json"
    local version_mask_file="$HOME/BASHRC/version.mask"
    local git_raw_base="https://raw.githubusercontent.com/lovelyspacedog/BRC"
    local branch="main"
    
    # Check if installed
    if [[ ! -f "$installed_settings" ]]; then
        echo "Error: BRC is not installed (settings.json not found)" >&2
        return 1
    fi
    
    # Get installed version
    local installed_version
    installed_version=$(jq -r '.VERSION // empty' "$installed_settings" 2>/dev/null || echo "")
    # If a version mask exists, use it instead of the installed VERSION
    if [[ -f "$version_mask_file" ]]; then
        local masked_version
        masked_version="$(sed -n '1p' "$version_mask_file" 2>/dev/null | tr -d '\r' | xargs)"
        if [[ -n "$masked_version" ]]; then
            installed_version="$masked_version"
            [[ "$silent" != "true" ]] && echo "Using masked version from $version_mask_file: $installed_version"
        fi
    fi
    if [[ -z "$installed_version" ]]; then
        echo "Error: Could not read VERSION from $installed_settings" >&2
        return 1
    fi
    
    # Get remote version
    local remote_settings_url="$git_raw_base/$branch/settings.json"
    local temp_settings
    temp_settings=$(mktemp)
    
    if ! curl -sfL "$remote_settings_url" -o "$temp_settings" 2>/dev/null; then
        echo "Error: Could not fetch remote version from repository" >&2
        rm -f "$temp_settings"
        return 1
    fi
    
    local remote_version
    remote_version=$(jq -r '.VERSION // empty' "$temp_settings" 2>/dev/null || echo "")
    rm -f "$temp_settings"
    
    if [[ -z "$remote_version" ]]; then
        echo "Error: Could not read VERSION from repository" >&2
        return 1
    fi

    # If the user passed --ignore-this-version, offer to store the current remote version in a mask file
    if [[ "$ignore_this_version" == "true" ]]; then
        if [[ "$silent" == "true" ]]; then
            echo "Error: --ignore-this-version cannot be used with --silent" >&2
            return 1
        fi
        # If a mask already exists, fail and offer to delete it
        if [[ -f "$version_mask_file" ]]; then
            current_mask="$(sed -n '1p' "$version_mask_file" 2>/dev/null | tr -d '\r' | xargs)"
            echo ""
            echo "A version mask already exists at: $version_mask_file"
            echo "Current ignored version: ${current_mask:-<empty>}"
            echo ""
            read -r -p "Delete existing mask? [y/N]: " __rmask
            case "${__rmask:-N}" in
                [Yy]* )
                    if rm -f "$version_mask_file"; then
                        echo "Removed existing version mask. Re-run with --ignore-this-version to set a new one."
                        return 0
                    else
                        echo "Error: failed to remove $version_mask_file" >&2
                        return 1
                    fi
                    ;;
                * )
                    echo "Keeping existing mask. Cancelled."
                    return 1
                    ;;
            esac
        fi
        echo ""
        echo "Repository version available: $remote_version"
        echo
        read -r -p "Ignore this version for future update checks? [y/N]: " __ans
        case "${__ans:-N}" in
            [Yy]* )
                if printf "%s\n" "$remote_version" > "$version_mask_file"; then
                    echo "Saved ignored version to $version_mask_file"
                    echo "To restore normal checks, delete this file: rm -f \"$version_mask_file\""
                    return 0
                else
                    echo "Error: failed to write $version_mask_file" >&2
                    return 1
                fi
                ;;
            * )
                echo "Cancelled."
                return 1
                ;;
        esac
    fi
    
    # Parse version format: 0.YYYY.MM.DD
    parse_version() {
        local version="$1"
        local cleaned="${version#0.}"
        local year month day
        year="${cleaned%%.*}"
        local rest="${cleaned#*.}"
        month="${rest%%.*}"
        day="${rest#*.}"
        
        if [[ -n "$year" && -n "$month" && -n "$day" && "$year" != "$cleaned" && "$month" != "$rest" && "$day" != "$rest" ]]; then
            printf "%s %s %s" "$year" "$month" "$day"
        else
            echo ""
        fi
    }
    
    # Parse versions
    local old_ifs="$IFS"
    local installed_parts remote_parts
    IFS=' ' read -ra installed_parts <<< "$(parse_version "$installed_version")"
    IFS=' ' read -ra remote_parts <<< "$(parse_version "$remote_version")"
    IFS="$old_ifs"
    
    if [[ ${#installed_parts[@]} -ne 3 || ${#remote_parts[@]} -ne 3 ]]; then
        echo "Error: Invalid version format. Installed: $installed_version, Remote: $remote_version" >&2
        return 1
    fi
    
    local installed_year=${installed_parts[0]}
    local installed_month=${installed_parts[1]}
    local installed_day=${installed_parts[2]}
    
    local remote_year=${remote_parts[0]}
    local remote_month=${remote_parts[1]}
    local remote_day=${remote_parts[2]}
    
    # Compare versions (use 10# prefix to force decimal interpretation, avoiding octal)
    local update_available=false
    if (( 10#$remote_year > 10#$installed_year )); then
        update_available=true
    elif (( 10#$remote_year == 10#$installed_year )); then
        if (( 10#$remote_month > 10#$installed_month )); then
            update_available=true
        elif (( 10#$remote_month == 10#$installed_month )); then
            if (( 10#$remote_day > 10#$installed_day )); then
                update_available=true
            fi
        fi
    fi
    
    if [[ "$update_available" == "true" ]]; then
        echo "Update available!"
        echo "  Installed version: $installed_version ($installed_year-$installed_month-$installed_day)"
        echo "  Repository version: $remote_version ($remote_year-$remote_month-$remote_day)"
        echo ""
        echo "Tips:"
        echo "  - To ignore this repository version in future checks, run: brcupdate --ignore-this-version"
        echo ""
        echo "To update:"
        echo "  1. Navigate to your cloned BRC repository directory"
        echo "  2. Run: git pull"
        echo "  3. Run: ./___UPDATE.sh"
        echo ""
        echo "⚠️  Important: Do NOT run ___UPDATE.sh from ~/BASHRC/"
        echo "   The update script must be run from your cloned git repository directory."
        return 0
    else
        if [[ "$silent" != "true" ]]; then
            echo "You are running the latest version: $installed_version"
        fi
        return 0
    fi
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
