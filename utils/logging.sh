#!/bin/bash
# logging.sh - Logging utility

VERBOSE=${VERBOSE:-false}
QUIET=${QUIET:-false}
LOG_FILE="$HOME/.config/audio-dl/audio-dl.log"

if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

log() {
    [ "$QUIET" = true ] && return
    echo -e "$@"
}

log_verbose() {
    [ "$VERBOSE" = true ] || return
    echo -e "${BLUE}[VERBOSE]${NC} $@" >&2
}

log_error() {
    [ "$QUIET" = true ] && return
    echo -e "${RED}[ERROR]${NC} $@" >&2
}

log_warning() {
    [ "$QUIET" = true ] && return
    echo -e "${YELLOW}[WARNING]${NC} $@" >&2
}

log_success() {
    [ "$QUIET" = true ] && return
    echo -e "${GREEN}[SUCCESS]${NC} $@"
}

log_to_file() {
    local log_directory="$(dirname "$LOG_FILE")"
    mkdir -p "$log_directory" 2>/dev/null
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >>"$LOG_FILE" 2>/dev/null
}

init_logging() {
    local log_directory="$(dirname "$LOG_FILE")"
    mkdir -p "$log_directory" 2>/dev/null
}

init_logging
