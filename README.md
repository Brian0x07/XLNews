# News

A hybrid iOS news reader app built with **SwiftUI + React Native**. The native shell (SwiftUI) handles the home screen and navigation, while the content pages (news list, news detail, settings) are rendered by React Native, demonstrating a real-world Swift ↔ RN mixed architecture.

## Screenshots

| Home (SwiftUI) | News List (RN) | News Detail (RN) | Settings (RN) |
|:-:|:-:|:-:|:-:|
| Categories grid | FlatList with thumbnails | Full article view | Theme & font size |

## Tech Stack

| Layer | Technology |
|---|---|
| Native Shell | SwiftUI, UIKit, UINavigationController |
| RN Runtime | React Native 0.84 (Bridge mode) |
| State Management | Redux Toolkit + React Redux |
| Networking (Native) | Alamofire 5.9 |
| Image Loading (Native) | Kingfisher 8.0 |
| Layout (Native) | SnapKit 5.7 |
| Animation (Native) | Lottie 4.5 |
| Serialization (Native) | SwiftProtobuf 1.28 |
| Package Management | npm + CocoaPods |

## Prerequisites

- **macOS** 14+
- **Xcode** 16+ (deployment target iOS 18.0)
- **Node.js** 18+ & npm
- **CocoaPods** (`gem install cocoapods`)
- **Ruby** 2.7+ (for CocoaPods)

## Getting Started

```bash
# 1. Clone the repo
git clone <repo-url> && cd News

# 2. Install JS dependencies
npm install

# 3. Install native pods
pod install

# 4. Start Metro bundler
npm start

# 5. Open Xcode workspace & run
open demo.xcworkspace
# Select the "demo" scheme → choose a simulator or device → Cmd+R
```

> **Note:** Always open `demo.xcworkspace` (not `demo.xcodeproj`), because CocoaPods manages the workspace.

### Building a Release Bundle

```bash
npm run bundle:ios
# Output: ios/main.jsbundle
```

This produces an offline JS bundle for production builds. Set the Xcode build configuration to **Release** and it will load the pre-bundled file instead of connecting to Metro.

## Project Structure

```
News/
├── demo/                        # iOS native code (Swift / ObjC)
│   ├── AppDelegate.swift        # App entry point (@main), sets up UINavigationController
│   ├── demoApp.swift            # Original SwiftUI entry (deprecated, see AppDelegate)
│   ├── ContentView.swift        # SwiftUI home screen (categories grid, trending, settings entry)
│   ├── Constants.swift          # Shared constants
│   ├── INMONavigationBar.swift  # Custom navigation bar
│   ├── TranslationOnboardingView.swift
│   ├── NavigationBridge.m       # RN Native Module — pushes NewsDetail from RN
│   ├── SettingsBridge.m         # RN Native Module — syncs theme to native UIKit
│   ├── demo-Bridging-Header.h   # ObjC ↔ Swift bridging header
│   ├── Assets.xcassets/         # App icons and accent colors
│   └── Info.plist
│
├── src/                         # React Native (TypeScript)
│   ├── App.tsx                  # RN home component (demo/debug)
│   ├── NewsList.tsx             # News feed — FlatList with themed cards
│   ├── NewsDetail.tsx           # Full article view
│   ├── SettingsPage.tsx         # Theme & font-size picker
│   ├── withProvider.tsx         # Redux Provider HOC wrapper
│   ├── theme.ts                 # Dark / light color palettes & font-size presets
│   └── store/
│       ├── index.ts             # Redux store configuration
│       └── settingsSlice.ts     # Settings state (theme, fontSize)
│
├── LocalPods/
│   └── RNViewFactory/           # Local CocoaPods — bridges RN view creation into Swift
│       ├── RNViewFactory.h/m    # Singleton factory for creating RCTRootViews
│       ├── NavigationBridge.h/m # Header for cross-module access
│       ├── module.modulemap     # Clang module map, enables `import RNViewFactory` in Swift
│       └── RNViewFactory.podspec
│
├── demo.xcworkspace             # Xcode workspace — ALWAYS open this (not .xcodeproj)
├── demo.xcodeproj               # Xcode project file
├── index.js                     # RN entry — registers App, NewsList, NewsDetail, SettingsPage
├── package.json                 # JS dependencies & scripts
├── package-lock.json            # JS dependency lock file
├── Podfile                      # CocoaPods dependencies
├── Podfile.lock                 # CocoaPods dependency lock file
├── metro.config.js              # Metro bundler config
├── babel.config.js              # Babel config
└── app.json                     # RN app name
```

## Architecture

```
┌─────────────────────────────────────┐
│           SwiftUI Shell             │
│  ContentView (Home / Categories)    │
│         UINavigationController      │
└──────────────┬──────────────────────┘
               │ pushViewController
               ▼
┌─────────────────────────────────────┐
│        RNViewFactory (ObjC)         │
│  Creates RCTRootView per module     │
│  Singleton RCTReactNativeFactory    │
└──────────────┬──────────────────────┘
               │
    ┌──────────┼──────────┐
    ▼          ▼          ▼
 NewsList  NewsDetail  SettingsPage
  (RN)       (RN)        (RN)
    │                      │
    │ NavigationBridge     │ SettingsBridge
    │ (pushNewsDetail)     │ (applyTheme)
    ▼                      ▼
  Native push           UIKit theme sync
```

**Key design decisions:**

- **Multi-entry RN modules**: Each RN page is registered as a separate `AppRegistry` component. The native side creates an `RCTRootView` for each, allowing independent lifecycle management.
- **Native Bridges**: `NavigationBridge` lets RN trigger native navigation (e.g., push detail page). `SettingsBridge` syncs theme changes from RN back to the native UINavigationBar.
- **Shared Redux store**: All RN components share one Redux store (via `withProvider` HOC) for consistent theme/font-size state.
- **RNViewFactory as local pod**: Encapsulates all RN bootstrapping into a reusable CocoaPods module, keeping the main app target clean.

## Native Modules Reference

| Module | Method | Direction | Purpose |
|---|---|---|---|
| `NavigationBridge` | `pushNewsDetail(data)` | RN → Native | Push NewsDetail VC onto the nav stack |
| `SettingsBridge` | `applyTheme(theme)` | RN → Native | Switch native nav bar between dark/light |

## Configuration

### Theme

The app supports dark and light themes. Theme state lives in Redux (`settingsSlice`) and is applied to:

- **RN side**: via `getColors(theme)` in `theme.ts`
- **Native side**: via `SettingsBridge.applyTheme()` which updates `UINavigationBar` appearance and `window.overrideUserInterfaceStyle`

### Font Size

Three presets — `small`, `medium`, `large` — defined in `theme.ts`. Affects body, title, caption, and detail text sizes across all RN pages.

## Troubleshooting

| Issue | Solution |
|---|---|
| `RCTSwiftUI` duplicate symbol | The `Podfile` post_install hook already strips these. Run `pod install` again. |
| Metro bundler can't find entry | Ensure `index.js` exists at the project root. |
| Xcode build fails on `swiftinterface` | The Podfile sets `SWIFT_VERIFY_EMITTED_MODULE_INTERFACE = NO`. Clean build folder (Cmd+Shift+K) and rebuild. |
| Pods not found after clone | Run `npm install && pod install` before opening the workspace. |

## License

Private project. All rights reserved.
