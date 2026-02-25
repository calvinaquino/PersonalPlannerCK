# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project (no SPM or CocoaPods). Open `personal-planner.xcodeproj` in Xcode.

```bash
# Build from command line
xcodebuild -project personal-planner.xcodeproj -scheme personal-planner -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build

# There are no tests currently
```

**Requirements:** iOS 15.0+, Xcode with Swift support. No external dependencies.

## Architecture

**Personal financial/shopping planning iOS app** with CloudKit sync. UI is in Brazilian Portuguese.

### Data Layer

- **`Cloud`** (singleton) — CloudKit operations against `iCloud.com.calvinaquino.planner` public database. Handles fetch, modify, delete, and subscription management for remote notifications.
- **`Store`** (singleton) — In-memory state holder with typed `Cache<T>` instances for each record type. On init, fetches all data from CloudKit.
- **`Cache<T>`** — Generic in-memory cache backed by `CurrentValueSubject<[T], Never>`. Views subscribe to the Combine publisher for reactive updates.
- **`Storage`** — Simple `[String: Record]` dictionary for quick ID-based lookups.

### Record Model Hierarchy

Base class `Record` wraps `CKRecord`. Behavior is composed via protocols:
- `Named`, `Priced`, `Valued`, `Completable`, `Needed`, `Dated`, `Categorized`

Six record types: `ShoppingItem`, `ShoppingCategory`, `TransactionItem`, `TransactionCategory`, `GoalItem`, `GoalCategory`.

### Data Flow

```
View action → Record.save() → Store cache update → Cloud.modify() → CloudKit
CloudKit notification → AppDelegate → Cloud.handleCreatedOrUpdatedRecord() → Cache update → Combine publisher → SwiftUI redraw
```

### View Layer

SwiftUI with TabView (3 tabs: Shopping, Tasks, Goals). Each feature follows a consistent pattern:
- `[Feature]ItemListView` — main list with `.searchable` filtering
- `[Feature]ItemList` — sectioned list component
- `[Feature]ItemRow` — row component
- `[Feature]ItemFormView` / `[Feature]CategoryFormView` — create/edit forms

**Shared components** in `Views/Common/`: `StackNavigationView`, `SectionView`, `RefreshButton`, `FilterButton`, `RoundedRow`, `MonthPicker`.

### Key Singletons

- `Store.shared` — data cache
- `Cloud.shared` — CloudKit access
- `FormViewManager.shared` — form presentation state

## Project Structure

```
personal-planner/
├── PersonalPlannerApp.swift    # @main SwiftUI entry point
├── AppDelegate.swift           # CloudKit remote notification handling
├── Data/                       # Models, CloudKit ops, Store/Cache
├── Views/                      # SwiftUI views organized by feature
│   ├── Common/                 # Shared UI components
│   ├── Shopping/
│   ├── Transaction/
│   ├── Goal/
│   └── Task/                   # Placeholder (TBD)
└── Utils/                      # FormViewManager, conversions, colors
```

## Notes

- The Core Data model (`personal_planner.xcdatamodeld`) is legacy/unused — the app uses CloudKit directly with in-memory caching.
- Tasks tab is a placeholder — not yet implemented.
- `CloudKitEncoder.swift` / `CloudKitDecoder.swift` are stubbed out (TBD).
- App uses `@UIApplicationDelegateAdaptor` for CloudKit push notification handling.
