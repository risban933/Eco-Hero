# Repository Guidelines

## Project Structure & Module Organization
- `Eco Hero/` contains the SwiftUI app. Major subfolders: `Views/` (UI screens such as Dashboard, LogActivity, WasteSorting), `ViewModels/` (state containers), `Services/` (AI, camera, sync, notifications), `Models/` (SwiftData entities, enums), `Utilities/` (constants, extensions), and `Resources/` (ML assets, sounds, datasets).
- `Eco HeroTests/` and `Eco HeroUITests/` mirror the same structure; add new tests alongside the feature under test (e.g., `Views/Dashboard` → `Eco HeroTests/DashboardTests.swift`).
- `scripts/` hosts helper tooling; document required parameters at the top of each script.

## Build, Test, and Development Commands
- `xcodebuild -scheme "Eco Hero" -destination 'platform=iOS Simulator,name=iPhone 16' build` — primary CI build; use before opening PRs.
- `xcodebuild test -scheme "Eco Hero" -destination 'platform=iOS Simulator,name=iPhone 16'` — runs unit + UI suites.
- `swift run swiftlint` (optional) — run local lint checks if SwiftLint is installed.
- Device testing: run from Xcode targeting iOS 26+ hardware to exercise Foundation Models and camera classifiers.

## Coding Style & Naming Conventions
- Swift 5.10, 4-space indentation, follow Swift API Design Guidelines. Keep one top-level type per file, matching filename (`WasteClassifierService.swift`).
- Use `@Observable` for services shared via `.environment(_)`, `@MainActor` on UI-bound APIs, and favor structs for view-only helpers.
- Colors, spacing, and typography should come from `AppConstants` or asset catalogs (avoid hard-coded literals).

## Testing Guidelines
- Prefer deterministic tests; mock `FoundationContentService` and camera feeds to avoid relying on Apple Intelligence or hardware sensors.
- Unit test naming: `test_WhenCondition_ThenExpectation`. UI tests should assert copy and accessibility identifiers.
- Run `xcodebuild test` before pushing and when modifying SwiftData models, add migration/regression tests.

## Commit & Pull Request Guidelines
- Use descriptive, present-tense commits (`fix: ensure Info.plist defines CFBundleExecutable`).
- Each PR should summarize scope, list testing performed (device + simulator), attach screenshots for UI-affecting work, and link related issues/challenges.
- Rebase before merging; keep PRs scoped (prefer ≤500 LOC diffs) to simplify review.

## Security & Configuration Tips
- Never commit API keys, ML credentials, or provisioning profiles. For Apple Intelligence access, rely on local `.xcconfig` or user-specific build settings.
- Validate that new features handle the iOS 26 minimum gracefully (e.g., guard Apple-only APIs with availability checks).
