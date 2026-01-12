#!/bin/bash

# validation.sh - Input validation and system checks

check_dependencies() {
    local missing=()

    # Check for yt-dlp
    if ! command -v yt-dlp >/dev/null 2>&1; then
        missing+=("yt-dlp")
    fi

    # Check for ffmpeg (required for audio conversion)
    if ! command -v ffmpeg >/dev/null 2>&1; then
        log_warning "ffmpeg not found - some features may not work"
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing[*]}"
        log_error ""
        return 1
    fi

    log_verbose "All dependencies satisfied"
    return 0
}

check_platform() {
    case "$(uname -s)" in
    Linux*) PLATFORM="Linux" ;;
    Darwin*) PLATFORM="Mac" ;;
    CYGWIN* | MINGW* | MSYS*) PLATFORM="Windows" ;;
    *) PLATFORM="Unknown" ;;
    esac

    export PLATFORM
}

validate_url() {
    local url="$1"

    if [ -z "$url" ]; then
        log_error "URL cannot be empty"
        return 1
    fi

    if [[ ! "$url" =~ ^https?://.*youtu ]]; then
        log_error "Invalid YouTube URL: $url"
        log_error "Expected format: https://youtube.com/watch?v=... or https://youtu.be/..."
        return 1
    fi

    log_verbose "URL validation passed"
    return 0
}

sanitise() {
    local input="$1"

    # Remove invalid filename characters
    local sanitized=$(echo "$input" | tr -d '\/:*?"<>|')

    # Replace spaces with underscores (optional, comment out if you prefer spaces)
    # sanitized=$(echo "$sanitized" | tr ' ' '_')

    # Trim leading/trailing whitespace
    sanitized=$(echo "$sanitized" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Empty post-sanitised
    if [ -z "$sanitized" ]; then
        sanitized="unknown"
    fi

    echo "$sanitized"
}

check_disk_space() {
    local directory="$1"

    mkdir -p "$directory" 2>/dev/null

    local available
    case "$PLATFORM" in
    Linux | Mac)
        available=$(df -P "$directory" 2>/dev/null | awk 'NR==2 {print $4}')
        ;;
    Windows)
        # To-do: One day
        return 0
        ;;
    *)
        return 0
        ;;
    esac

    if [ -z "$available" ] || [ "$available" -eq 0 ] 2>/dev/null; then
        log_verbose "Could not determine available disk space"
        return 0
    fi

    # Warn if less than 1GB (1048576 KB) available
    if [ "$available" -lt 1048576 ]; then
        log_warning "Low disk space: less than 1GB available"
    fi

    log_verbose "Available disk space: $(($available / 1024))MB"
    return 0
}

validate_format() {
    local format="$1"
    local valid_formats=("mp3" "opus" "flac" "m4a" "wav" "aac")

    for valid in "${valid_formats[@]}"; do
        if [ "$format" = "$valid" ]; then
            return 0
        fi
    done

    log_warning "Unknown format: $format (using anyway)"
    log_warning "Common formats: ${valid_formats[*]}"
    return 0
}
