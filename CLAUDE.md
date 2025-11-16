# Eco Hero - Project Documentation

## Overview
Eco Hero is an iOS SwiftUI app that helps users track their environmental impact through activity logging, waste sorting with ML classification, challenges, and educational content.

## Project Structure

```
Eco-Hero/
├── Eco Hero/                    # Main source directory (auto-synced by Xcode)
│   ├── Eco_HeroApp.swift       # App entry point, SwiftData & service setup
│   ├── ContentView.swift       # Main tab view
│   ├── Models/                 # Data models
│   │   ├── ActivityCategory.swift   # Activity categories (returns SwiftUI Color)
│   │   ├── EcoActivity.swift        # SwiftData model for logged activities
│   │   ├── UserProfile.swift        # User profile with stats
│   │   ├── Challenge.swift          # Challenge definitions
│   │   ├── WasteBin.swift           # Recycle/Compost enum
│   │   └── WasteSortingResult.swift # SwiftData model for sorting results
│   ├── Views/
│   │   ├── Dashboard/              # Main dashboard
│   │   ├── Activities/             # Activity logging (LogActivityView)
│   │   ├── WasteSorting/           # ML-powered waste classifier
│   │   ├── Challenges/             # User challenges
│   │   ├── Profile/                # User profile & stats
│   │   ├── Onboarding/             # First-time user flow
│   │   └── LearnView.swift         # Educational content
│   ├── Services/
│   │   └── AI/
│   │       ├── WasteClassifierService.swift  # Real-time ML waste classification
│   │       └── FoundationContentService.swift
│   ├── Utilities/
│   │   ├── Constants.swift         # App-wide constants & colors
│   │   └── Extensions.swift        # Helper extensions
│   └── Resources/
│       └── Models/
│           └── WasteClassifier.mlmodel  # CoreML model for waste classification
├── Eco Hero.xcodeproj/         # Xcode project file
├── Info.plist                  # App configuration (at root, NOT in Eco Hero/)
└── Assets.xcassets/            # Moved to Eco Hero/ folder
```

## Key Technical Details

### SwiftData Schema
- `UserProfile` - User stats, XP, streak tracking
- `EcoActivity` - Logged eco-friendly activities with CO2 savings
- `WasteSortingResult` - Waste sorting game results
- `Challenge` - Active and available challenges
- `Achievement` - User achievements

### WasteClassifierService (Important)
Located at: `Eco Hero/Services/AI/WasteClassifierService.swift`

**Features:**
- Real-time camera classification using Vision Framework + CoreML
- **Rolling average smoothing** (15-frame buffer, ~0.5s at 30fps)
- Fallback to color heuristics if ML model unavailable
- Classifies into: `WasteBin.recycle` or `WasteBin.compost`

**Rolling Average Implementation:**
- Buffers last 15 predictions with confidence scores
- Calculates weighted average for each bin type
- Updates UI only when confidence >= 60% or bin changes
- Prevents rapid flickering between classifications
- Buffer clears on session start/stop

### ActivityCategory Colors
`ActivityCategory.color` returns `SwiftUI.Color` directly (not String):
```swift
case .meals: return .green
case .transport: return .blue
case .plastic: return .orange
// etc.
```
Use directly: `category.color` (NOT `Color(category.color)`)

## Build Configuration

### Important Notes
1. **Info.plist** must be at project root (not in `Eco Hero/` folder)
   - Project uses `PBXFileSystemSynchronizedRootGroup` for auto-syncing
   - Placing Info.plist inside causes duplicate output errors

2. **INFOPLIST_FILE** in project.pbxproj points to `Info.plist` (root)

3. **No UIMainStoryboardFile** - SwiftUI app, removed empty key from Info.plist

4. **Target:** iOS 26.0+, iPhone/iPad

## Recent Changes (Nov 2025)

### Rolling Average for Waste Classifier
- Added `predictionBuffer` to smooth ML predictions
- Prevents rapid value changes in real-time classification
- Configurable buffer size (default: 15 frames)
- Stability threshold at 60% confidence

### Color System Fix
- Changed `ActivityCategory.color` from `String` to `Color`
- Eliminated "No color named 'X' found in asset catalog" warnings
- All views now use system colors directly

### Project Structure Fix
- Moved source files into `Eco Hero/` subdirectory
- Fixed missing executable in app bundle
- Resolved `CFBundleExecutable` path issues

## Development Notes

- Uses `@Observable` macro (modern Swift Observation)
- SwiftData for persistence
- AVFoundation for camera capture
- Vision + CoreML for image classification
- Local auth manager (no Firebase currently active)
- Supports both ML model and color-based fallback
