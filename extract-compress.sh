#!/usr/bin/env bash

readonly __EXTRACT_COMPRESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__EXTRACT_COMPRESS_DIR/_DEPENDENCY_CHECK.sh"

# Extract archives based on extension
extract() {
    [[ ! -f "$1" ]] && {
        echo "Error: '$1' does not exist or is not a file"
        return 1
    }
    case "$1" in
        *.tar.bz2)
            if ! ensure_commands_present --caller "extract" tar; then
                return 123
            fi
            tar xjf "$1"
            ;;
        *.tar.gz)
            if ! ensure_commands_present --caller "extract" tar; then
                return 123
            fi
            tar xzf "$1"
            ;;
        *.bz2)
            if ! ensure_commands_present --caller "extract" bunzip2; then
                return 123
            fi
            bunzip2 "$1"
            ;;
        *.rar)
            if ! ensure_commands_present --caller "extract" unrar; then
                return 123
            fi
            unrar x "$1"
            ;;
        *.gz)
            if ! ensure_commands_present --caller "extract" gunzip; then
                return 123
            fi
            gunzip "$1"
            ;;
        *.tar)
            if ! ensure_commands_present --caller "extract" tar; then
                return 123
            fi
            tar xf "$1"
            ;;
        *.tbz2)
            if ! ensure_commands_present --caller "extract" tar; then
                return 123
            fi
            tar xjf "$1"
            ;;
        *.tgz)
            if ! ensure_commands_present --caller "extract" tar; then
                return 123
            fi
            tar xzf "$1"
            ;;
        *.zip)
            if ! ensure_commands_present --caller "extract" unzip; then
                return 123
            fi
            unzip "$1"
            ;;
        *.Z)
            if ! ensure_commands_present --caller "extract" uncompress; then
                return 123
            fi
            uncompress "$1"
            ;;
        *.7z)
            if ! ensure_commands_present --caller "extract" 7z; then
                return 123
            fi
            7z x "$1"
            ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
}

compress() {
    local input="$1"
    local format="${2:-}"
    local output=""

    [[ ! -e "$input" ]] && {
        echo "Error: '$input' does not exist" >&2
        return 1
    }

    # Determine format and output filename
    if [[ -n "$format" ]]; then
        # Format specified as second argument
        case "$format" in
            tar.bz2|tbz2)
                format="tar.bz2"
                output="${input%/}.tar.bz2"
                ;;
            tar.gz|tgz)
                format="tar.gz"
                output="${input%/}.tar.gz"
                ;;
            bz2|rar|gz|tar|zip|Z|7z)
                output="${input%/}.${format}"
                ;;
            *)
                echo "Error: Unknown format '$format'" >&2
                echo "Supported formats: tar.bz2, tar.gz, bz2, rar, gz, tar, tbz2, tgz, zip, Z, 7z" >&2
                return 1
                ;;
        esac
    elif [[ -d "$input" ]]; then
        # Default for directories: tar.gz
        format="tar.gz"
        output="${input%/}.tar.gz"
    else
        # Default for files: gz
        format="gz"
        output="${input}.gz"
    fi

    # Check if output already exists
    [[ -e "$output" ]] && {
        echo "Error: Output file '$output' already exists" >&2
        return 1
    }

    # Create archive based on format
    case "$format" in
        tar.bz2|tbz2)
            if ! ensure_commands_present --caller "compress" tar; then
                return 123
            fi
            tar cjf "$output" "$input"
            ;;
        tar.gz|tgz)
            if ! ensure_commands_present --caller "compress" tar; then
                return 123
            fi
            tar czf "$output" "$input"
            ;;
        bz2)
            if ! ensure_commands_present --caller "compress" bzip2; then
                return 123
            fi
            bzip2 -k "$input"
            # bzip2 creates input.bz2, so we need to rename if different
            [[ "$output" != "${input}.bz2" ]] && mv "${input}.bz2" "$output"
            ;;
        rar)
            if ! ensure_commands_present --caller "compress" rar; then
                return 123
            fi
            rar a "$output" "$input"
            ;;
        gz)
            if ! ensure_commands_present --caller "compress" gzip; then
                return 123
            fi
            gzip -k "$input"
            # gzip creates input.gz, so we need to rename if different
            [[ "$output" != "${input}.gz" ]] && mv "${input}.gz" "$output"
            ;;
        tar)
            if ! ensure_commands_present --caller "compress" tar; then
                return 123
            fi
            tar cf "$output" "$input"
            ;;
        zip)
            if ! ensure_commands_present --caller "compress" zip; then
                return 123
            fi
            if [[ -d "$input" ]]; then
                zip -r "$output" "$input"
            else
                zip "$output" "$input"
            fi
            ;;
        Z)
            if ! ensure_commands_present --caller "compress" compress; then
                return 123
            fi
            compress -c "$input" > "$output"
            ;;
        7z)
            if ! ensure_commands_present --caller "compress" 7z; then
                return 123
            fi
            7z a "$output" "$input"
            ;;
        *)
            echo "Error: Unsupported format '$format'" >&2
            return 1
            ;;
    esac

    local result=$?
    if [[ $result -eq 0 ]]; then
        echo "Created: $output"
        return 0
    else
        echo "Error: Failed to create archive" >&2
        return $result
    fi
}

# Script entrypoint
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -z "$1" ]]; then
        echo "Usage: $0 <function> [arguments...]"
        echo "Functions: extract, compress"
        exit 1
    fi
    
    func="$1"
    shift
    if declare -F "$func" >/dev/null 2>&1; then
        "$func" "$@"
        exit $?
    else
        echo "Error: Function '$func' not found." >&2
        exit 1
    fi
fi