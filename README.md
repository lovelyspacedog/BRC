# BASHRC - Enhanced Bash Configuration

A comprehensive, modular bash configuration system with plugins, functions, aliases, and integrations for modern shell workflows.
This readme was Cursor generated. Take it with a grain of salt, lol.

**Made by Tony Pup (c) 2025. All rights reserved. Rarf~~! <3**

## Features

### 🚀 Core Features

- **Modular Architecture**: Organized into plugins, functions, and aliases
- **Easy Installation**: Automated installer with backup and rollback support
- **Configurable**: JSON-based settings for enabling/disabling features
- **Safe Updates**: Automated update script with version checking and automatic backups
- **Built-in Manual**: Comprehensive help system with `brchelp` command

### 🎨 Shell Enhancements

- **Starship Prompt**: Beautiful, fast, and customizable prompt (auto-configured)
- **Ble.sh Integration**: Enhanced line editor with syntax highlighting
- **Vim Keybindings**: Optional vi-mode for command-line editing
- **Zoxide**: Smart directory jumping with `z` and `zi` commands
- **Shell Mommy**: Encouraging messages after commands (optional)

### 📦 Included Plugins & Functions

#### Core Functions
- `backup()` / `backup_all()` - Create timestamped backups
- `calc()` - Quick calculator using `bc`
- `cpuinfo()` - Display CPU information
- `genpassword()` - Generate secure passwords
- `h()` - Enhanced history search
- `mkcd()` - Create directory and cd into it
- `n()` - Quick note-taking
- `update()` - System update helper
- `woof()` - Desktop notifications
- `xx()` - Open files in new terminal window

#### File Management
- `analyze-file` - Inspect file contents and metadata
- `extract()` - Universal archive extractor (tar, zip, rar, 7z, etc.)
- `compress()` - Create compressed archives
- `open` - Open files with default application
- `dots` - Manage dotfile shortcuts and navigation

#### Navigation & Bookmarks
- `navto` - Jump to bookmarked filesystem locations
- `slashback` - Restore previous directories using slash shortcuts
- `cdd` - Quick directory navigation

#### Utilities
- `weather` - Display current weather information
- `pokefetch` - Fetch random Pokémon data
- `timer` - Set and monitor simple named timers
- `fastnote` - Quick note-taking to scratchpad
- `motd` - Message-of-the-day display
- `dl-paper` - Download wallpapers from YouTube
- `cmd-not-found` - Enhanced command-not-found handler

#### Configuration
- `bashrc` - Edit `.bashrc` file
- `available` - List all available functions and plugins
- `plugins` - List loaded plugins
- `aliases` - List all aliases

## Installation

### Prerequisites

- Bash 4.0 or higher
- Basic Unix utilities (cp, mkdir, rm, etc.)
- Optional: `jq` for JSON parsing (fallback parser included)

### Quick Install

1. Clone or download this repository:
   ```bash
   git clone https://github.com/lovelyspacedog/BRC.git BRC
   cd BRC
   ```

2. Run the installer:
   ```bash
   ./___INSTALL.sh
   ```

3. Follow the prompts. The installer will:
   - Check dependencies
   - Create a timestamped backup of your existing `.bashrc`
   - Deploy the new configuration
   - Copy all scripts to `~/BASHRC`
   - Create `settings.json` for configuration
   - Optionally create `starship.toml` if starship is enabled

4. Open a new shell or run:
   ```bash
   source ~/.bashrc
   ```

### What Gets Installed

- `~/.bashrc` - Main bash configuration (backed up first)
- `~/BASHRC/` - Directory containing all scripts and plugins
- `~/BASHRC/settings.json` - Configuration file
- `~/.config/starship.toml` - Starship prompt config (if enabled)

## Updating

### Automatic Update

The project includes an automated update script that compares your installed version with the repository version and offers to update if a newer version is available.

**Important**: The update script must be run from the git repository directory (where you cloned the repo), **not** from `~/BASHRC`.

1. Navigate to your cloned repository directory:
   ```bash
   cd /path/to/BRC
   ```

2. Run the update script:
   ```bash
   ./___UPDATE.sh
   ```

3. The script will:
   - Check your installed version from `~/BASHRC/settings.json`
   - Compare it with the repository version
   - If an update is available, prompt for confirmation
   - Create timestamped backups of `~/.bashrc` and `~/BASHRC`
   - Run the installer to update your installation
   - Compare backup files with the new installation to identify custom scripts you may need to port over

4. After updating, check the backup directory for any custom files:
   ```bash
   ls ~/BASHRC.backup.*
   ```
   Port over any custom scripts you had in your old installation.

### Manual Update

If you prefer to update manually, simply run the installer again:
```bash
cd /path/to/BRC
./___INSTALL.sh
```

This will create new backups and update your installation.

## Configuration

### Settings File

Edit `~/BASHRC/settings.json` to enable/disable features:

```json
{
  "enable_automotd": true,
  "enable_blesh": true,
  "enable_manual": true,
  "enable_shellmommy": true,
  "enable_starship": true,
  "enable_vimkeys": true,
  "enable_wlcopy": true,
  "enable_zoxide": true
}
```

### Customization

**Important**: The main `.bashrc` file will be overwritten on updates. For customizations:

1. **Use `_PREAMBLE.sh`**: Edit `~/BASHRC/_PREAMBLE.sh` for user-specific configurations that won't be overwritten
2. **Modify plugins**: Edit individual plugin files in `~/BASHRC/`
3. **Add aliases**: Edit `~/BASHRC/_ALIASES.sh`

## Usage

### Getting Help

- `brchelp <function>` - Show manual for a specific function
- `available` - List all available functions and plugins
- `plugins` - List loaded plugins
- `aliases` - List all aliases

### Common Commands

```bash
# Navigation
z <directory>        # Jump to frequently used directory
zi                   # Interactive directory picker
navto <bookmark>     # Jump to bookmarked location

# File Operations
analyze <file>       # Analyze file contents
extract <archive>    # Extract any archive format
open <file>          # Open with default app

# Utilities
weather              # Show weather
timer <name> <sec>   # Set a timer
pokefetch            # Show random Pokémon
motd print           # Show message of the day

# System
update               # System update helper
cpuinfo              # CPU information
backup <file>        # Backup a file
```

## Optional Dependencies

The following are optional but enhance functionality:

- **starship** - Prompt customization
- **blesh** - Enhanced line editor (`~/.local/share/blesh/ble.sh`)
- **zoxide** - Smart directory jumping
- **shell-mommy** - Encouraging messages (`~/shell-mommy/shell-mommy.sh`)
- **jq** - JSON parsing (has fallback)
- **fortune** - For automotd feature
- **curl** - For weather functions
- **pokemon-colorscripts** & **fastfetch** - For pokefetch
- **yt-dlp** & **ffmpeg** - For dl-paper
- **eza** - Enhanced ls (falls back to ls)

The installer will check for these and warn about missing optional dependencies.

## Project Structure

```
BASHRC/
├── ___INSTALL.sh          # Main installer script
├── ___UPDATE.sh           # Automated update script
├── .bashrc.copyToHome     # Template .bashrc file
├── settings.json          # Default settings
├── _PREAMBLE.sh           # User customization file (safe to edit)
├── _PLUGINS.sh            # Plugin loader
├── _ALIASES.sh            # Alias definitions
├── _BASE_FUNCTIONS.sh     # Core helper functions
├── _DEPENDENCY_CHECK.sh   # Dependency checking utilities
├── _manual.sh             # Manual/help system
├── _manual_base.sh        # Manual base content
├── *.sh                   # Individual plugin scripts
└── README.md              # This file
```

## Reverting Changes

If you need to revert to your previous `.bashrc`:

```bash
# List available backups
ls ~/.bashrc.backup/

# Restore a specific backup
cp ~/.bashrc.backup/TIMESTAMP.bashrc ~/.bashrc
source ~/.bashrc
```

The installer creates timestamped backups in `~/.bashrc.backup/` before making any changes.

## Troubleshooting

### Installation Issues

- **Permission denied**: Make sure `___INSTALL.sh` is executable: `chmod +x ___INSTALL.sh`
- **Dependency errors**: Install missing required dependencies (bash, coreutils, etc.)
- **Backup failed**: Check write permissions in your home directory

### Runtime Issues

- **Function not found**: Run `available` to see if the plugin is loaded
- **Starship not working**: Check if starship is installed: `command -v starship`
- **Plugin errors**: Check `~/BASHRC/` directory exists and contains the plugin files

### Getting Help

- Use `brchelp <function>` for function-specific help
- Check `~/BASHRC/` for plugin source files
- Review `settings.json` to ensure features are enabled

## Contributing

This is a personal configuration project, but suggestions and improvements are welcome!

## License

Made by Tony Pup (c) 2025. All rights reserved.

---

**Rarf~~! <3**

