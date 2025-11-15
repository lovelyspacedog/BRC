#!/bin/bash
CURRENT_VERSION="0.2025.11.15" 
COPYRIGHT="${COPYRIGHT:-true}"
msg="Made by Tony Pup (c) 2025. All rights reserved.    Rarf~~! <3"

! ! ! ! ! $COPYRIGHT || {
  clear
  for ((i = 0; i < ${#msg}; i++)); do
    printf "%s" "${msg:$i:1}"
    sleep 0.01
  done
  sleep 0.4 && rarf_text="Rarf~~! <3"
  if [[ "$msg" == *"$rarf_text" ]]; then
    rarf_start=$((${#msg} - ${#rarf_text}))
    printf "\033[%dD" ${#rarf_text}
    printf "%${#rarf_text}s" ""
    printf "\033[%dD" ${#rarf_text}
  fi
  printf "\n\n"
  sleep 0.03
}

log_step()    { printf "\n[%s] %s\n" "$1" "$2"; }
log_detail()  { printf "    - %s\n" "$1"; }
log_success() { printf "[OK] %s\n" "$1"; }
log_warn()    { printf "[WARN] %s\n" "$1"; }
log_error()   { printf "[ERR] %s\n" "$1"; }
pause()       { sleep 0.5; }

# Exit Code Organization:
#   0  - Success
#   1  - User cancellation
#   2-9 - Setup/validation errors (script directory, dependency checks)
#  10-19 - Backup-related errors
#  20-29 - .bashrc deployment errors
#  30-39 - BASHRC directory errors
#  40-49 - Script copy errors
#  50-59 - Configuration/settings errors

# Let's keep things tidy; this could be someone else's computer after all.
set -euo pipefail
IFS=$'\n\t'

cleanup_bashrc_dir_if_empty() {
  local dir="$HOME/BASHRC"
  if [[ -d "$dir" ]]; then
    shopt -s nullglob dotglob
    local remaining=("$dir"/*)
    shopt -u nullglob dotglob
    if ((${#remaining[@]} == 0)); then
      rmdir "$dir" 2>/dev/null || true
    fi
  fi
}

declare -a copied_targets=()
bashrc_dir="$HOME/BASHRC"
preexisting_bashrc_dir=false

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if [[ -z "$script_dir" ]]; then
  log_error "Unable to determine script directory. Installation halted."
  exit 2
fi
if [[ "$script_dir" == "$HOME/BASHRC" ]]; then
  log_error "Installer cannot be run from the BASHRC directory. Installation halted."
  exit 3
fi
if ! cd "$script_dir"; then
  log_error "Failed to enter install directory at $script_dir."
  exit 4
fi

# Source dependency check utility
if [[ -f "$script_dir/_DEPENDENCY_CHECK.sh" ]]; then
  source "$script_dir/_DEPENDENCY_CHECK.sh"
else
  log_error "_DEPENDENCY_CHECK.sh not found. Cannot perform dependency checks."
  exit 5
fi

# Master dependency check function
check_all_dependencies() {
  local missing_required=()
  local missing_optional=()
  local warnings=()
  
  log_step "Dependency Check" "Scanning project for all dependencies"
  pause
  
  # Read settings.json to determine which optional features are enabled
  local enable_blesh=true
  local enable_shellmommy=true
  local enable_wlcopy=true
  local enable_vimkeys=true
  local enable_zoxide=true
  local enable_automotd=true
  local enable_manual=true
  local enable_starship=true
  
  if [[ -f "$script_dir/settings.json" ]]; then
    if command -v jq >/dev/null 2>&1; then
      enable_blesh=$(jq -r '.enable_blesh // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
      enable_shellmommy=$(jq -r '.enable_shellmommy // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
      enable_wlcopy=$(jq -r '.enable_wlcopy // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
      enable_vimkeys=$(jq -r '.enable_vimkeys // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
      enable_zoxide=$(jq -r '.enable_zoxide // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
      enable_automotd=$(jq -r '.enable_automotd // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
      enable_manual=$(jq -r '.enable_manual // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
      enable_starship=$(jq -r '.enable_starship // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
    else
      # Fallback: parse JSON manually
      while IFS= read -r line; do
        case "$line" in
          *\"enable_blesh\"*)
            [[ "$line" =~ \"enable_blesh\"[[:space:]]*:[[:space:]]*(true|false) ]] && enable_blesh="${BASH_REMATCH[1]}"
            ;;
          *\"enable_shellmommy\"*)
            [[ "$line" =~ \"enable_shellmommy\"[[:space:]]*:[[:space:]]*(true|false) ]] && enable_shellmommy="${BASH_REMATCH[1]}"
            ;;
          *\"enable_wlcopy\"*)
            [[ "$line" =~ \"enable_wlcopy\"[[:space:]]*:[[:space:]]*(true|false) ]] && enable_wlcopy="${BASH_REMATCH[1]}"
            ;;
          *\"enable_zoxide\"*)
            [[ "$line" =~ \"enable_zoxide\"[[:space:]]*:[[:space:]]*(true|false) ]] && enable_zoxide="${BASH_REMATCH[1]}"
            ;;
          *\"enable_automotd\"*)
            [[ "$line" =~ \"enable_automotd\"[[:space:]]*:[[:space:]]*(true|false) ]] && enable_automotd="${BASH_REMATCH[1]}"
            ;;
          *\"enable_starship\"*)
            [[ "$line" =~ \"enable_starship\"[[:space:]]*:[[:space:]]*(true|false) ]] && enable_starship="${BASH_REMATCH[1]}"
            ;;
        esac
      done < "$script_dir/settings.json"
    fi
  fi
  
  # Core required dependencies (always needed for basic functionality)
  log_detail "Checking core dependencies..."
  # Commands that are typically external programs
  local external_deps=("bash" "cp" "mkdir" "rm" "cat" "date" "sed" "grep" "ls" "mv" "touch" "chmod" "basename" "dirname" "head" "tail" "tr" "xargs" "sort" "find" "stat" "du" "wc" "awk" "cut")
  # Commands that are bash builtins (checked with type)
  local builtin_deps=("pwd" "cd" "printf" "read" "shopt")
  
  for cmd in "${external_deps[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing_required+=("$cmd")
    fi
  done
  
  for cmd in "${builtin_deps[@]}"; do
    if ! type "$cmd" >/dev/null 2>&1; then
      missing_required+=("$cmd (builtin)")
    fi
  done
  
  # Editor (highly recommended, but not strictly required)
  if ! command -v nvim >/dev/null 2>&1 && ! command -v vim >/dev/null 2>&1 && ! command -v vi >/dev/null 2>&1; then
    warnings+=("No editor found (nvim/vim/vi). Some functions may not work properly.")
  fi
  
  # Optional dependencies based on settings.json
  log_detail "Checking optional dependencies based on settings..."
  
  # jq - for parsing settings.json (optional, has fallback)
  if ! command -v jq >/dev/null 2>&1; then
    warnings+=("jq not found. JSON parsing will use fallback method.")
  fi
  
  # blesh - Ble.sh shell enhancement
  if [[ "$enable_blesh" == "true" ]]; then
    if [[ ! -f "$HOME/.local/share/blesh/ble.sh" ]]; then
      missing_optional+=("blesh (file: ~/.local/share/blesh/ble.sh)")
    fi
  fi
  
  # shell-mommy
  if [[ "$enable_shellmommy" == "true" ]]; then
    if [[ ! -f "$HOME/shell-mommy/shell-mommy.sh" ]]; then
      missing_optional+=("shell-mommy (file: ~/shell-mommy/shell-mommy.sh)")
    fi
  fi
  
  # wl-copy (Wayland clipboard)
  if [[ "$enable_wlcopy" == "true" ]]; then
    if ! command -v wl-copy >/dev/null 2>&1; then
      missing_optional+=("wl-copy")
    fi
  fi
  
  # zoxide
  if [[ "$enable_zoxide" == "true" ]]; then
    if ! command -v zoxide >/dev/null 2>&1; then
      missing_optional+=("zoxide")
    fi
  fi
  
  # automotd dependencies
  if [[ "$enable_automotd" == "true" ]]; then
    if ! command -v fortune >/dev/null 2>&1; then
      missing_optional+=("fortune")
    fi
  fi
  
  # starship - Cross-shell prompt customization
  if [[ "$enable_starship" == "true" ]]; then
    if ! command -v starship >/dev/null 2>&1; then
      missing_optional+=("starship")
    fi
  fi
  
  # Function-specific optional dependencies
  log_detail "Checking function-specific dependencies..."
  
  # Weather functions
  if ! command -v curl >/dev/null 2>&1; then
    missing_optional+=("curl (for weather functions)")
  fi
  
  # pokefetch
  if ! command -v pokemon-colorscripts >/dev/null 2>&1; then
    missing_optional+=("pokemon-colorscripts (for pokefetch)")
  fi
  if ! command -v fastfetch >/dev/null 2>&1; then
    missing_optional+=("fastfetch (for pokefetch)")
  fi
  
  # dl-paper
  if ! command -v yt-dlp >/dev/null 2>&1; then
    missing_optional+=("yt-dlp (for dl-paper)")
  fi
  if ! command -v ffmpeg >/dev/null 2>&1; then
    missing_optional+=("ffmpeg (for dl-paper)")
  fi
  
  # analyze-file
  if ! command -v file >/dev/null 2>&1; then
    missing_optional+=("file (for analyze-file)")
  fi
  if ! command -v sha256sum >/dev/null 2>&1; then
    missing_optional+=("sha256sum (for analyze-file)")
  fi
  
  # extract() function dependencies
  if ! command -v tar >/dev/null 2>&1; then
    missing_optional+=("tar (for extract function)")
  fi
  if ! command -v unzip >/dev/null 2>&1; then
    missing_optional+=("unzip (for extract function)")
  fi
  if ! command -v bunzip2 >/dev/null 2>&1; then
    missing_optional+=("bunzip2 (for extract function)")
  fi
  if ! command -v gunzip >/dev/null 2>&1; then
    missing_optional+=("gunzip (for extract function)")
  fi
  if ! command -v unrar >/dev/null 2>&1; then
    missing_optional+=("unrar (for extract function)")
  fi
  if ! command -v uncompress >/dev/null 2>&1; then
    missing_optional+=("uncompress (for extract function)")
  fi
  if ! command -v 7z >/dev/null 2>&1; then
    missing_optional+=("7z (for extract function)")
  fi
  
  # cpuinfo() function dependencies
  if ! command -v top >/dev/null 2>&1; then
    missing_optional+=("top (for cpuinfo function)")
  fi
  if ! command -v ps >/dev/null 2>&1; then
    missing_optional+=("ps (for cpuinfo function)")
  fi
  
  # calc() function
  if ! command -v bc >/dev/null 2>&1; then
    missing_optional+=("bc (for calc function)")
  fi
  
  # cpx() function
  if ! command -v g++ >/dev/null 2>&1; then
    missing_optional+=("g++ (for cpx function)")
  fi
  
  # update() function
  if ! command -v sudo >/dev/null 2>&1; then
    missing_optional+=("sudo (for update function)")
  fi
  
  # woof() function
  if ! command -v notify-send >/dev/null 2>&1; then
    missing_optional+=("notify-send (for woof function)")
  fi
  
  # xx() function
  if ! command -v kitty >/dev/null 2>&1; then
    missing_optional+=("kitty (for xx function)")
  fi
  
  # ssh (for navto ssh)
  if ! command -v ssh >/dev/null 2>&1; then
    missing_optional+=("ssh (for navto ssh command)")
  fi
  
  # eza (optional, has ls fallback)
  if ! command -v eza >/dev/null 2>&1; then
    warnings+=("eza not found. Will use ls as fallback.")
  fi
  
  # Report results
  printf "\n"
  if ((${#missing_required[@]} > 0)); then
    log_error "Missing required dependencies:"
    for dep in "${missing_required[@]}"; do
      log_detail "$dep"
    done
    printf "\n"
    log_error "Installation cannot proceed without required dependencies."
    return 1
  else
    log_success "All core dependencies are available"
  fi
  
  if ((${#warnings[@]} > 0)); then
    for warn in "${warnings[@]}"; do
      log_warn "$warn"
    done
  fi
  
  if ((${#missing_optional[@]} > 0)); then
    log_warn "Missing optional dependencies (some features may not work):"
    for dep in "${missing_optional[@]}"; do
      log_detail "$dep"
    done
    printf "\n"
    log_detail "Installation can proceed, but some features may be unavailable."
  else
    log_success "All optional dependencies are available"
  fi
  
  printf "\n"
  return 0
}

printf "=== BRC Installer ===\n"
pause

# Run master dependency check
if ! check_all_dependencies; then
  log_error "Dependency check failed. Please install missing required dependencies and try again."
  exit 6
fi

printf "Would you like to install the configuration into\n"
printf "  your home directory? A timestamped backup of .bashrc will be created.\n"
printf "\n"
printf "(y/N): "
read -t 10 -n 1 -r ans || ans="m"
# If no input given, enter an literal 'N' before newline for user-friendliness
[[ "$ans" == "m" ]] && {
  printf "N"
  ans="N"
}
[[ $ans =~ ^[Yy]$ ]] || {
  printf "\n"
  echo "Installation cancelled. No changes were made."
  exit 1
}
printf "\n"

log_step "Backup" "Preparing current .bashrc"
pause
if ! [[ -d ~/.bashrc.backup ]]; then
  log_detail "Creating ~/.bashrc.backup directory"
  pause
  if ! mkdir -p ~/.bashrc.backup; then
    log_error "Failed to create ~/.bashrc.backup. No changes were made."
    exit 10
  fi
fi
if ! [[ -f ~/.bashrc ]]; then
  log_error "~/.bashrc not found. No changes were made."
  exit 11
fi
saved_timestamp=$(date +%Y%m%d%H%M%S)
if ! cp ~/.bashrc ~/.bashrc.backup/$saved_timestamp.bashrc; then
  log_error "Failed to create backup of ~/.bashrc. No changes were made."
  exit 12
fi
log_success "Backup saved to ~/.bashrc.backup/$saved_timestamp.bashrc"

# 2.
log_step "Install" "Deploying new .bashrc"
if ! cp .bashrc.copyToHome ~/.bashrc; then
  log_error "Failed to copy .bashrc.copyToHome to $HOME/.bashrc. Only backup was created."
  log_detail "Reverting ~/.bashrc to previous version"
  if ! cp ~/.bashrc.backup/$saved_timestamp.bashrc ~/.bashrc; then
    log_error "Failed to revert ~/.bashrc automatically. Please revert manually."
    exit 21
  fi
  log_success "Original ~/.bashrc restored"
  exit 20
fi
log_success "New .bashrc deployed"
pause

# 3.
log_step "Scripts" "Preparing ~/BASHRC directory"
pause
if [[ -d "$bashrc_dir" ]]; then
  log_warn "$bashrc_dir already exists; reusing it and preserving existing files."
  preexisting_bashrc_dir=true
  printf "Continue with installation using existing contents? (y/N): "
  read -t 15 -n 1 -r reuse_ans || reuse_ans="m"
  [[ "$reuse_ans" == "m" ]] && {
    printf "N"
    reuse_ans="N"
  }
  printf "\n"
  if ! [[ $reuse_ans =~ ^[Yy]$ ]]; then
    log_warn "Installation cancelled; existing $bashrc_dir left untouched."
    log_detail "Reverting ~/.bashrc to previous version"
    if ! cp ~/.bashrc.backup/$saved_timestamp.bashrc ~/.bashrc; then
      log_error "Failed to revert ~/.bashrc automatically. Please revert manually."
      exit 32
    fi
    log_success "Original ~/.bashrc restored"
    exit 31
  fi
else
  log_detail "Creating $bashrc_dir directory"
fi
if ! mkdir -p "$bashrc_dir"; then
  log_error "Failed to create $HOME/BASHRC. .bashrc has been replaced, but scripts were not copied."
  log_detail "Reverting ~/.bashrc to previous version"
  if ! cp ~/.bashrc.backup/$saved_timestamp.bashrc ~/.bashrc; then
    log_error "Failed to revert ~/.bashrc automatically. Please revert manually."
    exit 33
  fi
  log_success "Original ~/.bashrc restored"
  exit 30
fi

log_detail "Copying local *.sh scripts to $HOME/BASHRC"
shopt -s nullglob
sh_files=(./*.sh)
if ((${#sh_files[@]} > 0)); then
  copied_targets=()
  for src in "${sh_files[@]}"; do
    copied_targets+=("$bashrc_dir/$(basename "$src")")
  done
  if ! cp "${sh_files[@]}" "$bashrc_dir/"; then
    log_error "Failed to copy shell scripts. .bashrc has been replaced, but scripts were not copied."
    pause
    log_detail "Removing files copied during this install"
    for target in "${copied_targets[@]}"; do
      rm -f "$target" 2>/dev/null || true
    done
    cleanup_bashrc_dir_if_empty
    log_detail "Reverting ~/.bashrc to previous version"
    if ! cp ~/.bashrc.backup/$saved_timestamp.bashrc ~/.bashrc; then
      log_error "Failed to revert ~/.bashrc automatically. Please revert manually."
      exit 41
    fi
    log_success "Original ~/.bashrc restored"
    exit 40
  fi
  log_success "Shell scripts copied to $HOME/BASHRC"
  pause
else
  log_warn "No *.sh scripts found in the repository. Nothing copied."
  pause
fi
shopt -u nullglob

# Create _PREAMBLE.sh if it doesn't exist (user-customizable file)
log_detail "Checking _PREAMBLE.sh configuration"
pause
preamble_file="$bashrc_dir/_PREAMBLE.sh"
if [[ ! -f "$preamble_file" ]]; then
  log_detail "Creating _PREAMBLE.sh template"
  if ! cat <<'PREAMBLE_EOF' > "$preamble_file"; then
#!/usr/bin/env bash

# This script is USER CUSTOMIZABLE and won't be overwritten by updates.

case "${1^^}" in
    "--NON-INTERACTIVE"|"-1")
        # This section runs before the interactive shell is started.
        # It's used to set up the shell environment.

        return 0
        ;;
    "--TAIL"|"-3")
        # This section runs at the very end of the shell startup.
        # It's used to set up the shell environment.

        return 0
        ;;
    "--INTERACTIVE"|"-2"|*)
        # This section runs immediately after the interactive shell is started.
        # It's used to set up the shell environment.

        return 0
        ;;
esac
PREAMBLE_EOF
    log_warn "Failed to create _PREAMBLE.sh. Installation will continue."
  else
    log_success "_PREAMBLE.sh created in $HOME/BASHRC"
  fi
  pause
else
  log_detail "_PREAMBLE.sh already exists, skipping creation"
fi

# Check if starship is enabled and create config if needed
log_detail "Checking starship configuration"
pause
# Default to true, but check settings.json to see if it's explicitly set
enable_starship=true
if [[ -f "$script_dir/settings.json" ]]; then
  if command -v jq >/dev/null 2>&1; then
    # Read from settings.json, defaulting to true if not set
    enable_starship=$(jq -r '.enable_starship // true' "$script_dir/settings.json" 2>/dev/null || echo "true")
  else
    # Fallback: parse JSON manually
    while IFS= read -r line; do
      case "$line" in
        *\"enable_starship\"*)
          [[ "$line" =~ \"enable_starship\"[[:space:]]*:[[:space:]]*(true|false) ]] && enable_starship="${BASH_REMATCH[1]}"
          ;;
      esac
    done < "$script_dir/settings.json"
  fi
fi

if [[ "$enable_starship" == "true" ]]; then
  starship_config="$HOME/.config/starship.toml"
  if [[ ! -f "$starship_config" ]]; then
    log_detail "Creating starship.toml configuration"
    if ! mkdir -p "$HOME/.config" 2>/dev/null; then
      log_warn "Failed to create ~/.config directory. Starship config not created."
    else
      if ! cat <<'STARSHIP_EOF' > "$starship_config"; then
add_newline = true

command_timeout = 200

format = "[$directory$git_branch$git_status]($style)$character"

[character]
error_symbol = "[✗](bold cyan)"
success_symbol = "[❯](bold cyan)"

[directory]
truncation_length = 2
truncation_symbol = "…/"
repo_root_style = "bold cyan"
repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) "

[git_branch]
format = "[$branch]($style) "
style = "italic cyan"

[git_status]
format     = '[$all_status]($style)'
style      = "cyan"
ahead      = "⇡${count} "
diverged   = "⇕⇡${ahead_count}⇣${behind_count} "
behind     = "⇣${count} "
conflicted = " "
up_to_date = " "
untracked  = "? "
modified   = " "
stashed    = ""
staged     = ""
renamed    = ""
deleted    = ""
STARSHIP_EOF
        log_warn "Failed to create starship.toml. Installation will continue."
      else
        log_success "starship.toml created in ~/.config"
      fi
    fi
    pause
  else
    log_detail "starship.toml already exists, skipping creation"
  fi
fi

log_detail "Initializing settings.json in $HOME/BASHRC"
if ! cat <<EOF > "$bashrc_dir/settings.json"; then
{
  "VERSION": "$CURRENT_VERSION",
  "enable_automotd": true,
  "enable_blesh": true,
  "enable_manual": true,
  "enable_shellmommy": true,
  "enable_starship": true,
  "enable_vimkeys": true,
  "enable_wlcopy": true,
  "enable_zoxide": true
}
EOF
  log_error "Failed to create settings.json. .bashrc has been replaced, but settings were not initialized."
  pause
  log_detail "Removing files copied during this install"
  for target in "${copied_targets[@]}"; do
    rm -f "$target" 2>/dev/null || true
  done
  rm -f "$HOME/BASHRC/settings.json" 2>/dev/null || true
  cleanup_bashrc_dir_if_empty
  log_detail "Reverting ~/.bashrc to previous version"
  if ! cp ~/.bashrc.backup/$saved_timestamp.bashrc ~/.bashrc; then
    log_error "Failed to revert ~/.bashrc automatically. Please revert manually."
    exit 51
  fi
  log_success "Original ~/.bashrc restored"
  exit 50
fi
log_success "settings.json created in $HOME/BASHRC"
pause

motd_timestamp="$(date +"%Y-%m-%d %H:%M:%S %Z")"
log_detail "Creating first run message in $HOME/motd.txt"
if ! cat <<EOF > "$HOME/motd.txt"; then
Installation was successful at ${motd_timestamp} !
Version: $CURRENT_VERSION

Type brchelp to show the manual for a specific function.
Type available to list all functions available after sourcing ~/.bashrc.
Type plugins or aliases to list all plugins/aliases loaded into ~/.bashrc.

Type bashrc to edit the ~/.bashrc file.
Type motd print to display the current message of the day.
Type motd make to edit the message of the day.
Type >>> motd shoo <<< to remove the message of the day file.
EOF
  log_warn "Failed to create motd.txt message. Installation otherwise completed."
else
  log_success "motd.txt created in $HOME"
fi
pause

# 4.
log_step "Complete" "Installation finished"
pause
cat <<EOF

Next steps:
  - Open a new shell to load the updated configuration.
  - To revert, run:
        cp ~/.bashrc.backup/$saved_timestamp.bashrc ~/.bashrc
        source ~/.bashrc

EOF
exit 0

