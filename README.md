# Yifi

**See what's slowing you down.**

Yifi is a macOS menu bar app that monitors your network health in real time. It breaks down your connection into easy-to-understand sections so you can quickly pinpoint where problems are — whether it's your Wi-Fi signal, your router, your ISP, or DNS.

## Features

- **Lives in your menu bar** — always one click away, never in the way
- **Real-time diagnostics** updated every 3 seconds across four key areas:
  - **Connection to Router** — link rate, signal strength, noise level
  - **Inside Home Network** — latency, jitter, and packet loss to your router
  - **Connection to Internet** — latency, jitter, and packet loss to the internet
  - **Website Name Lookup** — DNS resolution speed
- **Color-coded status indicators** — green, yellow, and red dots tell you at a glance what's healthy and what's not
- **Sparkline charts** — mini trend graphs for each metric so you can spot patterns over time
- **Liquid Glass design** — native macOS look and feel

## Requirements

- macOS 26.2 or later
- Location permission (required by macOS to access Wi-Fi information)

## Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/naumanahmad/yifi.git
   cd yifi
   ```

2. Open in Xcode (26.3+):
   ```bash
   open yifi.xcodeproj
   ```

3. Build and run (`Cmd + R`). The app will appear in your menu bar.

No third-party dependencies — Yifi uses only Apple frameworks (SwiftUI, CoreWLAN, CoreLocation).

## Permissions

On first launch, Yifi will ask for location access. This is required by macOS for any app that reads Wi-Fi network information — Yifi does not track or store your location.

## License

MIT
