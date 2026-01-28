# BlueStack iOS SDK Demo (UIKit)

An iOS demo app showcasing ad integration and key features of the BlueStack iOS SDK built with Swift and UIKit.

## Features

- Menu-based navigation system with coordinator pattern
- BlueStack SDK integration
- Multiple ad format support:
  - Banner ads (Standard, Large, Leader, Full, Sticky)
  - MREC (Medium Rectangle) ads
  - Interstitial ads
  - Rewarded video ads
- Consent Management Platform (CMP) integration
- Custom UI components with gradient buttons
- Comprehensive logging system
- Storyboard-based UI architecture

## Getting Started

### Prerequisites

- Xcode 16.0 or later
- iOS 13.0 or later
- CocoaPods or Swift Package Manager
- A physical device or simulator

### Installation

#### Option 1: Using CocoaPods

1. Navigate to the project directory:
   ```bash
   cd Swift/BlueStackDemo
   ```
2. Install dependencies using CocoaPods:
   ```bash
   pod install
   ```
3. Open the workspace (not the project):
   ```bash
   open BlueStackDemo.xcworkspace
   ```
4. Build and run the app in Xcode

#### Option 2: Using Swift Package Manager (SPM)

1. Open the project in Xcode:
   ```bash
   cd Swift/BlueStackDemo
   open BlueStackDemo.xcodeproj
   ```
2. In Xcode, go to **File → Add Package Dependencies...**
3. Enter the BlueStack SDK repository URL
4. Select the version or branch you want to use
5. Click **Add Package**
6. Build and run the app in Xcode

> **Note:** If using SPM, you don't need to run `pod install` or use the `.xcworkspace` file.

### Configuration

The demo app comes pre-configured with a BlueStack demo app ID and placement IDs in [`Constants.swift`](BlueStackDemo/Constants.swift:5):

```swift
struct Constants {
    static let appID = "3167505"
    
    struct Placements {
        static let interstitial = "/\(appID)/interstitial"
        static let rewarded = "/\(appID)/rewarded"
        static let mrec = "/\(appID)/mrec"
        static let banner = "/\(appID)/banner"
    }
}
```

**To use your own configuration:**
1. Replace `"3167505"` with your BlueStack app ID
2. Update the placement paths in the `Placements` struct to match your ad unit configuration

## Project Structure

```
BlueStackDemo/
├── AppDelegate.swift              # Application lifecycle
├── SceneDelegate.swift             # Scene lifecycle (iOS 13+)
├── Constants.swift                 # App configuration constants
├── Common/                         # Shared components
│   ├── Core/
│   │   ├── Coordinator/           # Navigation coordinator pattern
│   │   │   ├── AppCoordinator.swift
│   │   │   ├── MenuCoordinator.swift
│   │   │   ├── AppRoute.swift
│   │   │   └── Coordinator.swift
│   │   ├── CMP/                   # Consent Management Platform
│   │   │   ├── CMPManager.swift
│   │   │   ├── CMPManagerFactory.swift
│   │   │   └── DefaultCMPManager.swift
│   │   ├── Logger/                # Logging system
│   │   │   ├── Logger.swift
│   │   │   └── LogLevel.swift
│   │   ├── Menu/                  # Menu container
│   │   │   └── MenuContainerViewController.swift
│   │   ├── Utilties/
│   │   │   └── UIView+Extensions.swift
│   │   ├── GradientButton.swift
│   │   └── StoryboardInstantiable.swift
│   ├── Home/
│   │   └── HomeViewController.swift
│   ├── Menu/
│   │   ├── MenuViewController.swift
│   │   └── MenuTableViewCell.swift
│   ├── Splash/
│   │   └── SplashViewController.swift
│   ├── ViewModel/                 # View models
│   │   ├── AdViewModel.swift
│   │   ├── InlineAdViewModel.swift
│   │   ├── ListItemViewModel.swift
│   │   └── PlaceholderViewModel.swift
│   └── ListTableViewTableCell/    # Reusable cells
├── Banner/                        # Banner ad implementations
│   ├── ViewControllers/
│   │   ├── BaseBannerViewController.swift
│   │   ├── StandardBannerViewController.swift
│   │   ├── LargeBannerViewController.swift
│   │   ├── LeaderBannerViewController.swift
│   │   ├── FullBannerViewController.swift
│   │   └── StickyBannerViewController.swift
│   ├── BannerTableViewCell/
│   │   └── BannerTableViewCell.swift
│   └── ViewModel/
│       └── BannerAdViewModel.swift
├── MREC/                          # Medium Rectangle ads
│   ├── MRECViewController.swift
│   └── TableViewCell/
│       └── MRECTableViewCell.swift
├── Interstitial/                  # Interstitial ads
│   └── InterstitialViewController.swift
├── Reward/                        # Rewarded video ads
│   └── RewardedVideoViewController.swift
└── Assets.xcassets/               # Images and assets
```

## Architecture

### Coordinator Pattern

The app uses the Coordinator pattern for navigation management, providing a clean separation between view controllers and navigation logic:

- [`AppCoordinator`](BlueStackDemo/Common/Core/Coordinator/AppCoordinator.swift) - Main app coordinator
- [`MenuCoordinator`](BlueStackDemo/Common/Core/Coordinator/MenuCoordinator.swift) - Menu navigation coordinator
- [`AppRoute`](BlueStackDemo/Common/Core/Coordinator/AppRoute.swift) - Route definitions

### View Models

The app implements the MVVM pattern with dedicated view models for ad management and list items, ensuring clean separation of concerns.

### Storyboards

UI is built using Storyboards with the [`StoryboardInstantiable`](BlueStackDemo/Common/Core/StoryboardInstantiable.swift) protocol for type-safe view controller instantiation.

## Ad Formats

### Banner Ads
- **Standard Banner** (320x50)
- **Large Banner** (320x100)
- **Leader Banner** (728x90)
- **Full Banner** (468x60)
- **Sticky Banner** (fixed position)

### MREC (Medium Rectangle)
- 300x250 ad format
- Inline table view integration

### Interstitial Ads
- Full-screen ads
- Show on demand

### Rewarded Video Ads
- Video ads with user rewards
- Completion callbacks

## Dependencies

The project supports both CocoaPods and Swift Package Manager for dependency management:

### CocoaPods
- **BlueStack-SDK** - Core advertising SDK

See [`Podfile`](Podfile:7) for complete dependency list.

### Swift Package Manager
Add the BlueStack SDK package dependency in Xcode:
- Go to **File → Add Package Dependencies...**
- Enter the BlueStack SDK repository URL
- Select your desired version

## Logging

The app includes a comprehensive logging system with different log levels:

- Debug
- Info
- Warning
- Error

Access logs through the [`Logger`](BlueStackDemo/Common/Core/Logger/Logger.swift) class.

## Assets

The [`Assets.xcassets`](BlueStackDemo/Assets.xcassets) directory contains app icons, images, and other resources used in the application.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
