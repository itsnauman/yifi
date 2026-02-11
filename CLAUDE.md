> **Keep in sync**: This file is mirrored in `AGENTS.md`. When editing either file, apply the same changes to both.

## Project Overview

Yifi is a macOS menu bar app (SwiftUI) that monitors network health in real time. It shows Wi-Fi signal quality, router/internet latency, jitter, packet loss, and DNS lookup speed — organized into four diagnostic sections with color-coded status and sparkline charts. No third-party dependencies; uses only Apple frameworks (SwiftUI, CoreWLAN, CoreLocation).

## Build & Run

Open in Xcode 26.3+:
```bash
open yifi.xcodeproj
```
Build: `Cmd+B` | Run: `Cmd+R` (app appears in menu bar, not Dock)

CLI build (unsigned release):
```bash
xcodebuild -project yifi.xcodeproj -scheme yifi -configuration Release -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

No test targets exist. UI testing is done via Xcode previews (`#Preview` blocks in view files).

## Architecture

**Layered design**: Models → Services → Managers → Views

- **`yifiApp.swift`** — App entry point. Uses `MenuBarExtra` scene (LSUIElement, no Dock icon). Owns the global `NetworkMonitor` instance.

- **Models (`NetworkMetric.swift`)** — All domain types in one file: `MetricType`, `MetricStatus` (good/warning/bad/neutral), `MetricAvailability` (with unavailability reasons), `MetricData`, `SectionData`, `NetworkSection`. Metric thresholds are defined here.

- **Services** — System-level probes, each wrapping a macOS CLI tool:
  - `WiFiMetricsCollector` — CoreWLAN reads (link rate, signal, noise). Synchronous.
  - `PingService` — Discovers gateway via `/sbin/route`, sends 10 pings via `/sbin/ping`, calculates latency/jitter/packet loss.
  - `DNSService` — Measures DNS query time via `/usr/bin/dig`.
  - `ShellExecutor` — Async `Process` wrapper with timeout and `Sendable` conformance.

- **Managers** — Business logic coordinators:
  - `NetworkMonitor` (`@Observable`, `@MainActor`) — Central orchestrator. Polls every 3 seconds. Runs router ping, internet ping, and DNS probes concurrently via `async let`. Caches gateway IP with 60-second TTL. Updates 4 `SectionData` arrays.
  - `LocationManager` — Handles macOS location permission (required for CoreWLAN access).

- **Views** — SwiftUI presentation:
  - `MenuBarView` — Main container showing SSID, Wi-Fi band, sections, and permission overlay. Uses Liquid Glass effect (compiler-gated `#if compiler(>=6.2)`).
  - `SectionView` / `MetricRowView` / `SparklineView` — Composable metric display with 30-point history charts.
  - `LocationPermissionOverlay` — Permission request/denial UI.

## Key Patterns

- **Concurrency**: Modern Swift async/await throughout. Background polling loop in `NetworkMonitor.startMonitoring()`. Three probes run concurrently per cycle.
- **Availability tracking**: Metrics have explicit availability states (available/stale/unavailable) with specific reasons — prevents displaying stale or invalid data.
- **Compiler gating**: `#if compiler(>=6.2)` guards Liquid Glass APIs for backward compatibility.
- **No external dependencies**: Everything uses Apple frameworks only.

## CI/CD

GitHub Actions workflow (`.github/workflows/release-unsigned-binary.yml`) builds an unsigned `.app` bundle on release publish, packages it as `yifi.zip`, and uploads to GitHub Releases. Distributed via Homebrew cask (`itsnauman/yifi/yifi`).
