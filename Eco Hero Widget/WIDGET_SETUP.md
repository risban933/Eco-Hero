# Eco Hero Widget Setup Guide

This guide explains how to add the widget extension to the Xcode project.

## Prerequisites

- Xcode 15.0 or later
- iOS 18.0 deployment target
- Apple Developer account (for App Groups capability)

## Step 1: Create Widget Extension Target

1. In Xcode, select **File > New > Target**
2. Choose **Widget Extension**
3. Name it: `Eco Hero Widget`
4. Language: Swift
5. Uncheck "Include Configuration App Intent"
6. Click **Finish**
7. When prompted to activate the scheme, click **Activate**

## Step 2: Configure App Groups

### Main App Target
1. Select the main `Eco Hero` target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Create a new group: `group.eco.hero.shared`

### Widget Target
1. Select the `Eco Hero Widget` target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Select the same group: `group.eco.hero.shared`

## Step 3: Replace Generated Files

Replace the auto-generated widget files with the files from this directory:

1. Delete the auto-generated `Eco_Hero_Widget.swift` (or similar)
2. Copy `EcoHeroWidget.swift` into the widget target

## Step 4: Configure Build Settings

### Widget Target Build Settings
1. Set **Deployment Target**: iOS 18.0
2. Enable **Include this target in "Build" action** under build settings

## Step 5: Update Info.plist

Ensure the widget's Info.plist has:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>
```

## Project Structure After Setup

```
Eco-Hero/
├── Eco Hero/                    # Main app
│   └── Services/
│       └── WidgetDataProvider.swift  # Syncs data to widget
├── Eco Hero Widget/             # Widget extension
│   ├── EcoHeroWidget.swift      # Widget implementation
│   └── Assets.xcassets/         # Widget assets (if needed)
└── Eco Hero.xcodeproj
```

## How It Works

### Data Flow
1. Main app updates `UserProfile` with impact metrics
2. `UserProfile.updateImpactMetrics()` calls `syncToWidget()`
3. `WidgetDataProvider` writes to shared UserDefaults
4. Widget timeline provider reads from shared UserDefaults
5. WidgetKit refreshes the widget display

### Shared Data Keys
- `streak` - Current day streak (Int)
- `level` - Current level (Int)
- `xpProgress` - XP progress within level (Double, 0-1)
- `carbonSavedKg` - Total CO₂ saved (Double)
- `waterSavedLiters` - Total water saved (Double)
- `plasticSavedItems` - Total plastic items avoided (Int)
- `displayName` - User's display name (String)

## Widget Sizes

### Small Widget (systemSmall)
- Shows streak and level progress
- Minimal, glanceable design

### Medium Widget (systemMedium)
- Shows streak, level, and impact stats
- Full dashboard-style view

## Testing

1. Build and run the main app first
2. Log some activities to populate data
3. Add the widget from the home screen widget gallery
4. Verify data appears correctly

## Troubleshooting

### Widget Shows Placeholder Data
- Ensure App Groups are configured on both targets
- Verify the suite name matches: `group.eco.hero.shared`
- Check that `WidgetDataProvider` is being called

### Widget Not Refreshing
- Call `WidgetDataProvider.shared.reloadWidgets()` after data changes
- Timeline refresh is limited by iOS (usually every 15 minutes minimum)

### Build Errors
- Ensure deployment targets match (iOS 18.0)
- Clean build folder and rebuild
