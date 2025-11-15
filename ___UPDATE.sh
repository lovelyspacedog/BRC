#!/bin/bash
# _UPDATE.sh - Update script for BASHRC configuration
# This script compares the installed version with the git repository version
# and offers to update if a newer version is available.

COPYRIGHT=true
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
#   2-9 - Setup/validation errors
#  10-19 - Version check errors
#  20-29 - Download errors
#  30-39 - Backup errors
#  40-49 - Installation errors

set -euo pipefail
IFS=$'\n\t'

GIT_REPO_URL="https://github.com/lovelyspacedog/BRC.git"
GIT_RAW_BASE="https://raw.githubusercontent.com/lovelyspacedog/BRC"
GIT_BRANCH="main"
INSTALLED_SETTINGS="$HOME/BASHRC/settings.json"
INSTALLED_DIR="$HOME/BASHRC"

# Get the install directory (where this git repo was cloned)
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if [[ -z "$script_dir" ]]; then
  log_error "Unable to determine script directory. Update halted."
  exit 2
fi

# Check if we're running from ~/BASHRC (installed location)
if [[ "$script_dir" == "$INSTALLED_DIR" ]]; then
  log_error "Update script cannot be run from ~/BASHRC directory."
  log_detail "This script must be run from the git repository directory."
  log_detail "Please cd to the directory where you cloned the BASHRC repository"
  log_detail "and run this script from there."
  exit 3
fi

# Ensure we're in the install directory
if ! cd "$script_dir"; then
  log_error "Failed to enter install directory at $script_dir."
  exit 4
fi

# Check if this is a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  log_error "Current directory is not a git repository."
  log_detail "This script must be run from the cloned BASHRC repository."
  exit 5
fi

# Source dependency check utility
if [[ -f "$script_dir/_DEPENDENCY_CHECK.sh" ]]; then
  source "$script_dir/_DEPENDENCY_CHECK.sh"
else
  log_error "_DEPENDENCY_CHECK.sh not found. Cannot perform dependency checks."
  exit 6
fi

# Check required commands
if ! ensure_commands_present --caller "_UPDATE.sh" curl jq git date; then
  log_error "Missing required dependencies. Please install: curl, jq, git"
  exit 7
fi

printf "=== BRC Update Check ===\n"
pause

# Get installed version
log_step "Version Check" "Checking installed version"
if [[ ! -f "$INSTALLED_SETTINGS" ]]; then
  log_error "Installed settings.json not found at $INSTALLED_SETTINGS"
  log_detail "It appears BASHRC may not be installed."
  log_detail "Please run ___INSTALL.sh first."
  exit 10
fi

installed_version=$(jq -r '.VERSION // empty' "$INSTALLED_SETTINGS" 2>/dev/null || echo "")
if [[ -z "$installed_version" ]]; then
  log_error "Could not read VERSION from installed settings.json"
  exit 11
fi

log_success "Installed version: $installed_version"

# Get git repository version
log_step "Version Check" "Checking git repository version"
pause

# Determine the branch we're on or default to main
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
if [[ -z "$current_branch" ]]; then
  current_branch="main"
fi

# Try to fetch latest from remote
log_detail "Fetching latest from remote..."
if git fetch origin "$current_branch" >/dev/null 2>&1; then
  log_detail "Remote repository fetched successfully"
else
  log_warn "Could not fetch from remote. Using local git repository."
fi

# Download settings.json from the remote repository
# Try raw GitHub URL first
remote_settings_url="$GIT_RAW_BASE/$current_branch/settings.json"
temp_settings=$(mktemp)
log_detail "Downloading settings.json from repository..."

if curl -sfL "$remote_settings_url" -o "$temp_settings" 2>/dev/null; then
  log_success "Downloaded settings.json from repository"
else
  log_warn "Could not download from raw URL. Trying to use local git checkout..."
  # Fallback: use local git checkout
  if [[ -f "$script_dir/settings.json" ]]; then
    cp "$script_dir/settings.json" "$temp_settings"
    log_success "Using local settings.json"
  else
    log_error "Could not access repository settings.json"
    rm -f "$temp_settings"
    exit 20
  fi
fi

# Extract version from remote settings
remote_version=$(jq -r '.VERSION // empty' "$temp_settings" 2>/dev/null || echo "")
rm -f "$temp_settings"

if [[ -z "$remote_version" ]]; then
  log_error "Could not read VERSION from repository settings.json"
  exit 21
fi

log_success "Repository version: $remote_version"

# Compare versions
# Version format: 0.YYYY.MM.DD
# Parse: major.year.month.day
log_step "Version Comparison" "Comparing versions"
pause

parse_version() {
  local version="$1"
  # Remove leading "0." if present, then split by dots
  local cleaned="${version#0.}"
  IFS='.' read -ra parts <<< "$cleaned"
  if [[ ${#parts[@]} -eq 3 ]]; then
    printf "%s %s %s" "${parts[0]}" "${parts[1]}" "${parts[2]}"
  else
    echo ""
  fi
}

installed_parts=($(parse_version "$installed_version"))
remote_parts=($(parse_version "$remote_version"))

if [[ ${#installed_parts[@]} -ne 3 || ${#remote_parts[@]} -ne 3 ]]; then
  log_error "Invalid version format. Expected format: 0.YYYY.MM.DD"
  log_detail "Installed: $installed_version"
  log_detail "Remote: $remote_version"
  exit 12
fi

installed_year=${installed_parts[0]}
installed_month=${installed_parts[1]}
installed_day=${installed_parts[2]}

remote_year=${remote_parts[0]}
remote_month=${remote_parts[1]}
remote_day=${remote_parts[2]}

# Compare versions (year > month > day)
update_needed=false
if [[ $remote_year -gt $installed_year ]]; then
  update_needed=true
elif [[ $remote_year -eq $installed_year ]]; then
  if [[ $remote_month -gt $installed_month ]]; then
    update_needed=true
  elif [[ $remote_month -eq $installed_month ]]; then
    if [[ $remote_day -gt $installed_day ]]; then
      update_needed=true
    fi
  fi
fi

if [[ "$update_needed" == "true" ]]; then
  printf "\n"
  log_success "Update available!"
  printf "\n"
  printf "  Installed version: %s (%s-%s-%s)\n" "$installed_version" "$installed_year" "$installed_month" "$installed_day"
  printf "  Repository version: %s (%s-%s-%s)\n" "$remote_version" "$remote_year" "$remote_month" "$remote_day"
  printf "\n"
  printf "Would you like to update now? (y/N): "
  read -t 15 -n 1 -r ans || ans="m"
  [[ "$ans" == "m" ]] && {
    printf "N"
    ans="N"
  }
  printf "\n"
  
  if ! [[ $ans =~ ^[Yy]$ ]]; then
    log_warn "Update cancelled by user."
    exit 1
  fi
  
  # Perform update
  log_step "Update" "Starting update process"
  pause
  
  # 1. Backup .bashrc
  log_step "Backup" "Backing up .bashrc"
  pause
  if ! [[ -d ~/.bashrc.backup ]]; then
    log_detail "Creating ~/.bashrc.backup directory"
    if ! mkdir -p ~/.bashrc.backup; then
      log_error "Failed to create ~/.bashrc.backup. Update halted."
      exit 30
    fi
  fi
  
  bashrc_backup_timestamp=""
  backup_file=""
  if [[ -f ~/.bashrc ]]; then
    bashrc_backup_timestamp=$(date +%Y%m%d%H%M%S)
    backup_file="$HOME/.bashrc.backup/${bashrc_backup_timestamp}.bashrc"
    if ! cp ~/.bashrc "$backup_file"; then
      log_error "Failed to backup ~/.bashrc. Update halted."
      exit 31
    fi
    log_success "Backup saved to $backup_file"
  else
    log_warn "~/.bashrc not found. Skipping backup."
  fi
  pause
  
  # 2. Backup ~/BASHRC directory
  log_step "Backup" "Backing up ~/BASHRC directory"
  pause
  backup_dir=""
  if [[ -d "$INSTALLED_DIR" ]]; then
    backup_timestamp=$(date +%Y%m%d%H%M%S)
    backup_dir="$HOME/BASHRC.backup.$backup_timestamp"
    log_detail "Creating backup at $backup_dir"
    if ! cp -r "$INSTALLED_DIR" "$backup_dir"; then
      log_error "Failed to backup ~/BASHRC directory. Update halted."
      exit 32
    fi
    log_success "Backup saved to $backup_dir"
  else
    log_warn "~/BASHRC directory not found. Skipping backup."
  fi
  pause
  
  # 3. Run installer from install directory
  log_step "Installation" "Running installer from repository"
  pause
  if [[ ! -f "$script_dir/___INSTALL.sh" ]]; then
    log_error "Installer script not found at $script_dir/___INSTALL.sh"
    exit 40
  fi
  
  log_detail "Executing ___INSTALL.sh..."
  if bash "$script_dir/___INSTALL.sh"; then
    log_success "Installation completed successfully!"
    printf "\n"
    
    # Check for files in backup that aren't in current installation
    if [[ -d "$backup_dir" ]]; then
      log_step "Backup Check" "Checking for custom files in backup"
      pause
      
      # Get list of files in backup and current installation
      backup_files=()
      current_files=()
      
      # Get all files from backup directory (excluding .git if present)
      while IFS= read -r -d '' file; do
        relative_path="${file#$backup_dir/}"
        backup_files+=("$relative_path")
      done < <(find "$backup_dir" -type f ! -name '.git*' -print0 2>/dev/null || true)
      
      # Get all files from current installation
      if [[ -d "$INSTALLED_DIR" ]]; then
        while IFS= read -r -d '' file; do
          relative_path="${file#$INSTALLED_DIR/}"
          current_files+=("$relative_path")
        done < <(find "$INSTALLED_DIR" -type f ! -name '.git*' -print0 2>/dev/null || true)
      fi
      
      # Find files in backup that aren't in current installation
      missing_files=()
      for backup_file in "${backup_files[@]}"; do
        found=false
        for current_file in "${current_files[@]}"; do
          if [[ "$backup_file" == "$current_file" ]]; then
            found=true
            break
          fi
        done
        if [[ "$found" == "false" ]]; then
          missing_files+=("$backup_file")
        fi
      done
      
      if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_warn "Found ${#missing_files[@]} file(s) in backup that aren't in current installation:"
        for file in "${missing_files[@]}"; do
          log_detail "$backup_dir/$file"
        done
        printf "\n"
        log_detail "Please check the backup directory and port over any custom scripts you need:"
        log_detail "  $backup_dir"
        printf "\n"
      else
        log_success "No additional files found in backup directory"
        pause
      fi
    fi
    
    printf "Next steps:\n"
    printf "  - Open a new shell to load the updated configuration.\n"
    if [[ -d "$backup_dir" ]]; then
      printf "  - Check the backup directory for any custom scripts to port over:\n"
      printf "        %s\n" "$backup_dir"
    fi
    printf "  - If you need to revert, use the backups:\n"
    if [[ -n "$bashrc_backup_timestamp" ]]; then
      printf "        cp ~/.bashrc.backup/%s.bashrc ~/.bashrc\n" "$bashrc_backup_timestamp"
    fi
    if [[ -n "$backup_dir" ]]; then
      printf "        rm -rf ~/BASHRC && mv %s ~/BASHRC\n" "$backup_dir"
    fi
    printf "\n"
    exit 0
  else
    log_error "Installation failed."
    log_detail "Your backups are available at:"
    if [[ -f "$backup_file" ]]; then
      log_detail "  .bashrc: $backup_file"
    fi
    if [[ -d "$backup_dir" ]]; then
      log_detail "  BASHRC: $backup_dir"
    fi
    exit 41
  fi
  
else
  printf "\n"
  log_success "You are already running the latest version!"
  printf "  Installed: %s\n" "$installed_version"
  printf "  Repository: %s\n" "$remote_version"
  printf "\n"
  exit 0
fi

