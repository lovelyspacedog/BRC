#!/usr/bin/env bash

readonly __TIMER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__TIMER_DIR/_DEPENDENCY_CHECK.sh"

timer() {

  if ! ensure_commands_present --caller "timer" date read rm printf shopt; then
    return 123
  fi

  local safe_name="${1:-Timer}"

  local -r -i MINUTES_IN_SEC=60
  local -r -i HOURS_IN_SEC=$((60*60))


  # Convert spaces to underscores first, then allow dots, underscores, and hyphens
  safe_name="${safe_name// /_}"
  safe_name="${safe_name//[^[:alnum:]._-]/}"
  safe_name="${safe_name:-Timer}"
  # Default to 'Timer' if no name provided

  if [[ "${1^^}" == "CLEAR" ]]; then
    read -t 10 -n 1 -r -p "Are you sure you want to clear all timers? (y/N): " clear ||
      clear="N"
    printf "\n"
    [[ "${clear^^}" == "Y" ]] && {
      if rm -f /tmp/timer-*.txt; then
        printf "All timers cleared!\n"
        return 0
      else
        printf "Error: Could not clear timers.\n"
        return 4
      fi
    }
    printf "Timers not cleared.\n"
    return 0
  fi

  if [[ "${1^^}" == "LIST" ]]; then
    printf "Listing all timers:\n"

    shopt -s nullglob
    local timer_files=()
    local file
    for file in /tmp/timer-*.txt; do
      [[ -f "$file" ]] || continue
      timer_files+=("$file")
    done
    shopt -u nullglob

    if ((${#timer_files[@]} == 0)); then
      printf "  (no timers found)\n"
      return 0
    fi

    local now starttime elapsed hours minutes seconds name
    now="$(date +%s)"

    for file in "${timer_files[@]}"; do
      name="${file#/tmp/timer-}"
      name="${name%.txt}"

      if ! starttime="$(<"$file")"; then
        printf "  %s: error reading timer file\n" "$name"
        continue
      fi

      elapsed=$(( now - starttime ))
      (( elapsed < 0 )) && elapsed=0
      hours=$(( elapsed / HOURS_IN_SEC ))
      minutes=$(( (elapsed % HOURS_IN_SEC) / MINUTES_IN_SEC ))
      seconds=$(( elapsed % MINUTES_IN_SEC ))
      printf "  %s: %03d:%02d:%02d\n" "$name" "$hours" "$minutes" "$seconds"
    done
    return 0
  fi

  local flagfile="/tmp/timer-$safe_name.txt"

  local -i starttime=0
  local -i endtime=0
  local -i elapsedtime=0

  local -i totalHours=0
  local -i totalMinutes=0
  local -i totalSeconds=0

  if ! [[ -f "$flagfile" ]]; then
    if ! printf "%s" "$(date +%s)" >"$flagfile"; then
      printf "Error: Could not create %s. No timer set.\n" "$flagfile"
      return 1
    else
      printf "Timer set for %s!\n" "$safe_name"
      return 0
    fi
  else
    if ! starttime="$(cat "$flagfile")"; then
      printf "Error: Could not access %s.\n" "$flagfile"
      return 2
    fi
    endtime="$(date +%s)"
    elapsedtime=$(( endtime - starttime ))
    while [[ $elapsedtime -ge $HOURS_IN_SEC ]]; do
      elapsedtime=$((elapsedtime - HOURS_IN_SEC))
      ((totalHours++))
    done
    while [[ $elapsedtime -ge $MINUTES_IN_SEC ]]; do
      elapsedtime=$((elapsedtime - MINUTES_IN_SEC))
      ((totalMinutes++))
    done
    totalSeconds="$elapsedtime"
    printf "Elapsed Time for %s: %03d:%02d:%02d\n" "$safe_name" "$totalHours" "$totalMinutes" "$totalSeconds"
    sleep 1
    read -n 1 -p "Would you like to reset the timer? (y/N): " reset
    printf "\n"
    [[ "${reset^^}" == "Y" ]] && {
      if ! rm -f "$flagfile"; then
        printf "Error: Could not delete %s. Timer for %s is still set.\n" "$flagfile" "$safe_name"
        return 3
      fi
      printf "Timer for %s reset!\n" "$safe_name" 
      return 0
    }
    printf "Timer for %s is still set.\nUse 'timer %s' to display the current time.\n" "$safe_name" "$safe_name"
    return 0
  fi
}

# If script is run directly (not sourced), call timer with any passed arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  timer "$@"
fi