#!/usr/bin/env bash

readonly __DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__DOTS_DIR/_DEPENDENCY_CHECK.sh"

# Dots (dots to list and cd to directories in .config)
dots() {
  # Show help if no argument provided or help is requested
  [[ -z "$1" ]] && {
    echo "Usage: dots <command> [directory]"
    echo ""
    echo "Manage and navigate .config directories"
    echo ""
    echo "Commands:"
    echo "  ls [dir]  - List directories or contents"
    echo "  <dir>     - Navigate to a .config directory"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  dots ls           # List all .config directories"
    echo "  dots ls hypr      # List contents of ~/.config/hypr"
    echo "  dots hypr         # Navigate to ~/.config/hypr"
    echo "  dots waybar       # Navigate to ~/.config/waybar"
    echo "  dots help         # Show this help"
    echo ""
    echo "Note: All operations work within ~/.config/"
    return 1
  }

  # Show help if help is requested
  [[ "${1^^}" == "HELP" ]] && {
    echo "Usage: dots <command> [directory]"
    echo ""
    echo "Manage and navigate .config directories"
    echo ""
    echo "Commands:"
    echo "  ls [dir]  - List directories or contents"
    echo "  <dir>     - Navigate to a .config directory"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  dots ls           # List all .config directories"
    echo "  dots ls hypr      # List contents of ~/.config/hypr"
    echo "  dots hypr         # Navigate to ~/.config/hypr"
    echo "  dots waybar       # Navigate to ~/.config/waybar"
    echo "  dots help         # Show this help"
    echo ""
    echo "Note: All operations work within ~/.config/"
    return 0
  }

  [[ "$1" == "ls" ]] && {
    if ! ensure_commands_present --caller "dots" find sort xargs ls; then
      return 123
    fi

    [[ -z "$2" ]] && {
      printf "Displaying .config: \n"
      find "$HOME/.config" -maxdepth 1 -type d ! -name "." -exec basename {} \; |
        sort |
        xargs
      printf "\n"
      return 0
    }
    [[ -d "$HOME/.config/$2" ]] || {
      printf "[%s] is not a valid directory.\n\n" "~/.config/$2"
      return 2
    }
    echo "📁 Listing contents of $HOME/.config/$2"
    if command -v eza >/dev/null 2>&1; then
      eza -Alh --group-directories-first --icons=auto "$HOME/.config/$2"
    else
      ls -Al --color=auto "$HOME/.config/$2"
    fi
    printf "\n"
    return 0
  }
  [[ -d "$HOME/.config/$1" ]] || {
    printf "[%s] is not a valid directory.\n\n" "~/.config/$1"
    return 3
  }
  cd "$HOME/.config/$1"
  echo "📁 $(pwd)"
  if command -v eza >/dev/null 2>&1; then
    eza -Alh --group-directories-first --icons=auto
  else
    ls -Al --color=auto
  fi
  printf "\n"
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dots "$@"
    exit $?
fi