#!/bin/bash
#
# config.sh - Configuration management

load_config() {
    local config_file="$1"

    # If config exists, load it
    if [ -f "$config_file" ]; then
        log_verbose "Loading configuration from: $config_file"
        source "$config_file"
        return 0
    fi

    log "First time setup - configure audio-dl"
    echo ""

    setup_config "$config_file"
}

setup_config() {
    local config_file="$1"

    if [ -z "$BASE_DIRECTORY" ]; then
        read -p "Base audio directory [$HOME/Music]: " INPUT_PATH
        BASE_DIRECTORY="${INPUT_PATH:-$HOME/Music}"
    fi

    if [ -z "$FORMAT" ]; then
        echo "Available formats: mp3, opus, flac, m4a, aac"
        read -p "Default audio format [opus]: " INPUT_FORMAT
        FORMAT="${INPUT_FORMAT:-opus}"
    fi

    if [ -z "$PREFER_THUMBNAIL" ]; then
        read -p "Embed thumbnails as audio art? [true]: " INPUT_PREFERENCE
        PREFER_THUMBNAIL="${INPUT_PREFERENCE:-true}"
    fi

    validate_format "$FORMAT"

    save_config "$config_file"

    echo ""
    log_success "Configuration saved to: $config_file"
    echo ""
}

save_config() {
    local config_file="$1"
    local config_directory="$(dirname "$config_file")"
    mkdir -p "$config_directory"
    echo "$config_file"
    cat >"$config_file" <<EOF
# audio-dl configuration
# Edit this file to change default settings

# Base directory where audio will be downloaded
BASE_DIRECTORY="$BASE_DIRECTORY"

# Default audio format (mp3, opus, flac, m4a, aac)
FORMAT="$FORMAT"

# Embed video thumbnail as album art (true/false)
PREFER_THUMBNAIL="$PREFER_THUMBNAIL"
EOF

    log_verbose "Configuration saved"
}

show_config() {
    local config_file="$1"

    if [ ! -f "$config_file" ]; then
        log_error "No configuration file found at: $config_file"
        log "Run \`audio-dl\` to create initial configuration"
        return 1
    fi

    echo "Current configuration ($config_file):"
    echo ""
    cat "$config_file"
    echo ""
}

reset_config() {
    local config_file="$1"

    if [ ! -f "$config_file" ]; then
        log "No configuration file to reset"
        return 0
    fi

    read -p "Reset configuration? [y/N]: " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -f "$config_file"
        log_success "Configuration reset. Run audio-dl to reconfigure."
    else
        log "Reset cancelled"
    fi
}

set_config() {
    local config_file="$1"
    local key="$2"
    local value="$3"

    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found. Run audio-dl first to create it."
        return 1
    fi

    case "$key" in
    BASE_DIRECTORY | FORMAT | PREFER_THUMBNAIL)
        update_config_value "$config_file" "$key" "$value"
        log_success "Updated $key to: $value"
        ;;
    *)
        log_error "Unknown config key: $key"
        log "Valid keys: BASE_DIRECTORY, FORMAT, PREFER_THUMBNAIL"
        return 1
        ;;
    esac
}

get_config() {
    local config_file="$1"
    local key="$2"

    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found"
        return 1
    fi

    local value=$(grep "^${key}=" "$config_file" | cut -d'"' -f2)

    if [ -z "$value" ]; then
        log_error "Key not found: $key"
        return 1
    fi

    echo "$value"
}

edit_config() {
    local config_file="$1"

    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found"
        return 1
    fi

    local editor="${EDITOR:-nano}"
    "$editor" "$config_file"
    log_success "Configuration updated"
}

update_config_value() {
    local config_file="$1"
    local key="$2"
    local value="$3"

    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found"
        return 1
    fi

    sed -i.bak "s|^${key}=.*|${key}=\"${value}\"|" "$config_file"
    rm -f "${config_file}.bak"
}
