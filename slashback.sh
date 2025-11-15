#!/usr/bin/env bash

readonly __SLASHBACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__SLASHBACK_DIR/_DEPENDENCY_CHECK.sh"

__slashback() {
  local depth=${#FUNCNAME[1]}    # caller’s name: '/', '//', etc.
  local target="."
  for ((i = 0; i < depth; i++)); do
    target+="/.."
  done
  cd "$target"
}

function /()    { __slashback; }
function //()   { __slashback; }
function ///()  { __slashback; }
function ////() { __slashback; }
function /////(){ __slashback; }
function //////(){ __slashback; }

# If script is run directly (not sourced), call __slashback with any passed arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  __slashback "$@"
fi

#Given some of the recent threads, the interactive discussions might
#need to be conducted on canvas, in the presence of a referee, while
#wearing padded gloves.  ;-)
#	-- Phil Hands