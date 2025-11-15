#!/usr/bin/env bash

# xdg-open wrapper
open() {
  # If no arguments, just return
  [[ -z "$1" ]] && return 0
  
  # Check if the argument is a local file that exists
  if [[ -f "$1" ]]; then
    # Check if it's an executable or a script file (terminal application)
    if [[ -x "$1" ]] || [[ "$1" =~ \.(sh|bash|zsh|fish|py|pl|rb|js|ts)$ ]]; then
      # Execute in a new kitty window to ensure output is visible
      kitty --detach "$@" >/dev/null 2>&1 & disown
      return 0
    fi
  fi
  
  # For everything else (URLs, non-executable files, etc.), use xdg-open
  xdg-open "$@" >/dev/null 2>&1 & disown
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  open "$@"
  exit $?
fi