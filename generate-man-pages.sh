#!/usr/bin/env bash

# Script to generate man pages from _manual.sh and _manual_base.sh
# This script extracts help text from the manual functions and converts them to man pages

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAN_DIR="$SCRIPT_DIR/man/man1"

# Create man directory if it doesn't exist
mkdir -p "$MAN_DIR"

# Function to escape special groff characters
escape_groff() {
    local text="$1"
    # Escape backslashes first
    text=$(echo "$text" | sed 's/\\/\\\\/g')
    # Escape periods at start of line
    text=$(echo "$text" | sed 's/^\./\\&./')
    # Escape single quotes
    text=$(echo "$text" | sed "s/'/\\\\'/g")
    # Handle variables ($VAR) - make italic
    text=$(echo "$text" | sed 's/\$\([A-Za-z_][A-Za-z0-9_]*\)/\\fI\$\1\\fR/g')
    # Handle inline code (backticks) - make bold
    text=$(echo "$text" | sed 's/`\([^`]*\)`/\\fB\1\\fR/g')
    echo "$text"
}

# Function to convert help text to man page format
convert_to_man_page() {
    local cmd_name="$1"
    local help_text="$2"
    
    # Extract title line (first non-empty line)
    local title_line=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ -n "$line" ]] && [[ -z "$title_line" ]]; then
            title_line="$line"
            break
        fi
    done <<< "$help_text"
    
    # Extract title and description from "command - Description" format
    local title=""
    local desc=""
    # Match pattern: "command - Description" (first dash separates command from description)
    if [[ "$title_line" =~ ^([^[:space:]]+[^[:space:]-]*[^[:space:]]*)[[:space:]]+-[[:space:]]+(.+)$ ]]; then
        title=$(echo "${BASH_REMATCH[1]}" | xargs)
        desc=$(echo "${BASH_REMATCH[2]}" | xargs)
    elif [[ "$title_line" =~ ^([^-]+)-[[:space:]]+(.+)$ ]]; then
        # Fallback: match first dash
        title=$(echo "${BASH_REMATCH[1]}" | xargs)
        desc=$(echo "${BASH_REMATCH[2]}" | xargs)
    else
        # No dash found, use cmd_name as title
        title="$cmd_name"
        desc="$title_line"
    fi
    
    # Use cmd_name as title if extracted title doesn't match cmd_name
    if [[ ! "$title" =~ ^${cmd_name} ]] && [[ "$title" != "$cmd_name" ]]; then
        # Check if cmd_name is in the title line
        if [[ "$title_line" =~ ^${cmd_name}[[:space:]]*- ]]; then
            title="$cmd_name"
            # Extract description after dash
            if [[ "$title_line" =~ ^${cmd_name}[[:space:]]*-[[:space:]]+(.+)$ ]]; then
                desc=$(echo "${BASH_REMATCH[1]}" | xargs)
            fi
        else
            title="$cmd_name"
            desc="BRC command"
        fi
    fi
    
    # Generate man page header
    local man_file="$MAN_DIR/${cmd_name}.1"
    cat > "$man_file" <<EOF
.TH "${cmd_name^^}" "1" "$(date +"%B %d, %Y")" "BRC" "User Commands"
.SH NAME
${cmd_name} \- ${desc}
EOF
    
    # Process help text line by line
    local current_section=""
    local in_synopsis=false
    local skip_first_line=true
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip title line (already processed)
        if [[ "$skip_first_line" == true ]]; then
            if [[ "$line" == "$title_line" ]]; then
                skip_first_line=false
                continue
            fi
        fi
        
        # Skip empty lines at the start
        if [[ -z "$current_section" && -z "$line" ]]; then
            continue
        fi
        
        # Check for section headers (ending with :)
        if [[ "$line" =~ ^([A-Z][a-zA-Z /]+):$ ]]; then
            local section_name="${BASH_REMATCH[1]}"
            current_section="$section_name"
            
            # Map section names to man page sections
            case "$section_name" in
                "Usage")
                    echo ".SH SYNOPSIS" >> "$man_file"
                    in_synopsis=true
                    ;;
                "Description")
                    echo ".SH DESCRIPTION" >> "$man_file"
                    in_synopsis=false
                    ;;
                "Behavior")
                    echo ".SH BEHAVIOR" >> "$man_file"
                    ;;
                "Options")
                    echo ".SH OPTIONS" >> "$man_file"
                    ;;
                "Commands")
                    echo ".SH COMMANDS" >> "$man_file"
                    ;;
                "Modes")
                    echo ".SH MODES" >> "$man_file"
                    ;;
                "Dependencies")
                    echo ".SH DEPENDENCIES" >> "$man_file"
                    ;;
                "Examples")
                    echo ".SH EXAMPLES" >> "$man_file"
                    ;;
                "Files"|"Files Created/Modified")
                    echo ".SH FILES" >> "$man_file"
                    ;;
                "Installation Steps")
                    echo ".SH INSTALLATION" >> "$man_file"
                    ;;
                "Supported Formats")
                    echo ".SH SUPPORTED FORMATS" >> "$man_file"
                    ;;
                "Available Functions")
                    echo ".SH AVAILABLE FUNCTIONS" >> "$man_file"
                    ;;
                "Alias Categories")
                    echo ".SH ALIAS CATEGORIES" >> "$man_file"
                    ;;
                "Available Destinations")
                    echo ".SH AVAILABLE DESTINATIONS" >> "$man_file"
                    ;;
                "Update Components")
                    echo ".SH UPDATE COMPONENTS" >> "$man_file"
                    ;;
                "Configuration"|"Configuration in BRC")
                    echo ".SH CONFIGURATION" >> "$man_file"
                    ;;
                "Environment Variables"|"Environment")
                    echo ".SH ENVIRONMENT" >> "$man_file"
                    ;;
                "Exit Codes")
                    echo ".SH EXIT CODES" >> "$man_file"
                    ;;
                "Features")
                    echo ".SH FEATURES" >> "$man_file"
                    ;;
                "How It Works"|"How it works")
                    echo ".SH HOW IT WORKS" >> "$man_file"
                    ;;
                "How to Use"|"When to Use")
                    echo ".SH USAGE" >> "$man_file"
                    ;;
                "Rollback")
                    echo ".SH ROLLBACK" >> "$man_file"
                    ;;
                "Relationship with "*)
                    local rel_section=$(echo "$section_name" | sed 's/Relationship with //')
                    echo ".SS Relationship with $(echo "$rel_section" | tr '[:lower:]' '[:upper:]')" >> "$man_file"
                    ;;
                "Safety Features")
                    echo ".SH SAFETY" >> "$man_file"
                    ;;
                "Search Behavior"|"Installation"|"Smart Matching")
                    echo ".SH $(echo "$section_name" | tr '[:lower:]' '[:upper:]')" >> "$man_file"
                    ;;
                "Author's Note")
                    echo ".SS AUTHOR'S NOTE" >> "$man_file"
                    ;;
                *)
                    # Default: use as subsection
                    echo ".SS ${section_name}" >> "$man_file"
                    ;;
            esac
            continue
        fi
        
        # Check for numbered list items (1. Item)
        if [[ "$line" =~ ^[[:space:]]*([0-9]+)\.[[:space:]]+(.+)$ ]]; then
            local num="${BASH_REMATCH[1]}"
            local item="${BASH_REMATCH[2]}"
            echo ".TP" >> "$man_file"
            echo ".B ${num}." >> "$man_file"
            item=$(escape_groff "$item")
            echo "$item" >> "$man_file"
            continue
        fi
        
        # Check for list items (starting with "  - ")
        if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+)$ ]]; then
            local item="${BASH_REMATCH[1]}"
            echo ".TP" >> "$man_file"
            item=$(escape_groff "$item")
            echo "$item" >> "$man_file"
            continue
        fi
        
        # Check for numbered list items with closing paren (1) Item)
        if [[ "$line" =~ ^[[:space:]]*([0-9]+)\)[[:space:]]*(.+)$ ]]; then
            local num="${BASH_REMATCH[1]}"
            local item="${BASH_REMATCH[2]}"
            echo ".TP" >> "$man_file"
            echo ".B ${num})" >> "$man_file"
            item=$(escape_groff "$item")
            echo "$item" >> "$man_file"
            continue
        fi
        
        # Check for example lines (lines starting with command or $)
        if [[ "$line" =~ ^[[:space:]]*(\$|[a-zA-Z]) ]] && [[ "$current_section" == "Examples" ]]; then
            echo ".PP" >> "$man_file"
            # Make the command bold
            if [[ "$line" =~ ^[[:space:]]*\$[[:space:]]*(.+)$ ]]; then
                local cmd="${BASH_REMATCH[1]}"
                cmd=$(escape_groff "$cmd")
                echo ".B \$" >> "$man_file"
                echo "$cmd" >> "$man_file"
            elif [[ "$line" =~ ^[[:space:]]*([a-zA-Z][^#]+)([[:space:]]*#.*)?$ ]]; then
                local cmd="${BASH_REMATCH[1]}"
                local comment="${BASH_REMATCH[2]}"
                cmd=$(escape_groff "$cmd")
                echo ".B ${cmd}" >> "$man_file"
                if [[ -n "$comment" ]]; then
                    comment=$(escape_groff "$comment")
                    echo "$comment" >> "$man_file"
                fi
            else
                line=$(escape_groff "$line")
                echo "$line" >> "$man_file"
            fi
            continue
        fi
        
        # Regular paragraph text
        if [[ -n "$line" ]]; then
            # Format synopsis specially
            if [[ "$in_synopsis" == true ]] && [[ "$line" =~ ^[[:space:]]*[a-zA-Z] ]]; then
                echo ".B $(escape_groff "$line")" >> "$man_file"
            else
                line=$(escape_groff "$line")
                echo ".PP" >> "$man_file"
                echo "$line" >> "$man_file"
            fi
        fi
    done <<< "$help_text"
    
    # Add footer
    cat >> "$man_file" <<EOF
.SH SEE ALSO
.BR brchelp (1)
.br
For more information, run: brchelp ${cmd_name}
.SH BUGS
Report bugs at the BRC project repository.
.SH AUTHOR
Tony Pup
EOF
}

# Function to extract help text from heredoc in case statements
extract_help_text() {
    local script_file="$1"
    local in_case=false
    local in_heredoc=false
    local cmd_names=""
    local help_text=""
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check for case entry (e.g., "            analyze-file|analyze_file)")
        # Pattern: lines that start with whitespace and have a command name followed by | or )
        if [[ "$line" =~ ^[[:space:]]+[a-zA-Z0-9_._-]+[|\)] ]]; then
            # Extract command names (everything before closing paren)
            # Remove leading whitespace and trailing )
            cmd_names=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/)$//')
            # Trim whitespace
            cmd_names=$(echo "$cmd_names" | xargs)
            if [[ -n "$cmd_names" ]]; then
                in_case=true
                help_text=""
            fi
            continue
        fi
        
        # Check for cat <<EOF
        if [[ "$in_case" == true ]] && [[ "$line" =~ cat[[:space:]]*\<\<[[:space:]]*EOF ]]; then
            in_heredoc=true
            continue
        fi
        
        # Collect help text
        if [[ "$in_heredoc" == true ]]; then
            # Check for end of heredoc
            if [[ "$line" == "EOF" ]]; then
                in_heredoc=false
                in_case=false
                # Split command names by | and find the best primary name
                IFS='|' read -ra CMD_ARRAY <<< "$cmd_names"
                local primary_cmd=""
                # Find the first valid command name (prefer lowercase, no special chars except - and _)
                for cmd in "${CMD_ARRAY[@]}"; do
                    cmd=$(echo "$cmd" | xargs)
                    # Only process if name is valid
                    if [[ "$cmd" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                        # Prefer lowercase names without leading underscores
                        if [[ -z "$primary_cmd" ]]; then
                            primary_cmd="$cmd"
                        elif [[ "$cmd" =~ ^[a-z] ]] && [[ "$primary_cmd" =~ ^_ ]]; then
                            primary_cmd="$cmd"
                        elif [[ "$cmd" =~ ^[a-z] ]] && [[ "$primary_cmd" =~ ^[A-Z] ]]; then
                            primary_cmd="$cmd"
                        fi
                    fi
                done
                # If we found a primary command, output it once
                if [[ -n "$primary_cmd" ]]; then
                    echo "COMMAND:$primary_cmd"
                    echo -n "$help_text"
                    echo "END_COMMAND"
                fi
                cmd_names=""
                help_text=""
                continue
            fi
            help_text+="$line"$'\n'
        fi
    done < "$script_file"
}

# Function to generate central index man page
generate_index_man_page() {
    local man_file="$MAN_DIR/BRC.1"
    local commands=()
    
    # Collect all generated man page names
    for file in "$MAN_DIR"/*.1; do
        if [[ -f "$file" ]]; then
            local basename=$(basename "$file" .1)
            # Skip the index page itself
            if [[ "$basename" != "BRC" ]]; then
                commands+=("$basename")
            fi
        fi
    done
    
    # Sort commands alphabetically
    IFS=$'\n' sorted_commands=($(sort <<<"${commands[*]}"))
    unset IFS
    
    # Generate the index man page
    cat > "$man_file" <<EOF
.TH "BRC" "1" "$(date +"%B %d, %Y")" "BRC" "User Commands"
.SH NAME
BRC \- BRC Configuration System Command Reference
.SH DESCRIPTION
BRC is a comprehensive bash configuration system that provides numerous
utility functions, aliases, and plugins to enhance your shell experience.
.PP
This manual page provides an index of all available commands and functions
in the BRC system. Each command has its own detailed manual page.
.SH AVAILABLE COMMANDS
.PP
The following commands are available in the BRC system:
.PP
EOF
    
    # Group commands by category
    local main_commands=()
    local base_commands=()
    local config_commands=()
    
    for cmd in "${sorted_commands[@]}"; do
        # Categorize commands
        if [[ "$cmd" =~ ^(_|install|preamble|plugins|aliases) ]]; then
            config_commands+=("$cmd")
        elif [[ "$cmd" =~ ^(backup|backup_all|calc|cd|cdd|cpuinfo|cpx|extract|genpassword|h|mkcd|n|pwd|silent|swap|update|woof|xx|zd)$ ]]; then
            base_commands+=("$cmd")
        else
            main_commands+=("$cmd")
        fi
    done
    
    # Output main commands
    if [[ ${#main_commands[@]} -gt 0 ]]; then
        echo ".SS Main Commands" >> "$man_file"
        echo ".PP" >> "$man_file"
        for cmd in "${main_commands[@]}"; do
            echo ".BR ${cmd} (1)" >> "$man_file"
        done
        echo ".PP" >> "$man_file"
    fi
    
    # Output base commands
    if [[ ${#base_commands[@]} -gt 0 ]]; then
        echo ".SS Base Functions" >> "$man_file"
        echo ".PP" >> "$man_file"
        for cmd in "${base_commands[@]}"; do
            echo ".BR ${cmd} (1)" >> "$man_file"
        done
        echo ".PP" >> "$man_file"
    fi
    
    # Output configuration commands
    if [[ ${#config_commands[@]} -gt 0 ]]; then
        echo ".SS Configuration" >> "$man_file"
        echo ".PP" >> "$man_file"
        for cmd in "${config_commands[@]}"; do
            echo ".BR ${cmd} (1)" >> "$man_file"
        done
        echo ".PP" >> "$man_file"
    fi
    
    # Add usage instructions
    cat >> "$man_file" <<EOF
.SH USAGE
To view the manual page for a specific command, use:
.PP
.B man
.I command
.PP
For example:
.PP
.B man analyze-file
.PP
.B man timer
.PP
You can also use the built-in help system:
.PP
.B brchelp
.I command
.PP
For example:
.PP
.B brchelp timer
.PP
.B brchelp base
.SH SEE ALSO
For more information about BRC, see the individual command manual pages
listed above. Use
.B brchelp
without arguments to see a list of available commands.
.SH AUTHOR
Tony Pup
EOF
}

# Main execution
echo "Generating man pages from _manual.sh..."
while IFS= read -r line; do
    if [[ "$line" == "COMMAND:"* ]]; then
        cmd_name="${line#COMMAND:}"
        help_text=""
    elif [[ "$line" == "END_COMMAND" ]]; then
        if [[ -n "$cmd_name" ]] && [[ -n "$help_text" ]]; then
            echo "  Generating man page for: $cmd_name"
            convert_to_man_page "$cmd_name" "$help_text"
        fi
        cmd_name=""
        help_text=""
    else
        help_text+="$line"$'\n'
    fi
done < <(extract_help_text "$SCRIPT_DIR/_manual.sh")

echo "Generating man pages from _manual_base.sh..."
while IFS= read -r line; do
    if [[ "$line" == "COMMAND:"* ]]; then
        cmd_name="${line#COMMAND:}"
        help_text=""
    elif [[ "$line" == "END_COMMAND" ]]; then
        if [[ -n "$cmd_name" ]] && [[ -n "$help_text" ]]; then
            echo "  Generating man page for: $cmd_name"
            convert_to_man_page "$cmd_name" "$help_text"
        fi
        cmd_name=""
        help_text=""
    else
        help_text+="$line"$'\n'
    fi
done < <(extract_help_text "$SCRIPT_DIR/_manual_base.sh")

echo "Generating central index man page..."
generate_index_man_page

echo ""
echo "Man pages generated in $MAN_DIR"
echo ""
echo "To view a man page:"
echo "  man -l $MAN_DIR/<command>.1"
echo ""
echo "Or:"
echo "  groff -man -Tascii $MAN_DIR/<command>.1 | less"
echo ""
echo "To install man pages (requires sudo):"
echo "  sudo cp -r $MAN_DIR/* /usr/local/share/man/man1/"
echo "  sudo mandb"
