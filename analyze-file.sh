#!/usr/bin/env bash

readonly __ANALYZE_FILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__ANALYZE_FILE_DIR/_DEPENDENCY_CHECK.sh"

# File Analysis Tool
analyze-file() {
  if ! ensure_commands_present --caller "analyze-file" file stat du wc sha256sum; then
    return 123
  fi

  # Show help if no argument provided or help is requested
  [[ -z "$1" ]] && {
    echo "Usage: analyze-file <file>"
    echo ""
    echo "Provide detailed file analysis and information"
    echo ""
    echo "Description:"
    echo "  - Analyzes files and provides comprehensive information"
    echo "  - Shows file size, permissions, ownership, and type"
    echo "  - Displays line count, word count, and character count for text files"
    echo "  - Generates SHA256 hash for security verification"
    echo "  - Works with any file type"
    echo "  - Provides human-readable output with formatting"
    echo ""
    echo "Dependencies:"
    echo "  - file (file type detection)"
    echo "  - stat (file statistics)"
    echo "  - du (disk usage)"
    echo "  - wc (word count)"
    echo "  - sha256sum (hash generation)"
    echo ""
    echo "Examples:"
    echo "  analyze-file document.txt"
    echo "  analyze-file script.sh"
    echo "  analyze-file image.jpg"
    echo "  analyze-file help"
    echo ""
    echo "Note: Provides different analysis based on file type"
    return 1
  }

  # Show help if help is requested
  [[ "${1^^}" == "HELP" ]] && {
    echo "Usage: analyze-file <file>"
    echo ""
    echo "Provide detailed file analysis and information"
    echo ""
    echo "Description:"
    echo "  - Analyzes files and provides comprehensive information"
    echo "  - Shows file size, permissions, ownership, and type"
    echo "  - Displays line count, word count, and character count for text files"
    echo "  - Generates SHA256 hash for security verification"
    echo "  - Works with any file type"
    echo "  - Provides human-readable output with formatting"
    echo ""
    echo "Dependencies:"
    echo "  - file (file type detection)"
    echo "  - stat (file statistics)"
    echo "  - du (disk usage)"
    echo "  - wc (word count)"
    echo "  - sha256sum (hash generation)"
    echo ""
    echo "Examples:"
    echo "  analyze-file document.txt"
    echo "  analyze-file script.sh"
    echo "  analyze-file image.jpg"
    echo "  analyze-file help"
    echo ""
    echo "Note: Provides different analysis based on file type"
    return 0
  }

  local file="$1"

  # Check if file exists
  if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' does not exist"
    return 1
  fi

  echo -e "\n\033[36m📊 FILE ANALYSIS\033[0m"
  echo "================"
  echo "File: $file"
  echo ""

  # Basic file information
  echo "📏 Size: $(du -h "$file" | cut -f1)"
  echo "📅 Modified: $(stat -c "%y" "$file")"
  echo "🔐 Permissions: $(stat -c "%a" "$file")"
  echo "👤 Owner: $(stat -c "%U:%G" "$file")"
  echo ""

  # File type detection
  local file_type=$(file "$file" | cut -d: -f2)
  echo "📄 Type: $file_type"
  echo ""

  # Text file analysis
  if [[ "$file_type" == *"text"* ]] || [[ "$file_type" == *"ASCII"* ]] || [[ "$file_type" == *"UTF-8"* ]]; then
    echo "📝 Text File Analysis:"
    echo "  Lines: $(wc -l <"$file")"
    echo "  Words: $(wc -w <"$file")"
    echo "  Characters: $(wc -c <"$file")"
    echo "  Characters (no spaces): $(wc -m <"$file")"
    echo ""
  fi

  # Executable file analysis
  if [[ -x "$file" ]]; then
    echo "⚡ Executable File:"
    echo "  Executable: Yes"
    echo "  Shebang: $(head -1 "$file" | grep -E '^#!' || echo 'None')"
    echo ""
  fi

  # Archive file detection
  if [[ "$file_type" == *"archive"* ]] || [[ "$file_type" == *"compressed"* ]] || [[ "$file" =~ \.(tar|gz|bz2|zip|rar|7z)$ ]]; then
    echo "📦 Archive File:"
    echo "  Archive type detected"
    echo ""
  fi

  # Image file detection
  if [[ "$file_type" == *"image"* ]] || [[ "$file" =~ \.(jpg|jpeg|png|gif|bmp|svg|webp)$ ]]; then
    echo "🖼️  Image File:"
    echo "  Image type detected"
    echo ""
  fi

  # Video file detection
  if [[ "$file_type" == *"video"* ]] || [[ "$file" =~ \.(mp4|avi|mkv|mov|wmv|flv|webm)$ ]]; then
    echo "🎬 Video File:"
    echo "  Video type detected"
    echo ""
  fi

  # Audio file detection
  if [[ "$file_type" == *"audio"* ]] || [[ "$file" =~ \.(mp3|wav|flac|ogg|aac|m4a)$ ]]; then
    echo "🎵 Audio File:"
    echo "  Audio type detected"
    echo ""
  fi

  # Hash generation
  echo "🔒 SHA256 Hash:"
  echo "  $(sha256sum "$file" | cut -d' ' -f1)"
  echo ""

  # Additional file information
  echo "📋 Additional Info:"
  echo "  Inode: $(stat -c "%i" "$file")"
  echo "  Hard links: $(stat -c "%h" "$file")"
  echo "  Device: $(stat -c "%D" "$file")"
  echo ""

  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    analyze-file "$@"
  exit $?
fi