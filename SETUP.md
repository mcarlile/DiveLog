# DiveLog — Setup Guide

DiveLog is a SwiftUI iOS app for logging scuba dives, visualizing your dive history on a 3D globe, and managing your dive buddies.

## Requirements

- Xcode 15.0 or later
- iOS 17.0 deployment target
- Swift 5.9+
- An Apple Developer account (for HealthKit entitlements on device)

## Project Setup

### 1. Clone the repository

```bash
git clone https://github.com/mcarlile/divelog.git
cd divelog
```

### 2. Open in Xcode

```bash
open DiveLog.xcodeproj
```

Or open `DiveLog.xcodeproj` directly from Finder.

### 3. Configure signing

1. Select the **DiveLog** target in the project navigator
2. Open the **Signing & Capabilities** tab
3. Set your **Team** to your Apple Developer account
4. Update the **Bundle Identifier** if needed (e.g. `com.yourname.DiveLog`)

### 4. Add HealthKit capability

1. In **Signing & Capabilities**, click **+ Capability**
2. Add **HealthKit**
3. Check **Clinical Health Records** if desired (optional)

### 5. Add Location capability

1. In **Signing & Capabilities**, add **Location** if you want to use live GPS for dive site tagging

### 6. Build & Run

Select your target device or simulator and press **⌘R**.

> **Note:** HealthKit is not available on the iOS Simulator. Run on a physical device to test workout saving/reading.

## Project Structure

```
DiveLog/
├── App/
│   └── DiveLogApp.swift          # App entry point (@main)
├── ContentView.swift              # Root TabView (Globe / Dives / Buddies)
├── Models/
│   ├── Dive.swift                 # Dive & DepthSample data models
│   └── Buddy.swift                # Buddy & CertificationLevel models
├── Services/
│   ├── DiveStore.swift            # ObservableObject — data persistence (UserDefaults)
│   └── HealthKitService.swift     # HealthKit read/write for dive workouts
├── Views/
│   ├── Globe/
│   │   ├── GlobeView.swift        # SceneKit 3D globe with dive-site markers
│   │   └── GlobeContainerView.swift
│   ├── Dives/
│   │   ├── DiveListView.swift     # Searchable, sortable dive list
│   │   ├── DiveDetailView.swift   # Add / edit / view a single dive
│   │   └── DepthProfileView.swift # SwiftUI depth-over-time chart
│   └── Buddies/
│       ├── BuddyListView.swift    # Searchable buddy list
│       ├── BuddyDetailView.swift  # Add / edit / view a buddy
│       └── BuddyTagView.swift     # Chip/capsule tag component
└── Resources/
    └── Info.plist                 # App permissions & metadata
```

## Features

| Feature | Description |
|---|---|
| **3D Globe** | Rotating SceneKit globe with animated cyan markers at each dive location. Tap a marker to open the dive detail. |
| **Dive Log** | Full CRUD for dives — title, location, depth, duration, temperature, visibility, gas mix, tank pressure, and free-text notes. |
| **Depth Profile** | SVG-style SwiftUI chart rendering the depth-over-time profile for each dive. |
| **Buddy Manager** | Track dive buddies with certification level, agency, contact info, and shared dive history. |
| **HealthKit Sync** | Save dives as HKWorkoutActivityType.underwaterDiving workouts and read existing ones back. |
| **Persistence** | All data stored with UserDefaults via JSON encoding; no external dependencies. |

## Customization

### Adding a real Earth texture

Replace the placeholder colour in `GlobeView.swift` with a texture:

1. Add an `earth_texture.jpg` (2048×1024 equirectangular) to `Assets.xcassets`
2. The `GlobeView` already loads `UIImage(named: "earth_texture")` — it will pick it up automatically

### Migrating storage to SwiftData

`DiveStore` uses UserDefaults for zero-dependency simplicity. To migrate to SwiftData, conform `Dive` and `Buddy` to `@Model`, replace `DiveStore` with a SwiftData `ModelContainer`, and update the environment injection in `DiveLogApp`.

## Troubleshooting

**HealthKit authorization dialog never appears**
Ensure the HealthKit capability is added and the `Info.plist` keys `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` are present.

**Globe is black**
SceneKit requires a real device or Mac Catalyst for full rendering. On older simulators, fallback to a flat map or skip the globe tab during testing.

**App crashes on launch in simulator**
Confirm the deployment target is iOS 17.0+ and that you are using Xcode 15 or later.

## License

MIT — see LICENSE file for details.
