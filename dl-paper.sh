#!/usr/bin/env bash

readonly __DL_PAPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$__DL_PAPER_DIR/_DEPENDENCY_CHECK.sh"

# List formats or download a wallpaper clip with yt-dlp
dl-paper() {
    local first="$1"
    local second="$2"
    local third="$3"

    [[ -z "$first" ]] && return 1

    [[ "${first^^}" == "DOWN" || "${first^^}" == "D" || "${first^^}" == "-" ]] && {
        if ! ensure_commands_present --caller "dl-paper" yt-dlp ffmpeg; then
            return 123
        fi
        yt-dlp --downloader ffmpeg --downloader-args "ffmpeg_i:-ss 60 -to 300" -f "$second" "$third"
        return 0
    }

    if ! ensure_commands_present --caller "dl-paper" yt-dlp; then
        return 123
    fi
    yt-dlp -F "$first"
    return 0
}

