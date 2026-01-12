#!/bin/bash
#
# install.sh - Installation script for audio-dl
#

set -e

INSTALL_DIR="${HOME}/.local/bin"
UTILS_DIR="${HOME}/.local/lib/audio-dl"
SCRIPT_NAME="audio-dl"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Installing audio-dl${NC}"
echo ""

echo "Creating directories"
mkdir -p "$INSTALL_DIR"
mkdir -p "$UTILS_DIR"

echo "Installing main script"
cp "$SCRIPT_NAME" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "Installing library files"
cp -r utils/* "$UTILS_DIR/"

echo "Installing help file"
cp HELP.txt "$UTILS_DIR/"

sed -i.bak "s|^UTILS_DIRECTORY=.*|UTILS_DIRECTORY=\"$UTILS_DIR\"|" "$INSTALL_DIR/$SCRIPT_NAME"
rm -f "$INSTALL_DIR/$SCRIPT_NAME.bak"

echo ""
echo -e "Installation complete!${NC}"
echo ""
echo "Installed to: $INSTALL_DIR/$SCRIPT_NAME"
echo "Utility files: $UTILS_DIR"
echo ""

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}⚠ Note: $INSTALL_DIR is not in your PATH${NC}"
    echo ""
    echo "Add it to your PATH by adding this line to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then reload your shell with: source ~/.bashrc"
    echo ""
else
    echo -e "${GREEN}✓ Installation directory is already in your PATH${NC}"
    echo ""
fi

echo "Checking dependencies..."
if command -v yt-dlp >/dev/null 2>&1; then
    echo -e "${GREEN}✓ yt-dlp is installed${NC}"
else
    echo -e "${YELLOW}⚠ yt-dlp is not installed${NC}"
    echo "Install with: pip install yt-dlp"
fi

if command -v ffmpeg >/dev/null 2>&1; then
    echo -e "${GREEN}✓ ffmpeg is installed${NC}"
else
    echo -e "${YELLOW}⚠ ffmpeg is not installed (recommended)${NC}"
    echo "Install with:"
    echo "  Arch Linux: sudo pacman -S ffmpeg"
    echo "  Ubuntu/Debian: sudo apt install ffmpeg"
    echo "  macOS: brew install ffmpeg"
fi

echo ""
echo "Run 'audio-dl --help' to get started!"
