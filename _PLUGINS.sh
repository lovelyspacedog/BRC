#!/usr/bin/env bash

readonly __PLUGINS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__PLUGINS_DIR/_DEPENDENCY_CHECK.sh"

declare -a plugins=(
    "_BASE_FUNCTIONS.sh"   # Basic/Core helper functions
    "analyze-file.sh"      # Inspect file contents and metadata quickly
    "bashrc.sh"            # Load primary bash configuration helpers
    "cmd-not-found.sh"     # Command-not-found handler with yay/flatpak search
    "dl-paper.sh"          # Download wallpapers from YouTube
    "dots.sh"              # Manage dotfile shortcuts and navigation
    "extract-compress.sh"  # Extract and compress files
    "fastnote.sh"          # Append quick notes to the fastnote scratchpad
    "motd.sh"              # Show message-of-the-day style summaries
    "navto.sh"             # Jump to bookmarked filesystem locations
    "open.sh"              # Open a file with the default application
    "pokefetch.sh"         # Fetch random Pokémon data from the API
    "prepsh.sh"            # Prepare shell session with common setup
    "slashback.sh"         # Restore previous directories using slash shortcuts
    "weather.sh"           # Display current weather information
    "timer.sh"             # Set and monitor simple named timers
    "available.sh"         # List available plugins and their status
)

for plugin in "${plugins[@]}"; do
    if [[ -f "$__PLUGINS_DIR/$plugin" ]]; then
        source "$__PLUGINS_DIR/$plugin"
    else
        echo "Warning: $plugin not found" >&2
    fi
done

# Display loaded plugins when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Loaded plugins:"
    for plugin in "${plugins[@]}"; do
        echo "  $plugin"
    done
fi