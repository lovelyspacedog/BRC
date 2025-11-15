#!/usr/bin/env bash

readonly __WEATHER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__WEATHER_DIR/_DEPENDENCY_CHECK.sh"

# Wttr module
wttr() {
  if ! ensure_commands_present --caller "wttr" curl; then
    return 123
  fi

  local location="${1// /+}"
  test "$#" -gt 0 && shift
  local args=()
  for p in $WTTR_PARAMS "$@"; do
    args+=("--data-urlencode" "$p")
  done
  curl -fGsS -H "Accept-Language: ${LANG%_*}" "${args[@]}" --compressed "wttr.in/$location"
}

weather() {
  if ! ensure_commands_present --caller "weather" curl head; then
    return 123
  fi

  [[ "${1^^}" == "HELP" ]] && {
    echo "Usage: weather [options]"
    echo ""
    echo "Display weather information for your location"
    echo ""
    echo "Options:"
    echo "  current    - Show only current weather"
    echo "  forecast   - Show only 3-day forecast"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  weather            # Display current + 3-day forecast"
    echo "  weather current    # Display only current weather"
    echo "  weather forecast   # Display only 3-day forecast"
    echo "  weather help       # Show this help message"
    echo ""
    echo "  wttr <location>    # Display weather for a specific location"
    echo ""
    return 0
  }

  local city=$(curl -s ipinfo.io/city 2>/dev/null)
  [[ -z "$city" ]] && {
    echo "Error: Could not detect location"
    return 1
  }

  case "${1^^}" in
  "CURRENT")
    echo -e "\n\033[36m🌤️  CURRENT WEATHER\033[0m"
    echo "=================="
    curl -s "wttr.in/$city?format=3"
    return 0
    ;;
  "FORECAST")
    echo -e "\n\033[36m📅 3-DAY FORECAST\033[0m"
    echo "=================="
    wttr "$city"
    return 0
    ;;
  "HELP")
    weather help
    return 0
    ;;
  *)
    echo -e "\n\033[36m🌤️  WEATHER FOR $city\033[0m"
    echo "========================"
    echo ""
    echo -e "\033[33m📍 Current Weather:\033[0m"
    curl -s "wttr.in/$city?format=3" | head -3
    echo ""
    echo -e "\033[33m📅 3-Day Forecast:\033[0m"
    wttr "$city"
    return 0
    ;;
  esac
}

# If script is run directly (not sourced), call weather with any passed arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    weather "$@"
    exit $?
fi