#!/usr/bin/env bash

# Base functions help submenu
# Called from _manual.sh with remaining arguments

# Check for --quiet flag
__MANUAL_BASE_QUIET_MODE=false
if [[ "$1" == "--quiet" ]]; then
    __MANUAL_BASE_QUIET_MODE=true
    shift
fi

if [[ -n "$1" ]]; then
    case "$1" in
        backup)
            cat <<EOF
backup - Backup a Single File

Create a timestamped backup of a file.

Usage: backup <file>

Description:
  - Creates a backup copy of a file with timestamp
  - Backup filename format: filename.bak.YYYYMMDDHHMMSS
  - Preserves original file
  - Provides simple file backup functionality

Behavior:
  - Checks if file exists before backing up
  - Creates backup with current timestamp
  - Displays confirmation message with backup filename
  - Returns error if file doesn't exist

Dependencies:
  - cp (for copying file)
  - date (for timestamp generation)

Examples:
  backup script.sh           # Creates script.sh.bak.20250114123045
  backup config.txt          # Creates config.txt.bak.20250114123045

Note: The backup file includes a timestamp in the format YYYYMMDDHHMMSS.
      Original file is preserved unchanged.
EOF
            return 0
            ;;
        backup_all|backup-all)
            cat <<EOF
backup_all - Backup All Files in Current Directory

Create timestamped backups of all regular files in the current directory.

Usage: backup_all

Description:
  - Backs up every regular file in the current directory
  - Uses backup() function for each file
  - Creates timestamped backups for all files
  - Skips directories and special files

Behavior:
  - Iterates through all files in current directory
  - Calls backup() for each regular file
  - Only processes regular files (not directories)
  - Each file gets its own timestamped backup

Dependencies:
  - backup() function (which requires cp and date)

Examples:
  backup_all                 # Backup all files in current directory

Note: This function calls backup() for each file, so each backup will have
      its own timestamp. Directories and special files are skipped.
EOF
            return 0
            ;;
        brcversion)
            cat <<EOF
brcversion - Show BRC Version

Display the currently installed BRC (BASHRC) version.

Usage: brcversion

Description:
  - Reads the VERSION field from ~/BASHRC/settings.json
  - Displays the currently installed BRC version
  - Quick way to check which version you have installed

Behavior:
  - Reads version from ~/BASHRC/settings.json using jq
  - Prints version in format: "BRC version: 0.YYYY.MM.DD"
  - Returns error if settings.json not found or VERSION field missing

Dependencies:
  - jq (for parsing JSON)

Examples:
  brcversion              # Shows: BRC version: 0.2025.11.15

Note: This function is a simple way to check your installed BRC version.
      Use brcupdate() to check if a newer version is available online.
EOF
            return 0
            ;;
        brcupdate)
            cat <<EOF
brcupdate - Check for BRC Updates

Check if a newer version of BRC is available in the repository.

Usage: brcupdate

Description:
  - Compares installed version with the repository version online
  - Downloads settings.json from GitHub to get repository version
  - Parses and compares version numbers (format: 0.YYYY.MM.DD)
  - Informs user if an update is available and how to update
  - Does not perform the update (just checks and informs)

Behavior:
  - Reads installed version from ~/BASHRC/settings.json
  - Downloads remote settings.json from GitHub raw URL
  - Compares versions using year, month, day comparison
  - If update available: shows version comparison and update instructions
  - If up to date: informs user they're running latest version
  - Returns error if BRC not installed or version fetch fails

Version Comparison:
  - Version format: 0.YYYY.MM.DD (e.g., 0.2025.11.15)
  - Compares year, then month, then day
  - Update available only if repository version is strictly newer

Dependencies:
  - curl (for downloading settings.json from remote)
  - jq (for parsing JSON version information)

Examples:
  brcupdate               # Check for available updates

Output when update available:
  Update available!
    Installed version: 0.2025.11.14 (2025-11-14)
    Repository version: 0.2025.11.15 (2025-11-15)
  
  To update:
    1. Navigate to your cloned BRC repository directory
    2. Run: git pull
    3. Run: ./___UPDATE.sh
  
  ⚠️  Important: Do NOT run ___UPDATE.sh from ~/BASHRC/
     The update script must be run from your cloned git repository directory.

Output when up to date:
  You are running the latest version: 0.2025.11.15

Note: This function only checks for updates and provides instructions.
      It does not perform the actual update. To update, follow the
      instructions provided and run ___UPDATE.sh from your cloned
      git repository directory (not from ~/BASHRC/). Use brcversion()
      to see your current installed version.
EOF
            return 0
            ;;
        calc)
            cat <<EOF
calc - Arithmetic Calculator

Perform arithmetic calculations with decimal support.

Usage: calc <expression>

Description:
  - Evaluates arithmetic expressions
  - Supports decimal numbers
  - Uses bc for calculation
  - Cleans up output (removes trailing zeros)

Behavior:
  - Requires an expression as argument
  - Uses bc calculator with 10 decimal places precision
  - Removes trailing zeros and unnecessary decimal points
  - Returns error if expression is invalid

Dependencies:
  - bc (basic calculator)

Examples:
  calc '2 + 3'              # Result: 5
  calc '2 + 3.5 * 4'        # Result: 16
  calc '10 / 3'             # Result: 3.3333333333
  calc 'sqrt(16)'           # Result: 4

Note: Expression must be quoted if it contains spaces or special characters.
      Supports standard arithmetic operations and bc functions.
EOF
            return 0
            ;;
        cd)
            cat <<EOF
cd - Change Directory (Enhanced)

Enhanced cd command that defaults to home directory when no arguments provided.

Usage: cd [directory]

Description:
  - Overrides the builtin cd command
  - Changes to home directory if no arguments provided
  - Passes through to builtin cd for all other cases
  - Can be overridden by zoxide alias when zoxide is enabled

Behavior:
  - Without arguments: changes to home directory (\$HOME)
  - With arguments: passes through to builtin cd command
  - Works exactly like standard cd for all other operations
  - May be overridden by zoxide's cd alias if zoxide is enabled

Dependencies:
  - None (uses builtin cd)

Examples:
  cd              # Change to home directory
  cd /tmp         # Change to /tmp directory
  cd ..           # Change to parent directory
  cd ~/Documents  # Change to Documents directory

Note: This is a wrapper around the builtin cd command. When zoxide is enabled,
      its cd alias may override this function. Without arguments, it provides
      a convenient shortcut to go home.
EOF
            return 0
            ;;
        cdd)
            cat <<EOF
cdd - Change Directory and Display Contents

Change to a directory and automatically list its contents.

Usage: cdd <directory>

Description:
  - Changes to the specified directory
  - Automatically lists directory contents after changing
  - Shows directory path with folder emoji
  - Uses eza if available, otherwise falls back to ls
  - Provides a convenient way to navigate and see contents

Behavior:
  - Requires a directory argument
  - Changes to the directory if it exists
  - Displays current directory path with 📁 emoji
  - Lists directory contents (uses eza with icons if available)
  - Returns error if directory doesn't exist
  - Does not list contents if directory change fails

Dependencies:
  - ls (for listing contents)
  - eza (optional, for enhanced listing with icons)

Examples:
  cdd /tmp                # Change to /tmp and list contents
  cdd ~/Documents         # Change to Documents and list contents
  cdd ../                 # Change to parent directory and list contents

Note: This function requires a directory argument. It will not work without
      arguments (unlike cd). For directory navigation with automatic listing,
      this provides a convenient one-step operation. See also zd() for a
      zoxide-powered version that provides smart directory jumping with the
      same listing behavior.
EOF
            return 0
            ;;
        cpuinfo)
            cat <<EOF
cpuinfo - CPU Usage Information

Display current CPU usage and top CPU-consuming processes.

Usage: cpuinfo

Description:
  - Shows current CPU usage percentage
  - Displays top 10 processes sorted by CPU usage
  - Provides a quick overview of system CPU activity
  - Useful for monitoring system performance

Behavior:
  - Displays CPU usage percentage (from top command)
  - Shows top 10 processes consuming the most CPU
  - Processes are sorted by CPU usage (highest first)
  - Uses batch mode for non-interactive output

Dependencies:
  - top (for CPU usage information)
  - grep (for filtering output)
  - awk (for text processing)
  - cut (for extracting fields)
  - ps (for process information)
  - head (for limiting output)

Examples:
  cpuinfo              # Show CPU usage and top processes

Note: This function provides a snapshot of current CPU usage. The CPU usage
      percentage is extracted from the top command output. The top processes
      list shows the 10 processes currently using the most CPU resources.
EOF
            return 0
            ;;
        cpx)
            cat <<EOF
cpx - Compile and Run C++ File

Quickly compile and run a C++ file in one command.

Usage: cpx [file.cpp]

Description:
  - Compiles a C++ file using g++
  - Automatically runs the compiled executable
  - Shows the exit code of the program
  - Cleans up the temporary executable file
  - Defaults to main.cpp if no file is specified

Behavior:
  - Without arguments: compiles and runs main.cpp
  - With argument: compiles and runs the specified C++ file
  - Compiles to a.out (temporary executable)
  - Runs the executable immediately after compilation
  - Displays the exit code of the program
  - Removes a.out after execution
  - Returns error if file doesn't exist

Dependencies:
  - g++ (C++ compiler)

Examples:
  cpx                # Compile and run main.cpp
  cpx program.cpp    # Compile and run program.cpp
  cpx test.cpp       # Compile and run test.cpp

Note: The compiled executable is always named a.out and is automatically
      removed after execution. If compilation fails, the program won't run
      and a.out won't be created. This is a quick way to test C++ code
      without manually compiling and running separately.
EOF
            return 0
            ;;
        genpassword)
            cat <<EOF
genpassword - Generate Random Password

Generate a random password with alphanumeric characters and optional special characters.

Usage: genpassword [length] [--special|-s]
       genpassword [--special|-s] [length]

Description:
  - Generates a random password using /dev/urandom
  - Uses alphanumeric characters (A-Z, a-z, 0-9) and underscores by default
  - Can include special characters with --special or -s flag
  - Default length is 16 characters if not specified
  - Provides secure random password generation

Options:
  --special, -s    Include special characters in the password
                   Special characters: !@#\$%^&*()+-=[]{}|;:,.<>?

Behavior:
  - Without arguments: generates a 16-character password (alphanumeric + underscore)
  - With length: generates a password of the specified length
  - With --special/-s: includes special characters in the character set
  - Uses /dev/urandom as the random source
  - Default characters: uppercase letters, lowercase letters, digits, and underscores
  - With --special: adds special characters to the character set
  - Output is trimmed (xargs removes trailing whitespace)
  - Arguments can be in any order

Dependencies:
  - tr (for character filtering)
  - head (for limiting length)
  - xargs (for trimming output)

Examples:
  genpassword                    # Generate 16-character password (alphanumeric)
  genpassword 20                 # Generate 20-character password (alphanumeric)
  genpassword --special          # Generate 16-character password with special chars
  genpassword -s 20              # Generate 20-character password with special chars
  genpassword 32 --special       # Generate 32-character password with special chars
  genpassword -s 8               # Generate 8-character password with special chars

Note: The password is generated using /dev/urandom, which provides
      cryptographically secure random data. By default, the password contains
      only alphanumeric characters (A-Z, a-z, 0-9) and underscores (_). Use
      the --special or -s flag to include special characters for stronger
      passwords that meet more complex requirements.
EOF
            return 0
            ;;
        h)
            cat <<EOF
h - Quick History Viewer

View command history, optionally filtered by a search term, or edit history file.

Usage: h [search-term]
       h --edit|-e

Description:
  - Displays command history from the current shell session
  - Can filter history by a search term (case-insensitive)
  - Can open the bash history file in nvim for editing
  - Provides a quick way to find previously executed commands
  - Useful for recalling commands without scrolling through full history

Options:
  --edit, -e    Open ~/.bash_history in nvim for editing

Behavior:
  - Without arguments: displays full command history
  - With search term: filters history to show only matching commands
  - With --edit/-e: opens ~/.bash_history in nvim editor
  - Search is case-insensitive (matches both uppercase and lowercase)
  - Uses grep to filter history entries
  - Shows all history entries that contain the search term
  - Edit mode opens the persistent history file (not just current session)

Dependencies:
  - grep (for filtering history)
  - nvim (for edit mode)

Examples:
  h                    # Show full command history
  h cd                 # Show all commands containing "cd"
  h git                # Show all git commands
  h install            # Show all commands with "install"
  h "sudo"             # Show all commands with "sudo"
  h --edit             # Open bash history file in nvim
  h -e                 # Open bash history file in nvim (short form)

Note: This function searches through the current shell's command history.
      The search is case-insensitive, so "h CD" and "h cd" will return
      the same results. Use this to quickly find commands you've used
      recently without manually scrolling through the full history.
      The --edit/-e option opens the persistent ~/.bash_history file,
      which contains history from all shell sessions.
EOF
            return 0
            ;;
        mkcd)
            cat <<EOF
mkcd - Make Directory and Change Into It

Create a directory and automatically change into it, then list contents.

Usage: mkcd <directory>

Description:
  - Creates a directory (including parent directories if needed)
  - Automatically changes into the newly created directory
  - Lists directory contents after creation
  - Shows directory path with folder emoji
  - Uses eza if available, otherwise falls back to ls
  - Provides a convenient one-step operation for creating and entering directories

Behavior:
  - Requires a directory name as argument
  - Creates the directory using mkdir -p (creates parent directories if needed)
  - Changes into the directory after creation
  - Displays current directory path with 📁 emoji
  - Lists directory contents (uses eza with icons if available)
  - Returns error if directory creation fails
  - Returns error if directory change fails
  - Does not list contents if directory creation or change fails

Dependencies:
  - mkdir (for creating directory)
  - cd (builtin, for changing directory)
  - ls (for listing contents)
  - eza (optional, for enhanced listing with icons)

Examples:
  mkcd newproject           # Create newproject/ and enter it
  mkcd ~/Documents/notes    # Create notes/ in Documents and enter it
  mkcd path/to/new/dir      # Create nested directories and enter the final one

Note: This function creates the directory structure using mkdir -p, which
      means it will create any necessary parent directories. After creation,
      it automatically changes into the directory and lists its contents,
      making it easy to start working in a new directory immediately.
EOF
            return 0
            ;;
        n)
            cat <<EOF
n - Open in Neovim

Open the current directory or specified files in nvim.

Usage: n [file...]

Description:
  - Opens files or directories in nvim
  - Without arguments: opens current directory in nvim
  - With arguments: opens specified files in nvim
  - Provides a quick shortcut for opening files in the editor
  - Convenient single-letter command for nvim access

Behavior:
  - Without arguments: opens current directory (.) in nvim
  - With file arguments: opens specified files in nvim
  - Passes all arguments directly to nvim
  - Works exactly like calling nvim directly

Dependencies:
  - nvim (Neovim editor)

Examples:
  n                    # Open current directory in nvim
  n file.txt           # Open file.txt in nvim
  n file1.txt file2.sh # Open multiple files in nvim
  n script.sh          # Open script.sh in nvim

Note: This is a simple wrapper around nvim. Without arguments, it opens
      the current directory, which is useful for browsing files in nvim's
      file explorer. With arguments, it behaves exactly like "nvim <args>".
      The single-letter name makes it quick to type for frequent nvim usage.
EOF
            return 0
            ;;
        pwd)
            cat <<EOF
pwd - Print Working Directory (Enhanced)

Print the current directory path, or copy it to clipboard.

Usage: pwd [options]
       pwd c|C

Description:
  - Overrides the builtin pwd command
  - Prints the current working directory path
  - Can copy the current directory path to clipboard
  - Provides a convenient way to get or copy the current directory

Options:
  c, C          Copy the current directory path to clipboard

Behavior:
  - Without arguments: prints the current working directory (same as builtin pwd)
  - With "c" or "C" as first argument: copies current directory to clipboard
  - Passes through all other arguments to builtin pwd
  - Works exactly like standard pwd for all other operations
  - Clipboard copy uses wl-copy (Wayland clipboard)

Dependencies:
  - None (uses builtin pwd for normal operation)
  - wl-copy (for clipboard copy functionality)

Examples:
  pwd              # Print current directory: /home/user/projects
  pwd c            # Copy current directory to clipboard
  pwd C            # Copy current directory to clipboard (case-insensitive)
  pwd -P           # Print physical directory (passes through to builtin)

Note: This is a wrapper around the builtin pwd command. When called with
      "c" or "C" as the first argument, it copies the current directory
      path to the clipboard using wl-copy. This is useful for quickly
      sharing or pasting directory paths. All other arguments are passed
      through to the builtin pwd command.
EOF
            return 0
            ;;
        silent)
            cat <<EOF
silent - Run Command Silently

Execute a command and suppress all output (stdout and stderr).

Usage: silent <command> [arguments...]

Description:
  - Runs a command without displaying any output
  - Suppresses both standard output (stdout) and error output (stderr)
  - Redirects all output to /dev/null
  - Useful for running commands where output is not needed
  - Preserves the command's exit code

Behavior:
  - Executes the command with all provided arguments
  - Redirects stdout to /dev/null
  - Redirects stderr to /dev/null
  - Returns the exit code of the executed command
  - No output is displayed, regardless of success or failure

Dependencies:
  - None (uses shell redirection)

Examples:
  silent rm old_file.txt        # Delete file without showing output
  silent mkdir -p new/dir       # Create directory silently
  silent cp file1 file2         # Copy file without output
  silent command_that_errors    # Run command, ignore all output

Note: This function is useful when you want to run a command but don't
      need to see its output. The command still executes normally and
      returns its exit code, so you can check for success/failure using
      \$?. All output (both stdout and stderr) is discarded.
EOF
            return 0
            ;;
        swap)
            cat <<EOF
swap - Swap Two Filenames Safely

Exchange the names of two files using a temporary file.

Usage: swap <file1> <file2>

Description:
  - Swaps the names of two files safely
  - Uses a temporary file to ensure atomic operation
  - Verifies both files exist before attempting swap
  - Provides error handling for failed operations
  - Useful for renaming files when you need to exchange their names

Behavior:
  - Checks if both files exist before swapping
  - Uses a temporary file (tmp.$$) as intermediate storage
  - Performs three move operations: file1 -> tmp, file2 -> file1, tmp -> file2
  - Returns error if either file doesn't exist
  - Returns error if any move operation fails
  - Displays success message on completion
  - All operations are atomic (all succeed or all fail)

Dependencies:
  - mv (for moving/renaming files)

Examples:
  swap file1.txt file2.txt      # Swap names of file1.txt and file2.txt
  swap old.txt new.txt          # Swap old.txt and new.txt
  swap script.sh backup.sh      # Swap script.sh and backup.sh

Note: This function safely swaps two filenames using a temporary file.
      The swap operation is atomic - if any step fails, the function
      returns an error and the files remain unchanged. The temporary
      file uses the process ID ($$) to ensure uniqueness. Both files
      must exist for the swap to succeed.
EOF
            return 0
            ;;
        update)
            cat <<EOF
update - System Update Manager

Run system updates via yay, flatpak, and topgrade with bitmask exit code.

Usage: update

Description:
  - Updates system packages using multiple package managers
  - Runs updates for AUR (yay), Flatpak, and system-wide (topgrade)
  - Uses bitmask exit code to indicate which updates failed
  - Requires sudo privileges
  - Automatically skips missing package managers with warnings

Update Components:
  - yay: Updates AUR packages (Arch User Repository)
  - flatpak: Updates Flatpak applications
  - topgrade: Updates system-wide packages (with pacdef, pacstall, flatpak disabled)

Behavior:
  - Prompts for sudo password if needed
  - Checks for each package manager before running updates
  - Runs updates non-interactively (--noconfirm, --assumeyes, --yes)
  - Skips missing tools with warning messages
  - Returns bitmask exit code indicating failures
  - Exit code format: yay_fail * 100 + flatpak_fail * 10 + topgrade_fail

Exit Codes:
  0    - All updates successful
  1    - topgrade failed
  10   - flatpak failed
  11   - flatpak and topgrade failed
  100  - yay failed
  101  - yay and topgrade failed
  110  - yay and flatpak failed
  111  - All updates failed

Dependencies:
  - sudo (required for all updates)
  - yay (optional, for AUR updates)
  - flatpak (optional, for Flatpak updates)
  - topgrade (optional, for system-wide updates)

Examples:
  update              # Run all available system updates

Note: This function requires sudo privileges. It will prompt for your
      password if needed. The function uses a bitmask exit code system
      to indicate which update components failed. Exit code 0 means all
      updates succeeded. Missing package managers are skipped with
      warnings and counted as failures in the exit code. The function
      runs updates non-interactively, so no user confirmation is required
      during the update process.
EOF
            return 0
            ;;
        woof)
            cat <<EOF
woof - Send Desktop Notification

Send a desktop notification with a custom icon.

Usage: woof <message>

Description:
  - Sends a desktop notification using notify-send
  - Displays a custom icon (datadog-white-48.png)
  - Provides a convenient way to send notifications
  - Useful for script completion alerts or reminders

Behavior:
  - Takes a message as argument(s)
  - Sends notification using notify-send
  - Uses a custom icon from ~/.local/share/icons/datadog-white-48.png
  - All arguments are passed as the notification message
  - Notification appears in the system notification area

Dependencies:
  - notify-send (for notification functionality)

Examples:
  woof "Task completed"              # Send notification with message
  woof "Backup finished successfully" # Send notification with longer message
  woof "Reminder: Check email"       # Send reminder notification

Note: This function sends desktop notifications using notify-send. The
      notification will appear in your system's notification area. The
      function uses a custom icon located at
      ~/.local/share/icons/datadog-white-48.png. All arguments are
      combined into the notification message.
EOF
            return 0
            ;;
        xx)
            cat <<EOF
xx - Reopen Terminal

Start a new kitty terminal session in the background and exit current shell.

Usage: xx

Description:
  - Opens a new kitty terminal window in the background
  - Exits the current shell session
  - Effectively "reopens" the terminal
  - Useful for refreshing the terminal environment
  - Runs the new terminal detached from the current process

Behavior:
  - Starts a new kitty terminal session using nohup
  - Runs the new terminal in the background
  - Disowns the background process
  - Exits the current shell (exit code 0)
  - All output from the new terminal is redirected to /dev/null

Dependencies:
  - nohup (for running process in background)
  - kitty (terminal emulator)

Examples:
  xx              # Reopen terminal (start new kitty and exit)

Note: This function is specifically designed for the kitty terminal emulator.
      It starts a new kitty window in the background and immediately exits
      the current shell. This effectively "reopens" the terminal, which can
      be useful for refreshing the environment or starting a clean session.
      The new terminal is completely detached from the current process.
EOF
            return 0
            ;;
        zd)
            cat <<EOF
zd - Change Directory with Zoxide and Display Contents

Change to a directory using zoxide smart jumping and automatically list contents.

Usage: zd <directory>

Description:
  - Changes to a directory using zoxide's smart directory jumping
  - Automatically lists directory contents after changing
  - Falls back to cdd() if zoxide is not available
  - Shows directory path with folder emoji
  - Uses eza if available, otherwise falls back to ls
  - Provides intelligent directory navigation with automatic listing

Behavior:
  - Requires a directory argument
  - Uses zoxide's z command for smart directory jumping
  - Falls back to cdd() if zoxide/z is not available
  - Displays current directory path with 📁 emoji
  - Lists directory contents (uses eza with icons if available)
  - Returns error if directory change fails
  - Does not list contents if directory change fails

Relationship with cdd:
  - zd() is the zoxide-powered version of cdd()
  - Both functions change directory and list contents
  - zd() uses zoxide for intelligent directory jumping (fuzzy matching, frequency)
  - cdd() uses standard path-based directory navigation
  - zd() automatically falls back to cdd() if zoxide is unavailable
  - Use zd() for smart jumping to frequently used directories
  - Use cdd() for explicit path-based navigation

Dependencies:
  - zoxide, z (for smart directory jumping)
  - ls (for listing contents, used by fallback cdd)
  - eza (optional, for enhanced listing with icons)

Examples:
  zd projects              # Jump to frequently used "projects" directory
  zd docs                  # Jump to "docs" directory using zoxide
  zd /tmp                  # Jump to /tmp (works like cdd if zoxide unavailable)

Note: This function uses zoxide for intelligent directory navigation. Zoxide
      learns from your directory usage patterns and provides fuzzy matching,
      making it easy to jump to frequently used directories. If zoxide is not
      available, the function automatically falls back to cdd(), which provides
      the same listing behavior but uses standard path-based navigation. See
      also cdd() for the non-zoxide version.
EOF
            return 0
            ;;
        *)
            if [[ "$__MANUAL_BASE_QUIET_MODE" == "true" ]]; then
                # Quiet mode: just return error without showing list
                return 1
            else
                # Normal mode: show error and list
                echo "No manual entry found for base function: $1"
                echo "Available base functions:"
                echo "  backup        - Backup a single file"
                echo "  backup_all    - Backup all files in current directory"
                echo "  brcversion    - Show BRC version"
                echo "  brcupdate     - Check for BRC updates"
                echo "  calc          - Arithmetic calculator"
                echo "  cd            - Change directory (enhanced)"
                echo "  cdd           - Change directory and display contents"
                echo "  cpuinfo       - CPU usage information"
                echo "  cpx           - Compile and run C++ file"
                echo "  genpassword   - Generate random password"
                echo "  h             - Quick history viewer"
                echo "  mkcd          - Make directory and change into it"
                echo "  n             - Open in Neovim"
                echo "  pwd           - Print working directory (enhanced)"
                echo "  silent        - Run command silently"
                echo "  swap          - Swap two filenames safely"
                echo "  update        - System update manager"
                echo "  woof          - Send desktop notification"
                echo "  xx            - Reopen terminal"
                echo "  zd            - Change directory with zoxide and display contents"
                return 1
            fi
            ;;
    esac
else
    # Show list of available base functions
    cat <<EOF
_BASE_FUNCTIONS.sh - Basic Helper Functions

Core utility functions for common tasks.

Usage: brchelp base [FUNCTION]

Available base functions:
  backup        - Backup a single file
  backup_all    - Backup all files in current directory
  brcversion    - Show BRC version
  brcupdate     - Check for BRC updates
  calc          - Arithmetic calculator
  cd            - Change directory (enhanced)
  cdd           - Change directory and display contents
  cpuinfo       - CPU usage information
  cpx           - Compile and run C++ file
  genpassword   - Generate random password
  h             - Quick history viewer
  mkcd          - Make directory and change into it
  n             - Open in Neovim
  pwd           - Print working directory (enhanced)
  silent        - Run command silently
  swap          - Swap two filenames safely
  update        - System update manager
  woof          - Send desktop notification
  xx            - Reopen terminal
  zd            - Change directory with zoxide and display contents

Examples:
  brchelp base           # Show this list
  brchelp base calc      # Show help for a function (e.g., calc)
  brchelp base cd        # Show help for another function (e.g., cd)

Note: Use "brchelp base <function>" to get detailed help for a specific
      base function. More functions are available - see _BASE_FUNCTIONS.sh
      for the complete list.
EOF
    return 0
fi

