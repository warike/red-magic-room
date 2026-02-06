# Red Magic Room

A minimalist macOS menu bar app that generates ambient noise to help you focus.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

## Features

- **Three noise types**: White, Brown, and Pink noise generated algorithmically
- **Focus timer**: Configurable work/rest cycles (Pomodoro-style)
  - Focus: ∞ / 30 / 40 / 60 minutes
  - Rest: N/A / 5 / 10 / 15 minutes
- **Menu bar only**: Lives in your menu bar, no dock icon
- **Lightweight**: Zero external dependencies, ~200KB
- **Privacy**: No analytics, no network requests, no data collection

## Installation

### Homebrew (Recommended)

```bash
brew tap warike/tools
brew install --cask red-magic-room
```

### Download Release

Download the latest `RedMagicRoom.zip` from [Releases](https://github.com/warike/red-magic-room/releases).

1. Unzip the file
2. Move `RedMagicRoom.app` to your Applications folder
3. **First launch**: Right-click → "Open" (required for unsigned apps)
4. Click "Open" in the security dialog

### Build from Source

Requirements:
- macOS 14.0+
- Swift 5.9+ (included with Xcode Command Line Tools)

```bash
# Clone
git clone https://github.com/warike/red-magic-room.git
cd red-magic-room

# Build and run
./build.sh --run
```

## Usage

1. Click the shield icon in your menu bar
2. Select a noise type (White / Brown / Pink)
3. Adjust volume as needed
4. Optionally set Focus/Rest cycles for timed sessions

Click the active noise type again to stop playback.

## Noise Types

| Type | Character | Best For |
|------|-----------|----------|
| **White** | Equal intensity across frequencies | Masking distractions, tinnitus relief |
| **Brown** | Deeper, rumbling (−6dB/octave) | Deep focus, sleep, relaxation |
| **Pink** | Balanced, natural (−3dB/octave) | Concentration, background ambiance |

## Project Structure

```
red-magic-room/
├── RedMagicRoom/
│   ├── RedMagicRoomApp.swift   # App entry, MenuBarExtra
│   ├── ContentView.swift       # Popover UI
│   ├── NoiseEngine.swift       # AVAudioEngine noise generation
│   ├── NoiseType.swift         # Noise type enum
│   ├── AppState.swift          # Observable state + persistence
│   └── Info.plist              # App configuration
├── AppIcon.icns                # App icon
├── Package.swift               # Swift Package Manager config
└── build.sh                    # Build script
```

## Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

## License

[MIT](LICENSE)

## Acknowledgments

- Audio generation uses Apple's AVAudioEngine
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)
