#!/usr/bin/env bash

readonly __NAVTO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__NAVTO_DIR/_DEPENDENCY_CHECK.sh"

__navto_remove_destination() {
  local del_key="$1"
  local mode="${2:-}"  # when set to --direct, remove without confirmation and adjust messages
  local json_file="$__NAVTO_DIR/navto.json"

  if ! ensure_commands_present --caller "navto remove" jq; then
    return 123
  fi

  if [[ -z "$del_key" ]]; then
    printf "\e[1mUsage:\e[0m navto --remove <destination-key>\n"
    return 1
  fi

  if [[ ! -f "$json_file" ]]; then
    printf "\e[1;31mError:\e[0m No destinations file found: %s\n" "$json_file"
    return 1
  fi

  # Check existence
  if ! jq -e --arg k "${del_key^^}" 'has($k)' "$json_file" >/dev/null 2>&1; then
    printf "\e[1;31mError:\e[0m No destination found for key: \e[1;36m%s\e[0m\n" "${del_key^^}"
    return 1
  fi

  local name path
  name="$(jq -r --arg k "${del_key^^}" '.[ $k ].name // empty' "$json_file")"
  path="$(jq -r --arg k "${del_key^^}" '.[ $k ].path // empty' "$json_file")"

  if [[ "$mode" == "--direct" ]]; then
    printf "\e[1;35m🗑️  Removing stale destination (path missing):\e[0m\n"
    printf "  \e[1mKey :\e[0m \e[1;36m%s\e[0m\n" "${del_key^^}"
    printf "  \e[1mName:\e[0m %s\n" "$name"
    printf "  \e[1mPath:\e[0m %s\n" "$path"
  else
    printf "\e[1;35m🗑️  About to remove:\e[0m\n"
    printf "  \e[1mKey :\e[0m \e[1;36m%s\e[0m\n" "${del_key^^}"
    printf "  \e[1mName:\e[0m %s\n" "$name"
    printf "  \e[1mPath:\e[0m %s\n" "$path"
    local confirm
    read -r -p $'\n\e[1mProceed with removal?\e[0m [y/N]: ' confirm
    case "${confirm:-N}" in
      [Yy]* ) ;;
      * ) printf "\e[2mCancelled.\e[0m\n"; return 1 ;;
    esac
  fi

  local tmpfile
  tmpfile="$(mktemp)" || return 1
  if ! jq --arg k "${del_key^^}" 'del(.[$k])' "$json_file" > "$tmpfile"; then
    printf "\e[1;31mError:\e[0m failed to update JSON.\n"
    rm -f "$tmpfile"
    return 1
  fi
  if ! mv "$tmpfile" "$json_file"; then
    printf "\e[1;31mError:\e[0m failed to write %s\n" "$json_file"
    rm -f "$tmpfile"
    return 1
  fi
  printf "\e[1;32m✅ Removed destination\e[0m \e[1;36m%s\e[0m.\n" "${del_key^^}"
  return 0
}

# These are the default destinations if no navto.json file exists
__navto_create_template() {
  local json_file="$1"
  if cat > "$json_file" <<'JSON_TMPL'
{
  "X": { "name": "Home",             "path": "$HOME" },
  "D": { "name": "Documents",        "path": "$HOME/Documents" },
  "P": { "name": "Pictures",         "path": "$HOME/Pictures" },
  "V": { "name": "Videos",           "path": "$HOME/Videos" },
  "M": { "name": "Music",            "path": "$HOME/Music" },
  "L": { "name": "Downloads",        "path": "$HOME/Downloads" },
  ".": { "name": "Dotfiles",         "path": "$HOME/.config" },
  "T": { "name": "Temporary",        "path": "/tmp" },
  "R": { "name": "Filesystem Root",  "path": "/" },
  "SE": { "name": "System Etc",      "path": "/etc" },
  "SV": { "name": "System Var",      "path": "/var" },
  "SU": { "name": "System /usr",     "path": "/usr" },
  "SO": { "name": "System /opt",     "path": "/opt" },
  "SS": { "name": "System /srv",     "path": "/srv" }
}
JSON_TMPL
  then
    printf "\n\e[1;32m✅ Created template:\e[0m %s\n" "$json_file"
    printf "\e[2mTip:\e[0m run \e[1mnavto\e[0m to see available destinations.\n"
    return 0
  else
    printf "\e[1;31mError:\e[0m failed to write template to %s\n" "$json_file"
    return 1
  fi
}

__navto_add_destination() {
  local add_key="$1"
  local json_file="$__NAVTO_DIR/navto.json"

  if ! ensure_commands_present --caller "navto add" jq; then
    return 123
  fi

  local name path confirm
  printf "\e[1mEnter display name for '\e[1;36m%s\e[0m\e[1m': \e[0m" "$add_key"
  while true; do
    read -r name
    if [[ -z "$name" ]]; then
      printf "\e[1;31mError:\e[0m Name cannot be empty. Please enter a valid name:\n"
      continue
    fi
    # Validate JSON safety by letting jq parse it as a string
    if jq -e -n --arg n "$name" '$n' >/dev/null 2>&1; then
      break
    else
      printf "\e[1;31mError:\e[0m Name contains invalid characters for JSON. Please try again:\n"
    fi
  done

  printf "\e[1mEnter path for '\e[1;36m%s\e[0m\e[1m' (you can use \$HOME): \e[0m" "$add_key"
  while true; do
    read -r path
    if [[ -z "$path" ]]; then
      printf "\e[1;31mError:\e[0m Path cannot be empty. Please enter a valid path:\n"
      continue
    fi
    # Normalize: convert leading ~ to literal $HOME for storage
    path="${path/#\~/\$HOME}"
    local __expanded
    __expanded="$(eval echo "$path")"
    if [[ -d "$__expanded" ]]; then
      break
    else
      printf "\e[1;31mError:\e[0m Path does not exist: %s\n" "$__expanded"
      printf "\e[1mEnter a valid existing path for '\e[1;36m%s\e[0m\e[1m': \e[0m" "$add_key"
    fi
  done

  printf "\e[1;35m➕ About to add:\e[0m\n"
  printf "  \e[1mKey :\e[0m \e[1;36m%s\e[0m\n" "$add_key"
  printf "  \e[1mName:\e[0m %s\n" "$name"
  printf "  \e[1mPath:\e[0m %s\n" "$path"
  read -r -p $'\n\e[1mProceed?\e[0m [y/N]: ' confirm
  case "${confirm:-N}" in
    [Yy]* ) ;;
    * ) printf "\e[2mCancelled.\e[0m\n"; return 1 ;;
  esac

  # Ensure destinations file exists; initialize empty object if missing
  if [[ ! -f "$json_file" ]]; then
    echo "{}" > "$json_file" || { printf "\e[1;31mError:\e[0m cannot create %s\n" "$json_file"; return 1; }
  fi

  # Write updated JSON atomically
  local tmpfile
  tmpfile="$(mktemp)" || return 1
  if ! jq --arg k "$add_key" --arg n "$name" --arg p "$path" \
      '. + {($k): {name: $n, path: $p}}' \
      "$json_file" > "$tmpfile"; then
    printf "\e[1;31mError:\e[0m failed to update JSON.\n"
    rm -f "$tmpfile"
    return 1
  fi
  if ! mv "$tmpfile" "$json_file"; then
    printf "\e[1;31mError:\e[0m failed to write %s\n" "$json_file"
    rm -f "$tmpfile"
    return 1
  fi
  printf "\e[1;32m✅ Added destination\e[0m \e[1;36m%s\e[0m.\n" "$add_key"
  return 0
}

navto() {
  # Handle removal flag early
  if [[ "${1:-}" == "--remove" || "${1:-}" == "-r" || "${1:-}" == "--delete" || "${1:-}" == "-d" ]]; then
    shift
    local del_key="${1:-}"
    if [[ -z "$del_key" ]]; then
      echo "Usage: navto --remove|-r|--delete|-d <destination-key>"
      return 1
    fi
    __navto_remove_destination "$del_key"
    return $?
  fi

  local key="${1:-}"
  if [[ -z "$key" ]]; then
    printf "Usage: navto <destination-key>\n\n"
    printf "\e[1;35m🧭 Available destinations:\e[0m\n"
    if ensure_commands_present --caller "navto help" jq; then
      local json_file="$__NAVTO_DIR/navto.json"
      if [[ -f "$json_file" ]]; then
        # Color legend: key (bold cyan), name (bold), arrow+path (faint)
        jq -r 'to_entries | sort_by(.key)[] | "\(.key)\t\(.value.name)\t\(.value.path)"' "$json_file" | \
        while IFS=$'\t' read -r __k __n __p; do
          # Replace literal $HOME with ~ for readability (do not expand env yet)
          __p="${__p//'$HOME'/~}"
          printf "     \e[1;36m%-4s\e[0m - \e[1m%s\e[0m \e[2m-> %s\e[0m\n" "$__k" "$__n" "$__p"
        done
        #printf "\n"
      else
        printf "  \e[1;31m(destinations file not found: %s)\e[0m\n" "$json_file"
        read -r -p $'\n\e[1mCreate a starter template now?\e[0m [y/N]: ' __mk
        case "${__mk:-N}" in
          [Yy]* )
            if __navto_create_template "$json_file"; then
              return 0
            else
              return 1
            fi
            ;;
          * )
            return 0
            ;;
        esac
      fi
    else
      printf "  \e[2m(jq not available to display list)\e[0m\n"
    fi
    return 0
  fi

  if ! ensure_commands_present --caller "navto" jq; then
    return 123
  fi

  local json_file="$__NAVTO_DIR/navto.json"
  if [[ ! -f "$json_file" ]]; then
    printf "\e[1;31mError:\e[0m destinations file not found: %s\n" "$json_file"
    read -r -p $'\n\e[1mCreate a starter template now?\e[0m [y/N]: ' __mk
    case "${__mk:-N}" in
      [Yy]* )
        if __navto_create_template "$json_file"; then
          return 0
        else
          return 1
        fi
        ;;
      * )
        return 1
        ;;
    esac
  fi

  local ukey="${key^^}"

  local name path
  name="$(jq -r --arg k "$ukey" '.[ $k ].name // empty' "$json_file" 2>/dev/null)"
  path="$(jq -r --arg k "$ukey" '.[ $k ].path // empty' "$json_file" 2>/dev/null)"

  if [[ -z "$name" || -z "$path" ]]; then
    printf "\e[1;31mError:\e[0m destination not found for key: \e[1;36m%s\e[0m\n" "$key"
    read -r -p "$(printf '\n\e[1mWould you like to add key \e[1;36m%s\e[0m?\e[0m [y/N]: ' "$ukey")" __ans
    case "${__ans:-N}" in
      [Yy]* )
        if __navto_add_destination "$ukey"; then
          printf "\e[2mYou can now run:\e[0m navto \e[1;36m%s\e[0m\n" "$ukey"
          return 0
        else
          return 1
        fi
        ;;
      * )
        return 1
        ;;
    esac
  fi

  local expanded_path
  expanded_path="$(eval echo "$path")"

  # If destination directory no longer exists, confirm once here, then remove directly
  if [[ ! -d "$expanded_path" ]]; then
    printf "\e[1;31mError:\e[0m destination path no longer exists: %s\n" "$expanded_path"
    read -r -p "$(printf '\n\e[1mWould you like to remove key \e[1;36m%s\e[0m from destinations? [y/N]: ' "$ukey")" __rm
    case "${__rm:-N}" in
      [Yy]* )
        __navto_remove_destination "$ukey" --direct
        return $?
        ;;
      * )
        return 1
        ;;
    esac
  fi

  if ! cd "$expanded_path" 2>/dev/null; then
    printf "\e[1;31mError:\e[0m failed to navigate to: %s\n" "$expanded_path"
    return 1
  fi

  printf "📁 \e[1;36m%s\e[0m   [\e[1m%s\e[0m]\n" "$(pwd)" "$name"
  if command -v eza >/dev/null 2>&1; then
    eza -lh --group-directories-first --icons=auto
  else
    ls -Al --color=auto
  fi
  return 0
}