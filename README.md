# audio-dl

A [yt-dlp](https://github.com/yt-dlp/yt-dlp) wrapper for Youtube audio downloading. 

## Features
- Download audio from Youtube with automatic organisation
    - Organised by Artist/Album structure
- Embed thumbnails as album art
- Automatic retry on failed downloads
- Multiple audio format support (see [yt-dlp](https://github.com/yt-dlp/yt-dlp))
- Logging and verbose output
- Dry-run mode for testing
- Configurable defaults
- Cross-platform (Linux, macOS)

## Requirements
- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)**
- **ffmpeg** (recommended for format conversion)

## Installation

```bash
# Clone the repository
git clone https://github.com/HappyPotatoHead/audio-dl.git
cd audio-dl

# Run the installation script
./install.sh
```

Manual installation:

```bash
# Copy to your bin directory
cp audio-dl ~/.local/bin/
cp -r lib ~/.local/lib/audio-dl/

# Make executable
chmod +x ~/.local/bin/audio-dl

# Ensure ~/.local/bin is in your PATH
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

Basic Usage

```bash
# Interactive mode (with prompts)
audio-dl

# With the URL (will prompt for artist and album)
audio-dl "https://youtube.com/..."

# With all arguments
audio-dl "https://youtube.com/" "Artist name" "Album name"

# Using flags
audio-dl -u "https://youtube.com/" -a "Artist name" -b "Album name"
```

Batch Download

```txt
# Quoted
"URL" "ARTIST" "ALBUM"

# CSV
URL, ARTIST, ALBUM

# Space Separated
URL, RickAstley, NeverGonnaGiveYouUp

# Comments start with #
# Empty lines and comments are ignored.
```

```bash
audio-dl -t "Path to the text file"
```

Options

```bash
OPTIONS:
    -u, --url       URL          YouTube URL
    -a, --artist    ARTIST       Artist name
    -b, --album     ALBUM        Album name
    -f, --format    FORMAT       Audio format: mp3, opus, flac, m4a, aac
    -t, --text-file TEXT_FILE    File containing the link, artist, and album
    -v, --verbose   Show detailed output
    -q, --quiet     Suppress non-error messages
    -n, --dry-run   Show what will be downloaded without downloading anything
    -d, --debug     yt-dlp verbose mode
    --show-config   Show the stored configurations
    --reset-config  Reset configurations to defaults
    --set-config    Edit specific configuration argument
    --get-config    Retrieve specific configurations
    --edit-config   Edit configurations
    --version       Show version of this package
    -h, --help      Show this help message
```

Examples

```bash
# Download with specific format
audio-dl -u "https://youtube.com/..." -a "Artist name" -b "Album name" -f flac

# Dry run to see what would be downloaded
audio-dl --dry-run -u "https://youtube.com/..."

# Verbose mode for debugging
audio-dl -v -u "https://youtube.com/..." -a "Artist name" -b "Album name"

# Quiet mode for scripts
audio-dl -q -u "https://youtube.com/..." -a "Artist name" -b "Album name"
```

## Configuration

On first run, you will be asked to configure:
- **Base audio directory**: Where to save downloads (default `~/Music`)
- **Default audio format**: Preferred format (see supported format at [yt-dlp](https://github.com/yt-dlp/yt-dlp))
- **Thumbnail preference**: Embed video thumbnails as audio art 

Configuration is saved to:
`~/.config/audio-dl/audio_dl.conf`

### Managing Configuration

```bash
# View current configurations
audio-dl --show-config

# Edit specific configuration argument
audio-dl --set-config FORMAT mp3

# Retrieve specific configurations
audio-dl --get-config FORMAT

# Open configurations in an editor
audio-dl --edit-config

nano ~/.config/audio-dl/audio_dl.conf
```

## Directory structure

Downloads are organised as:

```bash
~/Music/
  ├── Artist_Name/
  │   ├── Album_Name/
  │   │   ├── song1.opus
  │   │   ├── song2.opus
  │   │   └── song3.opus
```

# Logs

Logs are saved to: `~/.config/audio-dl/audio-dl.log`

# Platform Supported

| Platform | Status | Notes |
| --------------- | --------------- | --------------- |
| Linus | ✅ Full | All features supported |
| macOS | ✅ Full | All features supported |
| Windows | ⚠️ Partial  | Works with Git Bash/WSL |

# Troubleshooting

## Missing Dependencies

`yt-dlp: command not found`

Install `yt-dlp`. See [yt-dlp](https://github.com/yt-dlp/yt-dlp)
`ffmpeg` not found

`ffmpeg` is required for audio format conversion. Install it:
- Ubuntu/Debian: `sudo apt install ffmpeg`
- Arch Linux: `sudo pacman -S ffmpeg`
- macOS: `brew intall ffmpeg`
- Windows: Download from [ffmpeg](https://www.ffmpeg.org/)
##  Downloads Failing

- Check Internet connection
- Verify YouTube URL
- Try with `--debug` flag for detailed output
- Check if the video is available in your region

## Permission Denied

```bash
chmod +x ~/.local/bin/audio-dl
```

# Development

```bash
audio-dl/
├── audio-dl              # Main entry point
├── utils/                # Library files
│   ├── logging.sh        # Logging functions
│   ├── validation.sh     # Validation and checks
│   ├── config.sh         # Configuration management
│   └── download.sh       # Download logic
├── HELP.txt              # Help file
├── install.sh            # Installation script
├── README.md             # This file
├── downloads.txt         # Example text file
└── LICENSE               # License file
```

# Testing

```bash
# Run with dry-run to test without downloading
./audio-dl --dry-run -u "https://youtube.com/..." -a "Test" -b "Test"

# Run with verbose for detailed output
./audio-dl -v -u "https://youtube.com/..." -a "Test" -b "Test"
```

# Contributing

Contributions are welcome! Please feel free to submit a pull request.
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

# License

This project is licensed under the MIT License - see the LICENSE file for details.

# Acknowledgements

[yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube downloader
[ffmpeg](https://www.ffmpeg.org/) - Audio/video processing

# Author

Jimmy Ding - [@HappyPotatoHead](https://github.com/HappyPotatoHead)

# Support
If you encounter any issues or have questions:

Check the Troubleshooting section

Open an issue on GitHub

Check [yt-dlp](https://github.com/yt-dlp/yt-dlp) documentation for download-specific issues
