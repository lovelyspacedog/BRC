#!/usr/bin/env bash

readonly __NAVTO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__NAVTO_DIR/_DEPENDENCY_CHECK.sh"

navto() {
  # Show help if no argument provided
  [[ -z "$1" || "$1^^" == "help" ]] && {
    echo "Usage: navto <destination>"
    echo "Available destinations:"
    echo "  X     - Home directory"
    echo "  P     - Pictures"
    echo "  V     - Videos"
    echo "  M     - Music"
    echo "  D     - Documents"
    echo "  L     - Downloads"
    echo "  W     - Wallpapers"
    echo "  .     - .config"
    echo "  H     - Hyprland config"
    echo "  S     - Hyprland scripts"
    echo "  WB    - Waybar config"
    echo "  U     - System applications"
    echo "  U2    - User applications"
    echo "  U3    - Local applications"
    echo "  C     - Code/Projects"
    echo "  T     - Templates"
    echo "  R     - Recent downloads"
    return 1
  }

  case "${1^^}" in
  "X" | "HOME")
    cd "$HOME"
    ;;
  "P" | "PICS" | "PICTURES")
    cd "$HOME/Pictures"
    ;;
  "V" | "VID" | "VIDEOS")
    cd "$HOME/Videos"
    ;;
  "M" | "MUSIC")
    cd "$HOME/Music"
    ;;
  "D" | "DOCS" | "DOCUMENTS")
    cd "$HOME/Documents"
    ;;
  "L" | "DOWN" | "DOWNLOADS")
    cd "$HOME/Downloads"
    ;;
  "W" | "WALL" | "WALLPAPERS")
    cd "$HOME/Videos/wallpapers"
    ;;
  "." | "CONFIG" | "CFG")
    cd "$HOME/.config"
    ;;
  "H" | "HYPR" | "HYPRLAND")
    cd "$HOME/.config/hypr"
    ;;
  "S" | "SCRIPTS" | "HYPRSCRIPTS")
    cd "$HOME/.config/hyprScripts"
    ;;
  "WB" | "WAYBAR")
    cd "$HOME/.config/waybar"
    ;;
  "U" | "USR" | "SYSTEM")
    cd "/usr/share/applications"
    ;;
  "U2" | "USER" | "LOCAL")
    cd "$HOME/.local/share/applications"
    ;;
  "U3" | "LOCAL")
    cd "/usr/local/share/applications"
    ;;
  "C" | "CODE" | "PROJECTS")
    cd "$HOME/Code" 2>/dev/null || cd "$HOME/Projects" 2>/dev/null || cd "$HOME"
    ;;
  "T" | "TEMPLATES")
    cd "$HOME/Templates" 2>/dev/null || cd "$HOME"
    ;;
  "R" | "RECENT")
    if ! ensure_commands_present --caller "navto recent" ls head; then
      return 123
    fi
    if cd "$HOME/Downloads"; then
      ls -lt | head -5
      return 0
    else
      return 1
    fi
    ;;
  *)
    echo "Unknown destination: $1"
    echo "Run 'navto' without arguments to see available options"
    return 1
    ;;
  esac

  # Show current directory contents if cd was successful
  local cd_result=$?
  [[ $cd_result -eq 0 ]] && {
    if ! ensure_commands_present --caller "navto list" pwd ls; then
      return 123
    fi
    echo "📁 $(pwd)"
    if command -v eza >/dev/null 2>&1; then
      eza -Alh --group-directories-first --icons=auto
    else
      ls -Al --color=auto
    fi
  }
  return 0
}

# If script is run directly (not sourced), call navto with any passed arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  navto "$@"
  exit $?
fi