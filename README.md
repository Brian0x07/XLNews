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
| GraphQL Client (Native) | Apollo iOS 1.25.2 |
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
open NewsApp.xcworkspace
# Select the "NewsApp" scheme → choose a simulator or device → Cmd+R
```

> **Note:** Always open `NewsApp.xcworkspace` (not `NewsApp.xcodeproj`), because CocoaPods manages the workspace.

### Building a Release Bundle

```bash
npm run bundle:ios
# Output: ios/main.jsbundle
```

This produces an offline JS bundle for production builds. Set the Xcode build configuration to **Release** and it will load the pre-bundled file instead of connecting to Metro.

## Project Structure

```
News/
├── NewsApp/                     # iOS native code (Swift / ObjC)
│   ├── AppDelegate.swift        # App entry point (@main), sets up UINavigationController
│   ├── NewsAppApp.swift          # Original SwiftUI entry (deprecated, see AppDelegate)
│   ├── ContentView.swift        # SwiftUI home screen (categories grid, trending, settings entry)
│   ├── Constants.swift          # Shared constants
│   ├── INMONavigationBar.swift  # Custom navigation bar
│   ├── TranslationOnboardingView.swift
│   ├── SettingsBridge.m         # RN Native Module — syncs theme to native UIKit
│   ├── NewsDataBridge.swift     # RN Native Module — fetches news via Apollo GraphQL
│   ├── NewsDataBridge.m         # ObjC bridge for NewsDataBridge
│   ├── NewsApp-Bridging-Header.h # ObjC ↔ Swift bridging header
│   ├── Services/
│   │   ├── ApolloService.swift  # Apollo client singleton (mock/production modes)
│   │   └── MockNewsData.swift   # Mock GraphQL server responses (local JSON)
│   ├── GraphQL/
│   │   ├── schema.graphqls      # GraphQL schema definition
│   │   ├── Operations/          # .graphql query files
│   │   └── Generated/           # Auto-generated Swift types (apollo-ios-cli)
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
│       ├── RNViewFactory.h/m    # Utility class with factory methods for creating RCTRootViews
│       ├── NavigationBridge.h/m # RN Native Module — pushes NewsDetail onto the native nav stack
│       ├── module.modulemap     # Clang module map, enables `import RNViewFactory` in Swift
│       └── RNViewFactory.podspec
│
├── NewsApp.xcworkspace          # Xcode workspace — ALWAYS open this (not .xcodeproj)
├── NewsApp.xcodeproj            # Xcode project file
├── index.js                     # RN entry — registers App, NewsList, NewsDetail, SettingsPage
├── package.json                 # JS dependencies & scripts
├── package-lock.json            # JS dependency lock file
├── Podfile                      # CocoaPods dependencies
├── Podfile.lock                 # CocoaPods dependency lock file
├── metro.config.js              # Metro bundler config
├── babel.config.js              # Babel config
├── apollo-codegen-config.json   # Apollo iOS code generation config
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
    │          │           │
    │ NewsDataBridge       │ SettingsBridge
    │ (fetchNewsFeed)      │ (applyTheme)
    ▼          │           ▼
 Apollo iOS    │        UIKit theme sync
 (GraphQL)     │
    │          │ NavigationBridge
    ▼          │ (pushNewsDetail)
 Mock/Server   ▼
             Native push
```

**Key design decisions:**

- **Multi-entry RN modules**: Each RN page is registered as a separate `AppRegistry` component. The native side creates an `RCTRootView` for each, allowing independent lifecycle management.
- **Native Bridges**: `NavigationBridge` lets RN trigger native navigation (e.g., push detail page). `SettingsBridge` syncs theme changes from RN back to the native UINavigationBar.
- **Shared Redux store**: All RN components share one Redux store (via `withProvider` HOC) for consistent theme/font-size state.
- **RNViewFactory as local pod**: Encapsulates all RN bootstrapping into a reusable CocoaPods module, keeping the main app target clean.
- **Native-owned networking (Apollo iOS)**: The native side owns the single GraphQL client. RN pages consume data through `NewsDataBridge`, avoiding dual-cache inconsistency and duplicated auth logic — the recommended pattern for brownfield hybrid apps.

## Native Modules Reference

| Module | Method | Direction | Purpose |
|---|---|---|---|
| `NavigationBridge` | `pushNewsDetail(data)` | RN → Native | Push NewsDetail VC onto the nav stack |
| `SettingsBridge` | `applyTheme(theme)` | RN → Native | Switch native nav bar between dark/light |
| `NewsDataBridge` | `fetchNewsFeed(category)` | RN → Native → Apollo | Fetch news list via GraphQL (returns Promise) |
| `NewsDataBridge` | `fetchArticle(id)` | RN → Native → Apollo | Fetch single article via GraphQL (returns Promise) |

## Configuration

### Theme

The app supports dark and light themes. Theme state lives in Redux (`settingsSlice`) and is applied to:

- **RN side**: via `getColors(theme)` in `theme.ts`
- **Native side**: via `SettingsBridge.applyTheme()` which updates `UINavigationBar` appearance and `window.overrideUserInterfaceStyle`

### Font Size

Three presets — `small`, `medium`, `large` — defined in `theme.ts`. Affects body, title, caption, detail, and detailTitle text sizes across all RN pages.

### GraphQL (Apollo iOS)

News data is fetched via Apollo iOS on the native side and bridged to RN through `NewsDataBridge`. The architecture follows the **"native owns networking"** pattern recommended for brownfield hybrid apps.

- **Schema**: `NewsApp/GraphQL/schema.graphqls` defines `NewsArticle` type and `newsFeed`/`article` queries
- **Generated types**: `NewsApp/GraphQL/Generated/` contains auto-generated Swift types from `apollo-ios-cli`
- **Mock mode** (default): `ApolloService.swift` uses a `MockNewsTransport` that returns local JSON data without a real server
- **Production mode**: Change `useMockData` to `false` and update `graphQLEndpoint` in `ApolloService.swift` to connect a real GraphQL server

Regenerate types after schema changes:

```bash
apollo-ios-cli generate
```

## Troubleshooting

| Issue | Solution |
|---|---|
| `RCTSwiftUI` duplicate symbol | The `Podfile` post_install hook already strips these. Run `pod install` again. |
| Metro bundler can't find entry | Ensure `index.js` exists at the project root. |
| Xcode build fails on `swiftinterface` | The Podfile sets `SWIFT_VERIFY_EMITTED_MODULE_INTERFACE = NO`. Clean build folder (Cmd+Shift+K) and rebuild. |
| Pods not found after clone | Run `npm install && pod install` before opening the workspace. |

## License

Private project. All rights reserved.
