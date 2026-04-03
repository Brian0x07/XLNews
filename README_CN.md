# News

一个使用 **SwiftUI + React Native** 构建的混合架构 iOS 新闻阅读应用。原生层（SwiftUI）负责首页和导航，内容页面（新闻列表、新闻详情、设置）由 React Native 渲染，展示了真实场景下的 Swift ↔ RN 混合开发架构。

## 截图

| 首页 (SwiftUI) | 新闻列表 (RN) | 新闻详情 (RN) | 设置 (RN) |
|:-:|:-:|:-:|:-:|
| 分类宫格 | 带缩略图的 FlatList | 完整文章视图 | 主题与字号 |

## 技术栈

| 层级 | 技术 |
|---|---|
| 原生外壳 | SwiftUI, UIKit, UINavigationController |
| RN 运行时 | React Native 0.84 (Bridge 模式) |
| 状态管理 | Redux Toolkit + React Redux |
| 网络请求（原生） | Alamofire 5.9 |
| 图片加载（原生） | Kingfisher 8.0 |
| 布局（原生） | SnapKit 5.7 |
| 动画（原生） | Lottie 4.5 |
| 序列化（原生） | SwiftProtobuf 1.28 |
| 包管理 | npm + CocoaPods |

## 环境要求

- **macOS** 14+
- **Xcode** 16+（部署目标 iOS 18.0）
- **Node.js** 18+ & npm
- **CocoaPods**（`gem install cocoapods`）
- **Ruby** 2.7+（CocoaPods 依赖）

## 快速开始

```bash
# 1. 克隆仓库
git clone <repo-url> && cd News

# 2. 安装 JS 依赖
npm install

# 3. 安装原生 Pods
pod install

# 4. 启动 Metro 打包服务
npm start

# 5. 打开 Xcode 工作区并运行
open demo.xcworkspace
# 选择 "demo" scheme → 选择模拟器或真机 → Cmd+R
```

> **注意：** 请始终打开 `demo.xcworkspace`（而非 `demo.xcodeproj`），因为 CocoaPods 通过 workspace 管理依赖。

### 构建 Release 离线包

```bash
npm run bundle:ios
# 输出: ios/main.jsbundle
```

此命令会生成用于生产环境的离线 JS Bundle。将 Xcode 构建配置设为 **Release** 后，应用将加载预打包文件而非连接 Metro 开发服务器。

## 项目结构

```
News/
├── demo/                        # iOS 原生代码 (Swift / ObjC)
│   ├── AppDelegate.swift        # 应用入口（@main），初始化 UINavigationController
│   ├── demoApp.swift            # 原始 SwiftUI 入口（已废弃，入口迁移至 AppDelegate）
│   ├── ContentView.swift        # SwiftUI 首页（分类宫格、热门、设置入口）
│   ├── Constants.swift          # 共享常量
│   ├── INMONavigationBar.swift  # 自定义导航栏
│   ├── TranslationOnboardingView.swift
│   ├── NavigationBridge.m       # RN 原生模块 — 从 RN 侧触发推入 NewsDetail 页面
│   ├── SettingsBridge.m         # RN 原生模块 — 将主题变更同步至原生 UIKit
│   ├── demo-Bridging-Header.h   # ObjC ↔ Swift 桥接头文件
│   ├── Assets.xcassets/         # 应用图标和主题色资源
│   └── Info.plist
│
├── src/                         # React Native (TypeScript)
│   ├── App.tsx                  # RN 首页组件（演示/调试用）
│   ├── NewsList.tsx             # 新闻列表 — 带主题卡片的 FlatList
│   ├── NewsDetail.tsx           # 文章详情页
│   ├── SettingsPage.tsx         # 主题与字号选择器
│   ├── withProvider.tsx         # Redux Provider 高阶组件封装
│   ├── theme.ts                 # 深色/浅色调色板 & 字号预设
│   └── store/
│       ├── index.ts             # Redux Store 配置
│       └── settingsSlice.ts     # 设置状态（主题、字号）
│
├── LocalPods/
│   └── RNViewFactory/           # 本地 CocoaPods — 封装 RN 视图创建供 Swift 调用
│       ├── RNViewFactory.h/m    # 单例工厂，用于创建 RCTRootView
│       ├── NavigationBridge.h/m # 跨模块访问头文件
│       ├── module.modulemap     # Clang 模块映射，使 Swift 可 `import RNViewFactory`
│       └── RNViewFactory.podspec
│
├── demo.xcworkspace             # Xcode 工作区 — 必须打开这个（而非 .xcodeproj）
├── demo.xcodeproj               # Xcode 项目文件
├── index.js                     # RN 入口 — 注册 App、NewsList、NewsDetail、SettingsPage
├── package.json                 # JS 依赖与脚本
├── package-lock.json            # JS 依赖锁文件
├── Podfile                      # CocoaPods 依赖配置
├── Podfile.lock                 # CocoaPods 依赖锁文件
├── metro.config.js              # Metro 打包器配置
├── babel.config.js              # Babel 配置
└── app.json                     # RN 应用名称
```

## 架构设计

```
┌─────────────────────────────────────┐
│          SwiftUI 外壳层              │
│  ContentView（首页 / 分类宫格）       │
│        UINavigationController       │
└──────────────┬──────────────────────┘
               │ pushViewController
               ▼
┌─────────────────────────────────────┐
│       RNViewFactory (ObjC)          │
│  按模块名创建 RCTRootView            │
│  单例 RCTReactNativeFactory         │
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
  原生页面跳转          UIKit 主题同步
```

**核心设计决策：**

- **多入口 RN 模块**：每个 RN 页面作为独立的 `AppRegistry` 组件注册。原生侧为每个模块创建独立的 `RCTRootView`，实现独立的生命周期管理。
- **原生桥接模块**：`NavigationBridge` 允许 RN 触发原生导航（如推入详情页）；`SettingsBridge` 将 RN 侧的主题变更同步回原生 UINavigationBar。
- **共享 Redux Store**：所有 RN 组件通过 `withProvider` 高阶组件共享同一个 Redux Store，确保主题/字号状态一致。
- **RNViewFactory 作为本地 Pod**：将所有 RN 启动逻辑封装为可复用的 CocoaPods 模块，保持主工程 target 整洁。

## 原生模块参考

| 模块 | 方法 | 方向 | 用途 |
|---|---|---|---|
| `NavigationBridge` | `pushNewsDetail(data)` | RN → 原生 | 将 NewsDetail 视图控制器推入导航栈 |
| `SettingsBridge` | `applyTheme(theme)` | RN → 原生 | 切换原生导航栏的深色/浅色模式 |

## 配置说明

### 主题

应用支持深色和浅色主题。主题状态保存在 Redux（`settingsSlice`）中，并应用于：

- **RN 侧**：通过 `theme.ts` 中的 `getColors(theme)` 获取对应颜色
- **原生侧**：通过 `SettingsBridge.applyTheme()` 更新 `UINavigationBar` 外观和 `window.overrideUserInterfaceStyle`

### 字号

提供三档预设 — `small`（小）、`medium`（中）、`large`（大） — 定义在 `theme.ts` 中。影响所有 RN 页面的正文、标题、副标题和详情文字大小。

## 常见问题

| 问题 | 解决方案 |
|---|---|
| `RCTSwiftUI` 重复符号 | `Podfile` 的 post_install 钩子已处理。重新执行 `pod install` 即可。 |
| Metro 打包器找不到入口文件 | 确保项目根目录存在 `index.js` 文件。 |
| Xcode 构建 `swiftinterface` 报错 | Podfile 已设置 `SWIFT_VERIFY_EMITTED_MODULE_INTERFACE = NO`。清理构建目录（Cmd+Shift+K）后重新编译。 |
| clone 后找不到 Pods | 打开工作区前先执行 `npm install && pod install`。 |

## 许可证

私有项目，保留所有权利。
