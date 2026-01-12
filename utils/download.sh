#!/bin/bash

# Retry configuration
MAX_RETRIES=3
RETRY_DELAY=5

attempt_download() {
    local url="$1"
    local destination="$2"
    local format="$3"
    local thumb_opts="$4"
    local debug="$5"

    local attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        log_verbose "Download attempt $attempt of $MAX_RETRIES"

        if perform_download "$url" "$destination" "$format" "$thumb_opts" "$debug"; then
            log_verbose "Download successful on attempt $attempt"
            cleanup_partial_downloads "$destination"
            return 0
        fi

        if [ $attempt -lt $MAX_RETRIES ]; then
            log_warning "Attempt $attempt failed, retrying in ${RETRY_DELAY}s"
            sleep $RETRY_DELAY
        fi

        ((attempt++))
    done

    log_error "Download failed after $MAX_RETRIES attempts"
    cleanup_partial_downloads "$destination"
    return 1
}

batch_download() {
    local file="$1"
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi

    local line_number=0
    local success_count=0
    local fail_count=0

    while IFS= read -r line || [ -n "$line" ]; do
        ((line_number++))

        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue

        local url artist album

        # Format 1: URL "Artist with spaces" "Album with spaces"
        if [[ "$line" =~ ^([^[:space:]]+)[[:space:]]+\"([^\"]+)\"[[:space:]]+\"([^\"]+)\"$ ]]; then
            url="${BASH_REMATCH[1]}"
            artist="${BASH_REMATCH[2]}"
            album="${BASH_REMATCH[3]}"
            log_verbose "Line $line_number: Parsed as quoted format"

        # Format 2: URL, Artist, Album (CSV)
        elif [[ $(awk -F',' '{print NF}' <<<"$line") -eq 3 ]]; then
            IFS=',' read -r url artist album <<<"$line"
            url="${url#"${url%%[![:space:]]*}"}"
            url="${url%"${url##*[![:space:]]}"}"

            artist="${artist#"${artist%%[![:space:]]*}"}"
            artist="${artist%"${artist##*[![:space:]]}"}"

            album="${album#"${album%%[![:space:]]*}"}"
            album="${album%"${album##*[![:space:]]}"}"
            log_verbose "Line $line_number: Parsed as CSV format"

        # Format 3: URL Artist Album (space-separated, album can have spaces)
        elif [[ "$line" =~ ^([^[:space:]]+)[[:space:]]+([^[:space:]]+)[[:space:]]+(.+)$ ]]; then
            url="${BASH_REMATCH[1]}"
            artist="${BASH_REMATCH[2]}"
            album="${BASH_REMATCH[3]}"
            log_verbose "Line $line_number: Parsed as space-separated format"

        else
            log_warning "Line $line_number: Could not parse format"
            log_warning "  Supported formats:"
            log_warning "    URL \"Artist\" \"Album\""
            log_warning "    URL, Artist, Album"
            log_warning "    URL Artist Album"
            log_warning "  Line content: $line"
            ((fail_count++))
            continue
        fi

        if [ -z "$url" ] || [ -z "$artist" ] || [ -z "$album" ]; then
            log_warning "Line $line_number: Invalid format (need: URL ARTIST ALBUM)"
            ((fail_count++))
            continue
        fi

        if ! validate_url "$url"; then
            log_warning "line $line_number: Invalid URL format: $url"
            ((fail_count++))
            continue
        fi

        log "[$line_number] Downloading: $artist - $album"
        log_verbose " URL: $url"

        artist=$(sanitise "$artist")
        album=$(sanitise "$album")

        local destination="${BASE_DIRECTORY}/${artist}/${album}"
        mkdir -p "$destination"

        if [ "$DRY_RUN" = true ]; then
            log "=== DRY RUN MODE ==="
            log "Would download to: $destination"
            log "Format: $FORMAT"
            log "URL: $url"
            log "==================="
            ((success_count++))
            continue
        fi

        if attempt_download "$url" "$destination" "$FORMAT" "$THUMB_OPTS" "$DEBUG"; then
            log_success "[$line_number] Complete: $artist - $album"
            ((success_count++))
        else
            log_error "[$line_number] Failed: $artist - $album"
            ((fail_count++))
        fi

        echo ""
    done <"$file"

    echo ""
    log "BATCH DOWNLOAD COMPLETE"
    log "Successful: $success_count"
    log "Failed: $fail_count"
    log "Total: $((success_count + fail_count))"
}

perform_download() {
    local url="$1"
    local destination="$2"
    local format="$3"
    local thumb_opts="$4"
    local debug="$5"

    local yt_dlp_cmd=(
        yt-dlp
        -x
        --audio-format "$format"
    )

    if [ -n "$thumb_opts" ]; then
        yt_dlp_cmd+=($thumb_opts)
    fi

    yt_dlp_cmd+=(
        --parse-metadata "title:%(artist)s - %(title)s"
        -o "${destination}/%(title)s.%(ext)s"
    )

    if [ "$QUIET" != true ]; then
        yt_dlp_cmd+=(--progress)
    else
        yt_dlp_cmd+=(--no-progress)
    fi

    if [ "$debug" = true ]; then
        yt_dlp_cmd+=(--verbose)
    fi

    yt_dlp_cmd+=("$url")

    if [ "$VERBOSE" = true ]; then
        log_verbose "Executing: ${yt_dlp_cmd[*]}"
    fi

    "${yt_dlp_cmd[@]}"
    return $?
}

cleanup_partial_downloads() {
    local directory="$1"

    if [ ! -d "$directory" ]; then
        return 0
    fi

    log_verbose "Cleaning up partial downloads"

    find "$directory" -name "*.part" -type f -delete 2>/dev/null

    find "$directory" -name "*.ytdl" -type f -delete 2>/dev/null
    log_verbose "Cleanup complete"
}

get_download_info() {
    local url="$1"

    log "Fetching video information"

    yt-dlp --print "%(title)s" \
        --print "%(duration_string)s" \
        --print "%(filesize_approx)s" \
        --no-warnings \
        "$url" 2>/dev/null
}
