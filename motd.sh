#!/usr/bin/env bash

readonly __MOTD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__MOTD_DIR/_DEPENDENCY_CHECK.sh"

# Message of the day (shoo to remove, make to edit)
motd() {
  # Show help if no argument provided or if help is requested
  case "${1^^}" in
  "SHOO")
    if ! ensure_commands_present --caller "motd shoo" rm; then
      return 123
    fi
    if ! rm -f "$HOME/motd.txt"; then
      echo "Error: failed to remove message of the day file"
      return 1
    fi
    return 0
    ;;
  "MAKE")
    local editor="${EDITOR:-nvim}"
    if ! ensure_commands_present --caller "motd make" "$editor"; then
      return 123
    fi
    "$editor" "$HOME/motd.txt"
    return
    ;;
  "PRINT")
    if ! ensure_commands_present --caller "motd print" cat; then
      return 123
    fi
    [[ -f "$HOME/motd.txt" ]] && {
      printf "\nMESSAGE OF THE DAY:\n"
      if ! cat "$HOME/motd.txt"; then
        echo "Error: failed to display message of the day"
        return 1
      fi
      printf "\n"
      sleep 1
    }
    return 0
    ;;
  *)
    cat <<'EOF'
Usage: motd [COMMAND]

Message of the Day - Display, create, or manage your daily message

Commands:
  (no args)  - Show this help message
  print      - Display the current message of the day
  make       - Create or edit the message of the day file
  shoo       - Remove the message of the day file

Examples:
  motd              # Show this help message
  motd print        # Display current message
  motd make         # Edit/create message in nvim
  motd shoo         # Delete message file

File location: ~/motd.txt
EOF
    return 0
  esac
}

# If script is run directly (not sourced), call motd with any passed arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  motd "$@"
  exit $?
fi

# If it's true that we are here to help others,
# then what exactly are the others here for?
