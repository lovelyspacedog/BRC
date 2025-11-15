#!/usr/bin/env bash

brchelp() {
    if ! ensure_commands_present --caller "brchelp" cat; then
        return 123
    fi
    
    # If a function name is provided, show its help
    if [[ -n "$1" ]]; then
        case "$1" in
            analyze-file|analyze_file)
                cat <<EOF
analyze-file - File Analysis Tool

Usage: analyze-file <file>

Provide detailed file analysis and information

Description:
  - Analyzes files and provides comprehensive information
  - Shows file size, permissions, ownership, and type
  - Displays line count, word count, and character count for text files
  - Generates SHA256 hash for security verification
  - Works with any file type
  - Provides human-readable output with formatting

Dependencies:
  - file (file type detection)
  - stat (file statistics)
  - du (disk usage)
  - wc (word count)
  - sha256sum (hash generation)

Examples:
  analyze-file document.txt
  analyze-file script.sh
  analyze-file image.jpg

Note: Provides different analysis based on file type
EOF
                return 0
                ;;
            automotd)
                cat <<EOF
automotd - Automatic Message of the Day

Automatically generates a daily message of the day (MOTD) with a fortune.

Description:
  - Runs automatically when bashrc is sourced (if enabled)
  - Creates a daily fortune message in \$HOME/motd.txt
  - Only updates once per day (checks timestamp in \$HOME/motd.time)
  - Displays the fortune when a new shell session starts
  - Can be dismissed with "motd shoo"

How it works:
  - Checks if 24 hours have passed since last update
  - If yes, generates a new fortune and saves it to \$HOME/motd.txt
  - Only creates motd.txt if it doesn't already exist (won't override existing file)
  - The motd.txt file is displayed by the motd command

Dependencies:
  - fortune (fortune cookie generator)
  - jq (JSON processor)

Files created:
  - \$HOME/motd.time - Timestamp of last update
  - \$HOME/motd.txt - The daily fortune message

Note: This script runs automatically and is not called directly by users.
      It's controlled by the enable_automotd setting in settings.json.
EOF
                return 0
                ;;
            available)
                cat <<EOF
available - List Available Bash Functions

Lists all bash functions currently defined in the shell.

Usage: available [OPTIONS]

Description:
  - Displays all functions available after sourcing ~/.bashrc
  - Shows functions in a formatted 3-column table
  - Filters out functions starting with underscore by default
  - Can be run as a function or as a standalone script

Options:
  --all, -a        Show all functions (including those starting with underscore)
  --hold, -h       Same as --all (show all functions)
  --help           Show this help message and exit

Behavior:
  - When run as a function: lists functions in current shell session
  - When run as a script: sources ~/.bashrc in a subshell first, then lists functions
  - Functions are sorted alphabetically
  - Long function names are truncated with "..." if they exceed 27 characters

Examples:
  available
  available --all
  available -a
  available --help

Note: By default, functions starting with underscore are filtered out to reduce
      clutter from internal/private functions.
EOF
                return 0
                ;;
            bashrc)
                cat <<EOF
bashrc - Edit .bashrc or View Aliases

Quick access to edit your .bashrc file or view aliases.

Usage: bashrc [ALIAS]

Description:
  - Opens ~/.bashrc in nvim for editing (default behavior)
  - Can display all aliases when called with "ALIAS" argument
  - Provides a convenient shortcut for common bashrc operations

Options:
  ALIAS            Display all aliases from _ALIASES.sh file
                  (case-insensitive, e.g., "alias", "ALIAS", "Alias")

Behavior:
  - Without arguments: opens ~/.bashrc in nvim editor
  - With "ALIAS" argument: displays contents of _ALIASES.sh file
  - Can be run as a function or as a standalone script

Dependencies:
  - nvim (for editing .bashrc)
  - cat (for displaying aliases)

Examples:
  bashrc              # Open ~/.bashrc in nvim
  bashrc alias        # Display all aliases
  bashrc ALIAS        # Display all aliases (case-insensitive)

Note: The ALIAS argument is case-insensitive and will display the contents
      of the _ALIASES.sh file from the BASHRC directory.
EOF
                return 0
                ;;
            cmd-not-found|cmd_not_found|command-not-found|cmd)
                cat <<EOF
cmd-not-found - Automatic Command Not Found Handler

Automatically searches for missing commands in package managers and offers to install them.

Usage: Automatically called by bash when a command is not found

Description:
  - Bash automatically calls this function when a command cannot be found
  - Searches for packages containing the missing command in yay (AUR + official repos)
  - Searches for applications in flatpak
  - Provides interactive installation prompts
  - Prioritizes official packages over AUR packages
  - Limits results to prevent overwhelming output

How It Works:
  - When you type a command that doesn't exist, bash automatically calls command_not_found_handle()
  - The function searches yay and flatpak for packages that might contain the command
  - Displays numbered list of found packages with source indicators
  - Prompts you to select a package for installation
  - Installs the selected package automatically

Features:
  - Smart package extraction: Handles yay's OSC 8 hyperlink escape sequences
  - Multiple extraction methods: Uses grep -P, perl, or basic regex for compatibility
  - Package prioritization: Official packages shown before AUR packages
  - Result limiting: Maximum 10 results per source (yay/flatpak)
  - Interactive installation: Prompts for confirmation before installing
  - Non-interactive safety: Only runs in interactive shells (has TTY)

Search Behavior:
  - Yay search: Searches both exact matches and broader patterns
    - Official packages (e.g., "core/package") prioritized over AUR
    - AUR packages (e.g., "aur/package") shown after official packages
  - Flatpak search: Searches application IDs and names
    - Extracts valid app IDs (e.g., "org.example.App")
    - Limits to 10 results

Installation:
  - Yay packages: Uses "yay -S --noconfirm" (requires sudo)
  - Flatpak packages: Uses "flatpak install --assumeyes --noninteractive"
    - Tries direct installation first
    - Falls back to flathub remote if needed

Dependencies:
  - yay (optional, for AUR and official repo search)
  - flatpak (optional, for flatpak application search)
  - grep, perl (for package name extraction)
  - sudo (for yay installation)

Examples:
  $ nonexistent-command
  # Automatically searches and shows:
  # 🔍 Searching yay (AUR + official)...
  #    Found 3 package(s) in yay:
  #     1) core/package-name
  #     2) aur/package-name
  #     3) extra/another-package
  # 
  # 🔍 Searching flatpak...
  #    Found 1 package(s) in flatpak:
  #     1) org.example.App
  # 
  # Would you like to install one of these packages? [y/N]:
  # [User selects package and it gets installed]

Behavior:
  - Only runs in interactive shells (checks for TTY)
  - Non-interactive shells get standard "command not found" error
  - 10-second timeout for initial installation prompt
  - Returns exit code 127 (command not found) if:
    - No packages found
    - User declines installation
    - Installation fails
    - Invalid choice entered

Note: This function is automatically called by bash when a command is not found.
      You don't call it directly - it runs automatically. The function name
      "command_not_found_handle" is special and recognized by bash. Once
      cmd-not-found.sh is sourced (via _PLUGINS.sh), this handler becomes
      active. The function searches package managers intelligently, handling
      terminal escape sequences and prioritizing official packages over AUR.
EOF
                return 0
                ;;
            dots)
                cat <<EOF
dots - Manage and Navigate .config Directories

Quick access to list and navigate directories in ~/.config.

Usage: dots <command> [directory]

Description:
  - Lists all directories in ~/.config
  - Navigates to specific .config subdirectories
  - Lists contents of .config subdirectories
  - Provides convenient shortcuts for dotfile management

Commands:
  ls [dir]         List all .config directories, or contents of a specific directory
  <dir>            Navigate to a .config subdirectory and list its contents
  help             Show help message

Behavior:
  - Without arguments: shows usage help
  - "dots ls": lists all directories in ~/.config
  - "dots ls <dir>": lists contents of ~/.config/<dir>
  - "dots <dir>": changes to ~/.config/<dir> and lists its contents
  - Uses eza if available, otherwise falls back to ls

Dependencies:
  - find, sort, xargs, ls (for listing)
  - eza (optional, for enhanced listing with icons)

Examples:
  dots ls                    # List all .config directories
  dots ls hypr              # List contents of ~/.config/hypr
  dots hypr                 # Navigate to ~/.config/hypr and list contents
  dots waybar               # Navigate to ~/.config/waybar and list contents
  dots help                 # Show help message

Note: All operations work within ~/.config/ directory. The function will
      change your current directory when navigating to a subdirectory.
EOF
                return 0
                ;;
            dl-paper)
                cat <<EOF
dl-paper - Download Wallpaper Clips with yt-dlp

List available formats or download video clips for use as wallpapers.

Usage: dl-paper <url>
       dl-paper DOWN|D|- <format> <url>

Description:
  - Lists available video formats for a URL
  - Downloads a 4-minute clip (60-300 seconds) from a video
  - Uses ffmpeg to extract the clip segment
  - Designed for downloading wallpaper clips from video sources
  - Provides format listing to help choose the right quality

Modes:
  List formats:  dl-paper <url>
                 Shows all available formats for the video URL
  
  Download:      dl-paper DOWN <format> <url>
                 dl-paper D <format> <url>
                 dl-paper - <format> <url>
                 Downloads a 4-minute clip (60-300 seconds) using the specified format

Behavior:
  - Without DOWN/D/-: lists all available formats for the URL
  - With DOWN/D/-: downloads a clip from seconds 60-300 (4 minutes)
  - Download mode requires format code and URL
  - Format codes can be found using the list mode
  - Uses ffmpeg as the downloader for clip extraction
  - Commands are case-insensitive (DOWN, D, or -)

Dependencies:
  - yt-dlp (for video downloading and format listing)
  - ffmpeg (required for download mode, for clip extraction)

Examples:
  dl-paper https://youtube.com/watch?v=VIDEO_ID
           # List available formats
  
  dl-paper DOWN 22 https://youtube.com/watch?v=VIDEO_ID
           # Download format 22 as a 4-minute clip
  
  dl-paper d 18 https://youtube.com/watch?v=VIDEO_ID
           # Download format 18 (case-insensitive)
  
  dl-paper - best https://youtube.com/watch?v=VIDEO_ID
           # Download best quality format

Note: The download mode extracts a 4-minute segment (60-300 seconds) from the
      video, which is ideal for wallpaper loops. Use the list mode first to
      find the format code you want. Format codes are typically numbers or
      special codes like "best" or "worst".
EOF
                return 0
                ;;
            extract)
                cat <<EOF
extract - Extract Archives

Extract various archive formats based on file extension.

Usage: extract <archive-file>

Description:
  - Automatically detects archive type from file extension
  - Extracts archives to the current directory
  - Supports multiple archive formats
  - Uses appropriate extraction tool for each format
  - Works with files in the current directory

Supported Formats:
  - .tar.bz2  - tar archive compressed with bzip2
  - .tar.gz   - tar archive compressed with gzip
  - .bz2      - bzip2 compressed file
  - .rar      - RAR archive
  - .gz       - gzip compressed file
  - .tar      - tar archive (uncompressed)
  - .tbz2     - tar archive compressed with bzip2
  - .tgz      - tar archive compressed with gzip
  - .zip      - ZIP archive
  - .Z        - compress compressed file
  - .7z       - 7-Zip archive

Behavior:
  - File must exist and be a regular file
  - Automatically selects extraction method based on file extension
  - Extracts contents to the current directory
  - Returns error if file doesn't exist or is not a file
  - Returns error if archive format is not supported

Dependencies:
  - tar (for .tar, .tar.bz2, .tar.gz, .tbz2, .tgz files)
  - bunzip2 (for .bz2 files)
  - unrar (for .rar files)
  - gunzip (for .gz files)
  - unzip (for .zip files)
  - uncompress (for .Z files)
  - 7z (for .7z files)

Examples:
  extract archive.tar.gz      # Extract tar.gz archive
  extract file.zip            # Extract ZIP archive
  extract data.tar.bz2        # Extract tar.bz2 archive
  extract archive.7z          # Extract 7-Zip archive

Note: The function automatically detects the archive type from the file extension
      and uses the appropriate extraction tool. Unsupported formats will
      display an error message. See also compress() for creating archives.
EOF
                return 0
                ;;
            compress)
                cat <<EOF
compress - Create Archives

Create archives from files or directories in various formats.

Usage: compress <file|directory> [format]

Description:
  - Creates archives from files or directories
  - Supports multiple archive formats
  - Automatically determines default format based on input type
  - Uses appropriate compression tool for each format
  - Preserves original files (uses -k flag for gzip/bzip2)

Supported Formats:
  - tar.bz2, tbz2  - tar archive compressed with bzip2
  - tar.gz, tgz    - tar archive compressed with gzip
  - bz2            - bzip2 compressed file
  - rar            - RAR archive
  - gz             - gzip compressed file
  - tar            - tar archive (uncompressed)
  - zip            - ZIP archive
  - Z              - compress compressed file
  - 7z             - 7-Zip archive

Default Behavior:
  - Files: defaults to gz format (creates file.gz)
  - Directories: defaults to tar.gz format (creates directory.tar.gz)

Behavior:
  - Requires file or directory as first argument
  - Optional format as second argument
  - Checks if input exists before creating archive
  - Prevents overwriting existing output files
  - Preserves original files (keeps original with -k flag)
  - Returns error if input doesn't exist
  - Returns error if output file already exists
  - Returns error if format is not supported

Dependencies:
  - tar (for .tar, .tar.bz2, .tar.gz, .tbz2, .tgz files)
  - bzip2 (for .bz2 files)
  - rar (for .rar files)
  - gzip (for .gz files)
  - zip (for .zip files)
  - compress (for .Z files)
  - 7z (for .7z files)

Examples:
  compress file.txt           # Creates file.txt.gz (default for files)
  compress directory/         # Creates directory.tar.gz (default for directories)
  compress file.txt zip       # Creates file.txt.zip
  compress dir/ tar.bz2       # Creates dir.tar.bz2
  compress data.txt 7z        # Creates data.txt.7z

Note: This function is the opposite of extract(). It creates archives from
      files or directories. The original files are preserved (not deleted).
      Default format is gz for files and tar.gz for directories. Use the
      second argument to specify a different format.
EOF
                return 0
                ;;
            generate-man-pages|generate_man_pages)
                cat <<EOF
generate-man-pages - Generate Man Pages from Manual Files

Generates man pages (groff/troff format) from help text in _manual.sh and _manual_base.sh.

Usage: ./generate-man-pages.sh

Description:
  - Extracts help text from _manual.sh and _manual_base.sh
  - Converts help text to standard man page format (groff/troff)
  - Generates individual .1 man pages for each command
  - Creates a central index man page (BRC.1) linking all commands
  - Organizes commands into categories (Main Commands, Base Functions, Configuration)
  - Removes duplicate entries (handles command aliases intelligently)

Behavior:
  - Scans _manual.sh for all case statement entries with help text
  - Scans _manual_base.sh for base function help text
  - Extracts help text from heredoc blocks (cat <<EOF)
  - Selects primary command name when multiple aliases exist
  - Generates man pages in man/man1/ directory
  - Creates BRC.1 index page with links to all commands
  - Outputs progress messages during generation

Output:
  - Individual man pages: man/man1/<command>.1
  - Central index: man/man1/BRC.1
  - All man pages include proper groff formatting
  - Sections: NAME, SYNOPSIS, DESCRIPTION, OPTIONS, EXAMPLES, etc.

Command Selection:
  - When multiple aliases exist (e.g., analyze-file|analyze_file), selects one primary name
  - Preference order:
    1. Lowercase names without leading underscores
    2. Lowercase names over uppercase
    3. First valid name if no preference applies
  - Prevents duplicate man pages for the same help content

Dependencies:
  - bash (for script execution)
  - Standard Unix utilities (grep, sed, awk, sort)
  - groff (optional, for viewing man pages)

Files Created:
  - man/man1/*.1 - Individual command man pages
  - man/man1/BRC.1 - Central index man page

Examples:
  ./generate-man-pages.sh              # Generate all man pages
  man -l man/man1/timer.1              # View a specific man page
  man -l man/man1/BRC.1             # View the central index
  groff -man -Tascii man/man1/timer.1 | less  # View formatted man page

Installation:
  To install man pages system-wide:
    sudo cp -r man/man1/* /usr/local/share/man/man1/
    sudo mandb
  
  After installation, view with:
    man <command>

Note: This script should be run from the BASHRC directory. It automatically
      creates the man/man1/ directory if it doesn't exist. The generated man
      pages follow standard Unix man page conventions and can be viewed with
      the man command or groff. The central BRC.1 index page provides a
      convenient overview of all available commands.
EOF
                return 0
                ;;
            fastnote)
                cat <<EOF
fastnote - Quick Note Management

Manage quick scratchpad notes stored in numbered files.

Usage: fastnote [NUMBER] [ACTION]
       fastnote list

Description:
  - Creates and manages quick notes in ~/.fastnotes/ directory
  - Notes are stored as numbered files (notes_0.txt, notes_1.txt, etc.)
  - Opens notes in your default editor for quick editing
  - Provides a simple scratchpad system for temporary notes

Commands:
  list            List all available notes
  <number>        Open/edit a note by number (default action)
  <number> delete Delete a note by number
  <number> open   Open/edit a note by number (explicit)

Behavior:
  - Without arguments: opens note 0 (creates if it doesn't exist)
  - "fastnote list": lists all available notes
  - "fastnote <n>": opens note number n in editor (creates if needed)
  - "fastnote <n> delete": deletes note number n
  - Creates ~/.fastnotes directory automatically if it doesn't exist
  - Uses \$EDITOR environment variable (defaults to nvim)

Dependencies:
  - mkdir (for creating directory)
  - touch (for creating note files)
  - basename, sed (for listing notes)
  - rm (for deleting notes)
  - Editor specified in \$EDITOR (default: nvim)

Files:
  - ~/.fastnotes/notes_*.txt - Note files (numbered)

Examples:
  fastnote              # Open note 0
  fastnote 1            # Open note 1
  fastnote list         # List all notes
  fastnote 2 delete     # Delete note 2
  fastnote 5 open       # Explicitly open note 5

Note: Note numbers must be positive integers or zero. The function will
      create note files automatically if they don't exist when opened.
EOF
                return 0
                ;;
            motd)
                cat <<EOF
motd - Message of the Day

Display, create, or manage your daily message.

Usage: motd [COMMAND]

Description:
  - Displays the message of the day from ~/motd.txt
  - Allows you to create or edit the message of the day
  - Can remove the message of the day file
  - Provides a simple way to show daily messages when starting shell sessions

Commands:
  (no args)      Show help message
  print          Display the current message of the day
  make           Create or edit the message of the day file in editor
  shoo           Remove the message of the day file

Behavior:
  - Without arguments: shows help message
  - "motd print": displays ~/motd.txt if it exists (with a 1 second pause)
  - "motd make": opens ~/motd.txt in editor (creates if it doesn't exist)
  - "motd shoo": deletes ~/motd.txt file
  - Commands are case-insensitive

Dependencies:
  - cat (for displaying message)
  - rm (for removing file)
  - Editor specified in \$EDITOR (default: nvim)

Files:
  - ~/motd.txt - The message of the day file

Examples:
  motd              # Show help message
  motd print        # Display current message
  motd make         # Edit/create message in nvim
  motd shoo         # Delete message file

Note: This works in conjunction with automotd.sh, which can automatically
      generate daily fortunes. The motd.txt file can also be manually created
      or edited. The "print" command is typically called automatically when
      starting a new shell session.
EOF
                return 0
                ;;
            navto)
                cat <<EOF
navto - Quick Navigation to Common Directories

Navigate to common directories using short aliases.

Usage: navto <destination>

Description:
  - Provides quick shortcuts to navigate to common directories
  - Changes directory and lists contents after navigation
  - Supports multiple aliases for the same destination
  - Commands are case-insensitive

Available Destinations:
  X, HOME          - Home directory
  P, PICS, PICTURES - Pictures directory
  V, VID, VIDEOS   - Videos directory
  M, MUSIC         - Music directory
  D, DOCS, DOCUMENTS - Documents directory
  L, DOWN, DOWNLOADS - Downloads directory
  W, WALL, WALLPAPERS - Wallpapers directory
  ., CONFIG, CFG   - .config directory
  H, HYPR, HYPRLAND - Hyprland config directory
  S, SCRIPTS, HYPRSCRIPTS - Hyprland scripts directory
  WB, WAYBAR       - Waybar config directory
  U, USR, SYSTEM   - System applications (/usr/share/applications)
  U2, USER, LOCAL  - User applications (~/.local/share/applications)
  U3, LOCAL        - Local applications (/usr/local/share/applications)
  B, SSH, EXPEDITION - SSH to expedition server
  C, CODE, PROJECTS - Code/Projects directory
  T, TEMPLATES     - Templates directory
  R, RECENT        - Recent downloads (shows last 5 files)

Behavior:
  - Changes to the specified directory
  - Displays current directory path
  - Lists directory contents (uses eza if available, otherwise ls)
  - Special case: "R" shows recent downloads without changing directory
  - Special case: "B" initiates SSH connection instead of changing directory
  - Commands are case-insensitive

Dependencies:
  - cd, pwd, ls (for navigation and listing)
  - eza (optional, for enhanced listing with icons)
  - ssh (for SSH connection)
  - head (for recent downloads)

Examples:
  navto X           # Navigate to home directory
  navto pics        # Navigate to Pictures (case-insensitive)
  navto .           # Navigate to .config
  navto hypr        # Navigate to Hyprland config
  navto recent      # Show recent downloads
  navto ssh         # SSH to expedition server

Note: All destination aliases are case-insensitive. The function will list
      directory contents after successful navigation. Some destinations have
      fallback paths (e.g., Code/Projects tries multiple locations).
EOF
                return 0
                ;;
            open)
                cat <<EOF
open - Smart File and URL Opener

Open files, URLs, and applications with intelligent terminal detection.

Usage: open <file|url>

Description:
  - Wrapper around xdg-open with smart terminal application detection
  - Automatically detects terminal applications (scripts, executables)
  - Opens terminal applications in a new kitty window to ensure output is visible
  - Uses xdg-open for regular files, URLs, and non-terminal applications
  - Provides a unified interface for opening various file types

Behavior:
  - Without arguments: returns silently (no error)
  - For local files: checks if file exists
  - For terminal applications: opens in new kitty window
    - Detects executables (files with execute permission)
    - Detects scripts by extension (.sh, .bash, .zsh, .fish, .py, .pl, .rb, .js, .ts)
  - For other files/URLs: uses xdg-open (system default handler)
  - All operations run in background (non-blocking)

Terminal Application Detection:
  - Files with execute permission (-x)
  - Script files with recognized extensions:
    - Shell scripts: .sh, .bash, .zsh, .fish
    - Scripting languages: .py, .pl, .rb, .js, .ts
  - Terminal applications are executed in a new kitty window
  - Ensures output is visible and not hidden in current terminal

Dependencies:
  - xdg-open (for opening files/URLs with system default handlers)
  - kitty (for opening terminal applications in new window)

Examples:
  open document.pdf           # Opens PDF with default PDF viewer
  open https://example.com    # Opens URL in default browser
  open script.sh              # Opens script in new kitty window
  open ./executable           # Opens executable in new kitty window
  open image.jpg              # Opens image with default image viewer
  open main.py                # Opens Python script in new kitty window

Note: This function intelligently routes terminal applications to kitty windows
      while using the system's default handlers for other file types. Terminal
      applications are detected by execute permission or script file extensions.
      All operations are non-blocking and run in the background.
EOF
                return 0
                ;;
            pokefetch)
                cat <<EOF
pokefetch - Pokemon-themed System Information Display

Display system information with a random Pokemon ASCII art logo.

Usage: pokefetch

Description:
  - Displays system information using fastfetch
  - Uses a random Pokemon (generations 1-4) as ASCII art logo
  - Shows a fun battle message with the Pokemon name
  - Provides an entertaining way to view system stats

Behavior:
  - Generates a random Pokemon from generations 1-4
  - Extracts Pokemon ASCII art using pokemon-colorscripts
  - Displays system information with Pokemon as logo (5 lines tall)
  - Shows "[Pokemon Name] Joins The Battle!" message
  - Uses temporary files in /tmp/ for processing

Dependencies:
  - pokemon-colorscripts (for Pokemon ASCII art)
  - fastfetch (for system information display)
  - head, sed, mv (for text processing)

Files:
  - /tmp/pokefetch.txt - Temporary file for Pokemon ASCII art

Examples:
  pokefetch              # Display system info with random Pokemon

Note: This function is typically called automatically when starting a new shell
      session (if enabled in .bashrc). The Pokemon is randomly selected from
      generations 1-4 each time the function is called.
EOF
                return 0
                ;;
            prepsh)
                cat <<EOF
prepsh - Prepare New Bash Script

Quickly create a new executable bash script with proper shebang.

Usage: prepsh [filename]

Description:
  - Creates a new bash script file with #!/usr/bin/env bash shebang
  - Makes the script executable automatically
  - Optionally opens the file in your editor
  - Provides a quick way to start new bash scripts

Behavior:
  - Without arguments: creates "main.sh"
  - If filename doesn't end in .sh, automatically adds .sh extension
  - Won't overwrite existing files (returns error if file exists)
  - Prompts to open in editor after creation
  - Sets executable permissions automatically

Dependencies:
  - chmod (for making file executable)
  - Editor specified in \$EDITOR (default: nvim, for optional editing)

Examples:
  prepsh              # Create main.sh
  prepsh myscript     # Create myscript.sh
  prepsh test.sh      # Create test.sh
  prepsh backup       # Create backup.sh

Note: The function will prompt you to edit the file after creation. Answer
      'y' to open in editor, 'n' to skip. The .sh extension is automatically
      added if not provided.
EOF
                return 0
                ;;
            timer)
                cat <<EOF
timer - Named Timer Management

Create and manage named timers to track elapsed time.

Usage: timer [NAME]
       timer list
       timer clear

Description:
  - Creates named timers that track elapsed time from when they were started
  - Stores timer start times in /tmp/timer-*.txt files
  - Displays elapsed time in HH:MM:SS format
  - Supports multiple named timers simultaneously
  - Provides simple time tracking for tasks or activities

Commands:
  (no args)      Start or check a timer named "Timer" (default)
  <name>         Start or check a named timer
  list           List all active timers with their elapsed times
  clear          Clear all timers (with confirmation)

Behavior:
  - First call with a name: starts a new timer
  - Subsequent calls with same name: shows elapsed time and offers to reset
  - Timer names are sanitized (spaces become underscores, special chars removed)
  - Default name is "Timer" if no name provided
  - Shows time in HH:MM:SS format (hours:minutes:seconds)
  - Commands are case-insensitive

Dependencies:
  - date (for timestamp tracking)
  - read (for user input)
  - rm (for clearing timers)
  - printf (for formatted output)
  - shopt (for nullglob)

Files:
  - /tmp/timer-*.txt - Timer files storing start timestamps

Examples:
  timer              # Start or check default "Timer"
  timer work         # Start or check "work" timer
  timer "my task"    # Start or check "my_task" timer (spaces become underscores)
  timer list         # List all active timers
  timer clear        # Clear all timers

Note: Timer names are automatically sanitized. Spaces become underscores, and
      special characters are removed. When checking an existing timer, you'll
      be prompted to reset it. Use "timer list" to see all active timers.
EOF
                return 0
                ;;
            weather)
                cat <<EOF
weather - Display Weather Information

Display weather information for your current location.

Usage: weather [OPTION]

Description:
  - Automatically detects your location via IP address
  - Displays current weather and/or forecast
  - Uses wttr.in API for weather data
  - Provides formatted, readable weather information

Options:
  (no args)      Show current weather + 3-day forecast
  current        Show only current weather
  forecast       Show only 3-day forecast
  help           Show help message

Behavior:
  - Without arguments: shows both current weather and 3-day forecast
  - "weather current": shows only current weather in compact format
  - "weather forecast": shows only 3-day forecast
  - Location is automatically detected from your IP address
  - Commands are case-insensitive

Dependencies:
  - curl (for API requests and location detection)
  - head (for formatting output)

Examples:
  weather              # Show current + 3-day forecast
  weather current      # Show only current weather
  weather forecast     # Show only 3-day forecast
  weather help         # Show help message

Note: Location is automatically detected. For weather in a specific location,
      use the wttr() function instead. The weather data comes from wttr.in.
EOF
                return 0
                ;;
            wttr)
                cat <<EOF
wttr - Weather for Any Location

Display weather information for any location using wttr.in.

Usage: wttr [location] [options]

Description:
  - Get weather for any location worldwide
  - Supports wttr.in API parameters
  - More flexible than weather() function
  - Uses WTTR_PARAMS environment variable for default options

Behavior:
  - Location can be city name, coordinates, or airport code
  - Spaces in location names are automatically converted to +
  - Accepts additional wttr.in API parameters
  - Uses WTTR_PARAMS environment variable for default formatting
  - Respects Accept-Language header from LANG environment variable

Dependencies:
  - curl (for API requests)

Environment Variables:
  - WTTR_PARAMS - Default parameters for wttr.in API (e.g., "n" for narrow format)

Examples:
  wttr London           # Weather for London
  wttr "New York"       # Weather for New York
  wttr NYC              # Weather for New York (airport code)
  wttr Paris n          # Weather for Paris with narrow format
  wttr Tokyo Q          # Weather for Tokyo with quiet mode

Note: This is a lower-level function that directly calls wttr.in API. For
      automatic location detection, use weather() instead. See wttr.in
      documentation for available format options and parameters.
EOF
                return 0
                ;;
            slashback|/|//|///|////|/////|//////)
                cat <<EOF
slashback - Quick Directory Navigation Upwards

Navigate up directory levels using slash functions.

Usage: / [levels]
       // [levels]
       /// [levels]
       etc.

Description:
  - Provides quick shortcuts to navigate up the directory tree
  - Each slash represents one directory level up
  - Functions are named with slashes: /, //, ///, ////, /////, //////
  - Allows rapid navigation without typing "cd ../.." repeatedly

Available Functions:
  /        - Navigate up 1 directory level (parent)
  //       - Navigate up 2 directory levels (grandparent)
  ///      - Navigate up 3 directory levels
  ////     - Navigate up 4 directory levels
  /////    - Navigate up 5 directory levels
  //////   - Navigate up 6 directory levels

Behavior:
  - The number of slashes determines how many levels up to navigate
  - Each slash function calls the internal __slashback function
  - Changes directory relative to current location
  - Works from any directory in the filesystem

Examples:
  /              # Go up 1 level: cd ..
  //             # Go up 2 levels: cd ../..
  ///            # Go up 3 levels: cd ../../..
  ////           # Go up 4 levels: cd ../../../..
  /////          # Go up 5 levels: cd ../../../../..
  //////         # Go up 6 levels: cd ../../../../../..

Note: These are bash functions with special names (just slashes). They provide
      a convenient way to quickly navigate up the directory tree without typing
      multiple "../" sequences. The functions are automatically available when
      slashback.sh is sourced.
EOF
                return 0
                ;;
            _PLUGINS|plugins|_plugins)
                cat <<EOF
_PLUGINS.sh - Plugin Loader System

Loads and manages all BRC plugin scripts.

Usage: source _PLUGINS.sh
       _PLUGINS.sh

Description:
  - Central plugin management system for BRC
  - Automatically sources all plugin scripts in the correct order
  - Maintains a list of available plugins
  - Provides error handling for missing plugins
  - Displays loaded plugins when run directly

Loaded Plugins:
  - _BASE_FUNCTIONS.sh  - Basic/Core helper functions
  - analyze-file.sh     - Inspect file contents and metadata quickly
  - bashrc.sh           - Load primary bash configuration helpers
  - cmd-not-found.sh    - Command-not-found handler with yay/flatpak search
  - dl-paper.sh         - Download wallpapers from YouTube
  - dots.sh             - Manage dotfile shortcuts and navigation
  - extract-compress.sh - Extract and compress files
  - fastnote.sh         - Append quick notes to the fastnote scratchpad
  - motd.sh             - Show message-of-the-day style summaries
  - navto.sh            - Jump to bookmarked filesystem locations
  - open.sh             - Open a file with the default application
  - pokefetch.sh        - Fetch random Pokémon data from the API
  - prepsh.sh           - Prepare shell session with common setup
  - slashback.sh        - Restore previous directories using slash shortcuts
  - weather.sh          - Display current weather information
  - timer.sh            - Set and monitor simple named timers
  - available.sh        - List available plugins and their status

Behavior:
  - When sourced: loads all plugins in the order listed
  - When run directly: displays list of all loaded plugins
  - Warns if a plugin file is missing (but continues loading others)
  - Plugins are sourced from the same directory as _PLUGINS.sh

Dependencies:
  - _DEPENDENCY_CHECK.sh (sourced automatically)

Examples:
  source _PLUGINS.sh    # Load all plugins (typical usage)
  _PLUGINS.sh           # Display list of loaded plugins

Note: This file is typically sourced automatically by .bashrc. It manages
      the loading of all BRC plugin scripts in the correct order. Plugins
      are loaded from the BASHRC directory.
EOF
                return 0
                ;;
            _ALIASES|aliases|_aliases)
                cat <<EOF
_ALIASES.sh - Shell Alias Definitions

Defines shell aliases for common commands and shortcuts.

Usage: source _ALIASES.sh
       _ALIASES.sh
       aliases

Description:
  - Central alias management system for BRC
  - Defines convenient shortcuts for common commands
  - Includes conditional aliases based on available tools
  - Provides root-specific aliases for safety
  - Displays all aliases when run directly

Alias Categories:

General Aliases:
  ++, cpx          - Copy with progress
  analyze          - Alias for analyze-file
  brb              - Reboot system (use zzz to poweroff)
  c, cls, clear    - Clear screen
  clss             - Clear screen and show pokefetch
  copy             - rsync with progress
  cx               - chmod +x (make executable, negate with xcx)
  duu              - Get size of current directory contents
  fzf              - fzf with bat preview
  gg, tg, update   - System update
  grep             - grep with color
  hardware         - System hardware information (overridden by nvim alias if nvim available)
  hyperctl         - hyprctl
  hyperpm          - hyprpm
  mc               - Midnight Commander (no subshell)
  media            - Navigate to /run/media
  media-cd         - Navigate to /run/media and then cd
  mu, music        - rmpc (music player)
  myip             - Get public IP address
  nuke             - Force kill process
  please, pls, s   - sudo
  plugins          - View _PLUGINS.sh
  aliases          - View _ALIASES.sh
  ports            - Show network ports
  speedtest        - Internet speed test
  ssh1             - SSH to expedition server
  tt               - tmux
  uninst, yayr     - Uninstall package
  us               - dots userScripts
  x                - exit
  xcx              - chmod -x (remove executable, negate with cx)
  zzz              - Poweroff system (use brb to reboot)

Root-Specific Aliases (when UID=0):
  rm, cp, mv       - Interactive versions (ask for confirmation)

EZA Aliases (if eza is available):
  ls               - eza with icons and grouping
  lsa              - eza with hidden files
  lt               - eza tree view
  lta              - eza tree with hidden files
  ff               - fzf with bat preview (eza-specific alias, separate from general fzf)

Neovim Aliases (if nvim is available):
  vi, vim          - nvim
  svi, svim        - sudo nvim
  edit             - nvim
  hardware         - hardware info in nvim (overrides general hardware alias)

Behavior:
  - When sourced: defines all aliases in current shell
  - When run directly: displays all alias definitions
  - Conditional aliases only defined if required tools are available
  - Root aliases only active when running as root user

Examples:
  source _ALIASES.sh    # Load all aliases (typical usage)
  _ALIASES.sh           # Display all aliases
  aliases               # Display all aliases (using alias)

Note: This file is typically sourced automatically by .bashrc via _PLUGINS.sh.
      You can also use "bashrc alias" to view aliases. Conditional aliases
      (eza, nvim) are only defined if those tools are installed.
EOF
                return 0
                ;;
            ___INSTALL|INSTALL|install|_INSTALL)
                cat <<EOF
___INSTALL.sh - BRC Installation Script

Interactive installation script for the BRC configuration system.

Usage: bash ___INSTALL.sh

Description:
  - Installs BRC configuration into your home directory
  - Creates timestamped backup of existing .bashrc
  - Copies all shell scripts to ~/BASHRC directory
  - Initializes settings.json configuration file
  - Creates welcome message in motd.txt
  - Provides rollback instructions if needed

Installation Steps:
  1. Backup: Creates timestamped backup of ~/.bashrc in ~/.bashrc.backup/
  2. Install: Copies .bashrc.copyToHome to ~/.bashrc
  3. Scripts: Creates ~/BASHRC directory and copies all *.sh files
  4. Settings: Initializes settings.json with default configuration
  5. Welcome: Creates motd.txt with installation success message

Safety Features:
  - Interactive confirmation required before installation
  - Automatic backup creation with timestamp
  - Automatic rollback on errors
  - Preserves existing ~/BASHRC directory if it exists
  - Cannot be run from within ~/BASHRC directory

Files Created/Modified:
  - ~/.bashrc - Replaced with new configuration
  - ~/.bashrc.backup/YYYYMMDDHHMMSS.bashrc - Timestamped backup
  - ~/BASHRC/ - Directory containing all shell scripts
  - ~/BASHRC/settings.json - Configuration file
  - ~/motd.txt - Welcome message

Behavior:
  - Prompts for confirmation before proceeding
  - Shows animated copyright message at start
  - Provides detailed logging of each step
  - Handles errors gracefully with automatic rollback
  - Asks for confirmation if ~/BASHRC already exists
  - Cleans up on failure (removes copied files, restores .bashrc)

Dependencies:
  - bash
  - Standard Unix utilities (cp, mkdir, date, etc.)

Examples:
  bash ___INSTALL.sh        # Run installation script

Rollback:
  If you need to revert the installation:
    cp ~/.bashrc.backup/YYYYMMDDHHMMSS.bashrc ~/.bashrc
    source ~/.bashrc

Note: This script must be run from outside the ~/BASHRC directory. It will
      create a timestamped backup of your existing .bashrc before making any
      changes. All installation steps are logged with clear status messages.
EOF
                return 0
                ;;
            ___UPDATE|UPDATE|update|_UPDATE)
                cat <<EOF
___UPDATE.sh - BRC Update Script

Automated update script that compares installed version with git repository version
and offers to update if a newer version is available.

Usage: bash ___UPDATE.sh

Description:
  - Compares version number from ~/BASHRC/settings.json with git repository version
  - Downloads settings.json from the remote git repository
  - Parses version format (0.YYYY.MM.DD) and compares year, month, and day
  - Offers to update if repository version is newer
  - Performs safe update with automatic backups
  - Runs installer from the git repository directory

Update Process:
  1. Version Check: Reads installed version from ~/BASHRC/settings.json
  2. Repository Check: Downloads settings.json from git repository (or uses local)
  3. Comparison: Compares versions to determine if update is available
  4. Backup: Creates timestamped backups of ~/.bashrc and ~/BASHRC directory
  5. Installation: Runs ___INSTALL.sh from the git repository directory

Safety Features:
  - Interactive confirmation required before updating
  - Automatic backup of ~/.bashrc to ~/.bashrc.backup/
  - Automatic backup of ~/BASHRC to ~/BASHRC.backup.TIMESTAMP
  - Cannot be run from ~/BASHRC directory (must run from git repository)
  - Verifies git repository status before proceeding
  - Provides detailed logging of each step
  - Shows rollback instructions after successful update

Version Comparison:
  - Version format: 0.YYYY.MM.DD (e.g., 0.2025.11.15)
  - Compares year, then month, then day
  - Update offered only if repository version is strictly newer
  - If versions match or installed is newer, no update is offered

Files Created/Modified:
  - ~/.bashrc.backup/YYYYMMDDHHMMSS.bashrc - Timestamped .bashrc backup
  - ~/BASHRC.backup.TIMESTAMP/ - Timestamped BASHRC directory backup
  - All files installed by ___INSTALL.sh during update

Behavior:
  - Must be run from the git repository directory (not from ~/BASHRC)
  - Checks if current directory is a git repository
  - Attempts to fetch latest from remote repository
  - Falls back to local git checkout if remote fetch fails
  - Downloads settings.json from raw GitHub URL or uses local file
  - Prompts user before proceeding with update
  - Shows clear version comparison information
  - Runs ___INSTALL.sh after successful backups

Dependencies:
  - curl (for downloading settings.json from remote)
  - jq (for parsing JSON version information)
  - git (for repository operations)
  - date (for timestamp generation)
  - bash (for script execution)
  - ___INSTALL.sh (runs automatically during update)

Examples:
  bash ___UPDATE.sh        # Check for updates and install if available

Prerequisites:
  - Must be run from the directory where you cloned the BASHRC repository
  - Cannot be run from ~/BASHRC directory
  - Current directory must be a git repository
  - BASHRC must already be installed (for version comparison)

Rollback:
  If you need to revert after an update:
    cp ~/.bashrc.backup/YYYYMMDDHHMMSS.bashrc ~/.bashrc
    rm -rf ~/BASHRC && mv ~/BASHRC.backup.TIMESTAMP ~/BASHRC
    source ~/.bashrc

Note: This script checks for updates by comparing the VERSION field in settings.json
      from your installed BASHRC with the version in the git repository. It must be
      run from the git repository directory (where you cloned the repo), not from
      ~/BASHRC. The script will automatically backup your configuration before
      updating, and provides instructions for rollback if needed.
EOF
                return 0
                ;;
            bash-completion|bash_completion|bashcompletion)
                cat <<EOF
bash-completion - Enhanced Tab Completion System

Automatic tab completion for bash commands, options, and arguments.

Usage: Automatically loaded when available

Description:
  - Provides enhanced tab completion for bash commands
  - Automatically loads if /usr/share/bash-completion/bash_completion exists
  - Enables completion for git, docker, systemd, ssh, and many other commands
  - Provides programmable completion for command arguments and options
  - Works seamlessly with BRC's existing completion settings

Behavior:
  - Automatically sourced from .bashrc if the file exists
  - No configuration needed - works out of the box
  - Enhances tab completion for hundreds of commands
  - Provides intelligent completion suggestions
  - Works alongside BRC's completion settings (case-insensitive, etc.)

Features:
  - Command option completion (e.g., git checkout <TAB> shows branches)
  - File path completion with filtering
  - Package name completion (for package managers)
  - Environment variable completion
  - Hostname completion for SSH
  - And many more command-specific completions

Dependencies:
  - bash-completion package (usually installed via system package manager)
  - File must exist at: /usr/share/bash-completion/bash_completion

Installation:
  On Arch Linux:
    sudo pacman -S bash-completion
  
  On Debian/Ubuntu:
    sudo apt install bash-completion
  
  On Fedora:
    sudo dnf install bash-completion

Examples:
  git checkout <TAB>              # Shows available branches
  docker run <TAB>                # Shows available Docker images
  systemctl <TAB>                 # Shows systemd commands
  ssh <TAB>                       # Shows known hosts
  pacman -S <TAB>                 # Shows available packages

Note: Bash-completion is automatically loaded if available. No manual
      configuration is required. It enhances the default bash completion
      system with intelligent, context-aware suggestions for many common
      commands. The completion system works alongside BRC's existing
      completion settings like case-insensitive completion and menu completion.
EOF
                return 0
                ;;
            _PREAMBLE|PREAMBLE|preamble)
                cat <<EOF
_PREAMBLE.sh - User Customization File

Safe place to add custom configuration that won't be overwritten.

Usage: Edit ~/BASHRC/_PREAMBLE.sh directly

Description:
  - User-editable file for custom shell configuration
  - Changes persist even when .bashrc is updated
  - Sourced three times: before interactive check, after interactive check, and at the end
  - Provides separation between system config and user customizations
  - Uses case statement to handle different sourcing contexts

Behavior:
  - Sourced with --non-interactive flag before interactive check
    (runs in all shells, including non-interactive)
    - Use this section for environment variables needed in all shells
  - Sourced with --interactive flag (or no flag) after interactive check
    (runs only in interactive shells)
    - Use this section for interactive-only features
  - Sourced with --tail flag at the very end of .bashrc
    (runs only in interactive shells, after all plugins are loaded)
    - Use this section for configuration that needs to run after plugins

Sections:
  --non-interactive, -1  - Runs before interactive check (all shells)
  --interactive, -2      - Runs after interactive check (interactive shells only)
  --tail, -3             - Runs at the end of .bashrc (interactive shells only)

When to Use:
  - Add personal aliases, functions, or environment variables
  - Set up custom PATH modifications
  - Configure personal preferences
  - Add machine-specific settings
  - Configure plugin-specific settings (use --tail section)
  - Any customization you want to preserve across updates

Examples:
  # Add to _PREAMBLE.sh:
  case "\${1^^}" in
      "--NON-INTERACTIVE"|"-1")
          export MY_CUSTOM_VAR="value"
          return 0
          ;;
      "--TAIL"|"-3")
          export PLUGIN_SETTING="value"
          return 0
          ;;
      *)
          alias myalias="command"
          myfunction() { echo "custom function"; }
          return 0
          ;;
  esac

Note: This file uses a case statement to handle different sourcing contexts.
      Add your customizations in the appropriate section based on when you
      need them to run. The file is sourced from .bashrc at three points:
      once before the interactive check (for environment setup), once after
      (for interactive-only features), and once at the end (for post-plugin
      configuration).
EOF
                return 0
                ;;
            starship)
                cat <<EOF
starship - Cross-Shell Prompt Customization

The minimal, blazing-fast, and infinitely customizable prompt for any shell.

Usage: Configured automatically via settings.json

Description:
  - Cross-shell prompt customization tool (bash, zsh, fish, etc.)
  - Provides fast, customizable, and feature-rich command prompt
  - Shows git status, directory info, command duration, and more
  - Highly configurable via ~/.config/starship.toml
  - Replaces the default bash PS1 prompt when enabled

Behavior:
  - Automatically initialized when enabled in settings.json
  - Runs "eval \$(starship init bash)" to set up the prompt
  - If starship is not installed, shows a warning and disables itself
  - Works alongside other BRC features (zoxide, vimkeys, etc.)

Configuration:
  - Enable/disable: Edit ~/BASHRC/settings.json
    Set "enable_starship": true or false
  - Customize prompt: Edit ~/.config/starship.toml
    See https://starship.rs/config/ for configuration options

Dependencies:
  - starship (must be installed separately)
    Install via: curl -sS https://starship.rs/install.sh | sh
    Or via package manager: cargo install starship

Files:
  - ~/.config/starship.toml - Starship configuration file (create if needed)

Examples:
  # Enable starship in settings.json:
  {
    "enable_starship": true
  }
  
  # Disable starship:
  {
    "enable_starship": false
  }
  
  # Customize prompt (create ~/.config/starship.toml):
  [git_status]
  format = '[\($all_status$ahead_behind\)]($style) '
  
  [directory]
  truncation_length = 3

Note: When starship is enabled, it replaces the default bash PS1 prompt.
      The prompt is initialized early in .bashrc loading. To customize
      the starship prompt appearance, create and edit ~/.config/starship.toml.
      Visit https://starship.rs for full documentation and configuration options.
EOF
                return 0
                ;;
            zoxide)
                cat <<EOF
zoxide - Smarter cd Command

A smarter way to navigate directories. Zoxide learns your habits and gets you
where you need to go with just a few keystrokes.

Usage: Configured automatically via settings.json

Description:
  - Smarter replacement for the cd command
  - Learns your navigation patterns and ranks directories by frequency and recency
  - Provides intelligent directory jumping with partial matching
  - Works with any number of arguments (matches paths across filesystem)
  - Replaces standard cd command when enabled

Behavior:
  - Automatically initialized when enabled in settings.json
  - Runs "eval \$(zoxide init bash)" to set up the shell integration
  - Replaces the cd command with zoxide's z command
  - Adds cdi alias for interactive mode (zi)
  - If zoxide is not installed, shows a warning and disables itself
  - Works alongside other BRC features

Commands:
  cd <query>      - Jump to directory (uses zoxide's smart matching)
  cdi <query>     - Interactive mode: shows multiple matches to choose from
  z <query>       - Direct zoxide command (same as cd when enabled)
  zi <query>      - Direct zoxide interactive command (same as cdi when enabled)
  zd <query>      - Change directory with zoxide and display contents

Smart Matching:
  - Partial matches work (e.g., "cd doc" matches "Documents")
  - Matches across the entire filesystem, not just current directory
  - Prioritizes frequently accessed directories
  - Considers recency (recently visited directories rank higher)
  - Fuzzy matching: "cd proj" might match "~/Projects/myproject"

Configuration:
  - Enable/disable: Edit ~/BASHRC/settings.json
    Set "enable_zoxide": true or false
  - Customize: Create ~/.config/zoxide/config.toml
    See https://github.com/ajeetdsouza/zoxide for configuration options

Dependencies:
  - zoxide (must be installed separately)
    Install via: curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    Or via package manager: cargo install zoxide

Files:
  - ~/.local/share/zoxide/db.zo - Zoxide database (auto-created, stores directory rankings)

Examples:
  # Enable zoxide in settings.json:
  {
    "enable_zoxide": true
  }
  
  # Disable zoxide:
  {
    "enable_zoxide": false
  }
  
  # Basic usage:
  cd doc              # Jump to Documents (if frequently accessed)
  cd /var/log         # Works like normal cd for absolute paths
  cd ..               # Works like normal cd for relative paths
  
  # Interactive mode (when multiple matches):
  cdi proj            # Shows list of matching project directories to choose from
  
  # Change directory and list contents:
  zd doc              # Jump to Documents and list contents

Note: When zoxide is enabled, the standard cd command is replaced with zoxide's
      smart directory jumping. This means "cd" becomes intelligent and learns
      your habits over time. The zd() function combines zoxide's smart jumping
      with automatic directory listing. If zoxide is not available, zd() falls
      back to cdd() automatically.
EOF
                return 0
                ;;
            blesh|ble\.sh|blesh)
                cat <<EOF
blesh - Bash Line Editor

A powerful line editor for bash that provides syntax highlighting, auto-completion,
and modern editing features in your terminal.

Usage: Configured automatically via settings.json

Description:
  - Advanced line editor for bash (Bash Line Editor)
  - Provides syntax highlighting as you type
  - Enhanced auto-completion with visual feedback
  - Vim/Emacs keybinding support
  - Real-time syntax checking and error highlighting
  - Multi-line command editing support
  - History search and navigation enhancements

Behavior:
  - Automatically sourced when enabled in settings.json
  - Loads from ~/.local/share/blesh/ble.sh
  - Only loads if the ble.sh file exists and enable_blesh is true
  - Initializes enhanced editing features immediately
  - Works alongside other BRC features

Features:
  - Syntax highlighting for commands, options, and arguments
  - Auto-completion with visual selection
  - Vim/Emacs keybinding modes
  - Real-time syntax validation
  - Multi-line command editing with proper indentation
  - Enhanced history search with incremental search
  - Visual feedback for command execution status
  - Improved tab completion with previews

Configuration:
  - Enable/disable: Edit ~/BASHRC/settings.json
    Set "enable_blesh": true or false
  - Customize: Edit ~/.local/share/blesh/ble.conf
    See https://github.com/akinomyoga/ble.sh for configuration options
  - Keybindings: Configure in ble.conf (vim/emacs modes available)

Dependencies:
  - ble.sh (must be installed separately)
    Install via: git clone --recursive https://github.com/akinomyoga/ble.sh.git ~/.local/share/blesh
    Then run: make -C ~/.local/share/blesh install PREFIX=~/.local
    Or follow instructions at https://github.com/akinomyoga/ble.sh

Files:
  - ~/.local/share/blesh/ble.sh - Main ble.sh script (required)
  - ~/.local/share/blesh/ble.conf - Configuration file (optional)

Examples:
  # Enable blesh in settings.json:
  {
    "enable_blesh": true
  }
  
  # Disable blesh:
  {
    "enable_blesh": false
  }
  
  # After enabling, you'll see:
  # - Syntax highlighting as you type commands
  # - Enhanced tab completion
  # - Visual feedback for command editing

Note: Ble.sh enhances the bash command line editing experience with modern
      features like syntax highlighting and improved auto-completion. It loads
      early in the shell initialization process to provide immediate enhancements.
      If the ble.sh file is not found at ~/.local/share/blesh/ble.sh, it will
      silently skip loading without errors. Ble.sh works well with other BASHRC
      features and can be used alongside zoxide, starship, and other enhancements.
EOF
                return 0
                ;;
            shell-mommy|shellmommy|shell_mommy)
                cat <<EOF
shell-mommy - Encouraging Terminal Assistant

A supportive terminal assistant that provides encouragement and feedback when
you run commands, making your terminal experience more positive and friendly.

Usage: Configured automatically via settings.json

Description:
  - Terminal assistant that provides encouragement after command execution
  - Gives supportive messages based on command success or failure
  - Customizable personality and language
  - Only shows negative feedback when enabled (SHELL_MOMMYS_ONLY_NEGATIVE=true)
  - Uses colorful output to make terminal interactions more engaging

Behavior:
  - Automatically sourced when enabled in settings.json
  - Loads from ~/shell-mommy/shell-mommy.sh
  - Only loads if the shell-mommy.sh file exists and enable_shellmommy is true
  - Integrated into PROMPT_COMMAND to run after each command
  - Provides feedback based on command exit status
  - Works alongside other BRC features

Configuration in BRC:
  Environment variables can be configured in the --tail section of _PREAMBLE.sh,
  which runs after all plugins are loaded, ensuring shell-mommy is configured correctly.

Features:
  - Encouraging messages after command execution
  - Customizable personality and language
  - Color-coded output for better visibility
  - Configurable feedback (positive/negative/both)
  - Fun, friendly terminal experience

Configuration:
  - Enable/disable: Edit ~/BASHRC/settings.json
    Set "enable_shellmommy": true or false
  - Customize personality: Modify environment variables in _PREAMBLE.sh --tail section
    - Edit ~/BASHRC/_PREAMBLE.sh and modify the --tail section
    - SHELL_MOMMYS_LITTLE - what shell-mommy calls you
    - SHELL_MOMMYS_PRONOUNS - pronouns for shell-mommy
    - SHELL_MOMMYS_ROLES - roles/personality types
    - SHELL_MOMMYS_COLOR - message color (ANSI color codes)
    - SHELL_MOMMYS_ONLY_NEGATIVE - show messages only on errors
  - See shell-mommy documentation for more customization options

Dependencies:
  - shell-mommy (must be installed separately)
    Install via: git clone https://github.com/bxparks/shell-mommy.git ~/shell-mommy
    Or follow instructions at https://github.com/bxparks/shell-mommy

Files:
  - ~/shell-mommy/shell-mommy.sh - Main shell-mommy script (required)

Examples:
  # Enable shell-mommy in settings.json:
  {
    "enable_shellmommy": true
  }
  
  # Disable shell-mommy:
  {
    "enable_shellmommy": false
  }
  
  # Customize in _PREAMBLE.sh --tail section:
  # Edit ~/BASHRC/_PREAMBLE.sh and add to the --tail section:
  export SHELL_MOMMYS_LITTLE="developer/coder/engineer"
  export SHELL_MOMMYS_ONLY_NEGATIVE=false  # Show messages for both success and failure
  export SHELL_MOMMYS_COLOR="\e[35m"       # Change to magenta

Note: Shell-mommy provides a fun, supportive terminal experience by giving
      encouragement after command execution. When configured with
      SHELL_MOMMYS_ONLY_NEGATIVE=true, it only shows messages when commands fail,
      helping you learn from mistakes. If the shell-mommy.sh file is not found
      at ~/shell-mommy/shell-mommy.sh, it will silently skip loading without errors.
      Shell-mommy works well with other BRC features and can be used alongside
      blesh, zoxide, starship, and other enhancements.
EOF
                return 0
                ;;
            base|_BASE_FUNCTIONS)
                # Delegate to _manual_base.sh with remaining arguments
                local __manual_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                shift  # Remove "base" from arguments
                source "$__manual_dir/_manual_base.sh" "$@"
                return $?
                ;;
            *)
                # Check if the entry is available under base functions
                local __manual_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                source "$__manual_dir/_manual_base.sh" --quiet "$1"
                local base_result=$?
                if [[ $base_result -eq 0 ]]; then
                    return 0
                fi
                # If not found in base either, show error
                echo "No manual entry found for: $1"
                return 1
                ;;
        esac
    fi
    
    # Default help
    cat <<EOF
Usage: brchelp [FUNCTION]

Show the manual for a specific function

Available functions:
  ___INSTALL      - BRC installation script
  ___UPDATE       - BRC update script
  _ALIASES        - Shell alias definitions
  _PLUGINS        - Plugin loader system
  _PREAMBLE       - User customization file
  analyze-file    - File analysis tool
  automotd        - Automatic message of the day generator
  available       - List available bash functions
  base            - Basic helper functions (submenu)
  bash-completion - Enhanced tab completion system
  bashrc          - Edit .bashrc or view aliases
  cmd-not-found   - Automatic command not found handler
  blesh           - Bash Line Editor
  compress        - Create archives
  dl-paper        - Download wallpaper clips with yt-dlp
  dots            - Manage and navigate .config directories
  extract         - Extract archives
  fastnote        - Quick note management
  generate-man-pages - Generate man pages from manual files
  motd            - Message of the day
  navto           - Quick navigation to common directories
  open            - Smart file and URL opener
  pokefetch       - Pokemon-themed system information display
  prepsh          - Prepare new bash script
  shell-mommy     - Encouraging terminal assistant
  slashback       - Quick directory navigation upwards
  starship        - Cross-shell prompt customization
  timer           - Named timer management
  weather         - Display weather information
  wttr            - Weather for any location
  zoxide          - Smarter cd command

Examples:
  brchelp available
  brchelp timer
  brchelp base calc
  brchelp dl-paper
  brchelp _ALIASES
EOF
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    brchelp "$@"
    exit $?
fi