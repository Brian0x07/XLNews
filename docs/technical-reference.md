# 技术文档

本文档详细说明项目中使用的所有技术细节，包括框架原理、集成方式、数据流、桥接机制、状态管理、主题系统等方方面面。

---

## 目录

- [一、整体架构](#一整体架构)
- [二、SwiftUI 原生层](#二swiftui-原生层)
- [三、React Native 集成](#三react-native-集成)
- [四、RNViewFactory — 本地桥接 Pod](#四rnviewfactory--本地桥接-pod)
- [五、Native Module 桥接机制](#五native-module-桥接机制)
- [六、React Native 页面层](#六react-native-页面层)
- [七、Redux 状态管理](#七redux-状态管理)
- [八、主题系统](#八主题系统)
- [九、字号系统](#九字号系统)
- [十、第三方原生依赖详解](#十第三方原生依赖详解)
- [十一、React Native 依赖详解](#十一react-native-依赖详解)
- [十二、入口注册机制](#十二入口注册机制)
- [十三、导航体系](#十三导航体系)
- [十四、Bridging Header 与模块化](#十四bridging-header-与模块化)
- [十五、Podfile post_install 钩子详解](#十五podfile-post_install-钩子详解)
- [十六、数据模型](#十六数据模型)
- [十七、文件完整清单与职责](#十七文件完整清单与职责)
- [十八、日常开发工作流](#十八日常开发工作流)
- [十九、调试指南](#十九调试指南)
- [二十、实操教程：新增一个 RN 页面](#二十实操教程新增一个-rn-页面)
- [二十一、实操教程：新增一个 Native Module](#二十一实操教程新增一个-native-module)

---

## 一、整体架构

### 1.1 混合架构概览

本项目采用 **Swift 原生外壳 + React Native 内容页** 的混合架构：

```
┌─────────────────────────────────────────────────────┐
│                   iOS 应用进程                        │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │           UINavigationController              │  │
│  │  ┌─────────────┐    ┌──────────────────────┐  │  │
│  │  │ ContentView │    │   RNViewController    │  │  │
│  │  │  (SwiftUI)  │───▶│   ┌──────────────┐   │  │  │
│  │  │   首页/分类   │    │   │ RCTRootView  │   │  │  │
│  │  └─────────────┘    │   │  (RN 渲染层)   │   │  │  │
│  │                     │   └──────────────┘   │  │  │
│  │                     └──────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │            JavaScript 运行时（JSC/Hermes）       │  │
│  │  ┌──────────┐ ┌───────────┐ ┌──────────────┐ │  │
│  │  │ NewsList │ │NewsDetail │ │SettingsPage  │ │  │
│  │  └──────────┘ └───────────┘ └──────────────┘ │  │
│  │              Redux Store (共享)                │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### 1.2 为什么选择混合架构？

| 考量 | 说明 |
|---|---|
| **首页性能** | SwiftUI 原生渲染，启动速度快，动画流畅 |
| **内容页迭代效率** | 新闻列表/详情/设置使用 RN 编写，支持热更新，迭代无需重新提交 App Store |
| **代码复用** | RN 页面理论上可跨 iOS/Android 复用 |
| **渐进式迁移** | 适合在现有原生项目中逐步引入 RN |

### 1.3 Bridge vs New Architecture (Bridgeless)

本项目使用 React Native **Bridge 模式**（非 New Architecture）：

```ruby
# Podfile 中明确关闭 Fabric
use_react_native!(
  :fabric_enabled => false,
  ...
)
```

```objc
// RNViewFactory.m 中的 RNFactoryDelegate 类明确关闭 bridgeless
- (BOOL)bridgelessEnabled {
    return NO;
}
```

**Bridge 模式的工作原理：**

```
Native (ObjC/Swift)  ←──  JSON 序列化  ──→  JavaScript (JSC/Hermes)
                      Bridge（异步消息队列）
```

- Native 和 JS 运行在不同线程
- 通过 Bridge 传递 JSON 消息进行通信
- 所有通信是异步的

**New Architecture（Bridgeless/Fabric）的区别：**

- 使用 JSI（JavaScript Interface）替代 Bridge
- Native 和 JS 可以直接同步调用（无需 JSON 序列化）
- 性能更好，但 API 变化大，部分第三方库尚未完全适配

本项目选择 Bridge 模式是因为稳定性和兼容性更好。

---

## 二、SwiftUI 原生层

### 2.1 应用入口 — AppDelegate.swift

```swift
// 以下为简化版，省略了导航栏外观配置。完整代码见 demo/AppDelegate.swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 1. 创建 UIWindow
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.overrideUserInterfaceStyle = .dark

        // 2. 将 SwiftUI ContentView 包装为 UIHostingController
        let swiftUIVC = UIHostingController(rootView: ContentView())
        swiftUIVC.title = "Discover"

        // 3. 嵌入 UINavigationController
        let nav = UINavigationController(rootViewController: swiftUIVC)

        // 4. 配置深色导航栏外观（此处省略 UINavigationBarAppearance 配置代码）

        // 5. 设置为根视图控制器
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        return true
    }
}
```

**关键技术点：**

| 概念 | 说明 |
|---|---|
| `@main` | Swift 5.3 引入的应用入口标记。标记 `AppDelegate` 而非 `App` struct，因为 React Native 需要 UIKit 生命周期 |
| `UIHostingController` | SwiftUI ↔ UIKit 桥梁。将 SwiftUI View 包装为 UIViewController，使其可以被 UIKit 导航体系管理 |
| `UINavigationController` | UIKit 的导航控制器，管理视图控制器的推入/弹出栈。所有页面（SwiftUI 和 RN）都通过它进行导航 |
| `overrideUserInterfaceStyle` | 强制窗口使用深色模式，覆盖系统设置 |

**为什么不用 SwiftUI 的 `@main App` 入口？**

React Native 需要在应用启动早期初始化其运行时（Bridge/Factory），这些初始化依赖 UIKit 的 `AppDelegate` 生命周期。SwiftUI 的 `App` 协议封装了 UIKit 细节，不方便介入启动流程。因此本项目使用传统的 `AppDelegate` 作为入口。

### 2.2 首页 — ContentView.swift

ContentView 是一个纯 SwiftUI 视图，包含四个区域（Header、Categories Grid、Trending、Settings）：

**分类宫格（Categories Grid）：**

```swift
let categories: [Category] = [
    Category(id: "medical",  name: "Medical",  icon: "cross.case.fill",     accent: ...),
    Category(id: "tech",     name: "Tech",     icon: "cpu.fill",            accent: ...),
    // ... 共 6 个分类
]
```

使用 `LazyVGrid` 实现 3 列自适应网格布局：

```swift
LazyVGrid(columns: [
    GridItem(.flexible(), spacing: 14),
    GridItem(.flexible(), spacing: 14),
    GridItem(.flexible(), spacing: 14),
], spacing: 14) {
    ForEach(categories) { cat in
        CategoryCard(category: cat) {
            pushRNNewsList(category: cat.id, title: cat.name)
        }
    }
}
```

**点击分类后的导航：**

```swift
private func pushRNPage(moduleName: String, title: String) {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first,
          let nav = window.rootViewController as? UINavigationController else {
        return
    }
    let vc = RNViewController(moduleName: moduleName)
    vc.title = title
    nav.pushViewController(vc, animated: true)
}
```

这里的关键是通过 `UIWindowScene` API 获取当前窗口的 `UINavigationController`，然后推入一个承载 RN 视图的 `RNViewController`。

### 2.3 RNViewController

```swift
class RNViewController: UIViewController {
    private let moduleName: String

    init(moduleName: String) {
        self.moduleName = moduleName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)
        let rnView = RNViewFactory.createRootView(withModuleName: moduleName)
        rnView.frame = view.bounds
        rnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(rnView)
    }
}
```

这是一个轻量级 UIViewController，唯一职责是持有一个 RN 渲染的 `RCTRootView`。每次推入新页面时创建新实例。

- `init(moduleName:)`：自定义初始化器，接收 RN 模块名
- `required init?(coder:)`：Swift 要求 UIViewController 子类必须实现此初始化器。因为本类不支持从 Storyboard/XIB 创建，直接 `fatalError`
- `view.backgroundColor`：设置深色背景，避免 RN 视图加载前出现白色闪烁

---

## 三、React Native 集成

### 3.1 集成模式

React Native 官方提供两种集成到现有项目的方式：

| 模式 | 说明 | 本项目 |
|---|---|---|
| **Greenfield**（新建项目） | 从 RN CLI 生成完整项目脚手架 | 否 |
| **Brownfield**（集成到现有项目） | 将 RN 作为依赖集成到已有原生项目 | **是** |

本项目是典型的 Brownfield 集成：先有 Swift 原生项目，后将 RN 作为子系统引入。

### 3.2 RN 运行时初始化

RN 运行时通过 `RNViewFactory` 进行懒加载初始化。首次调用 `createRootView` 时：

1. 创建 `RCTReactNativeFactory` 单例
2. 内部初始化 JS 引擎（JavaScriptCore 或 Hermes）
3. 加载 JS Bundle（开发模式从 Metro 服务器，Release 从本地文件）
4. 创建 Bridge 实例
5. 执行 `index.js` 中注册的模块

### 3.3 JS 引擎

React Native 0.84 默认使用 **Hermes** 引擎：

| 引擎 | 说明 |
|---|---|
| JavaScriptCore (JSC) | Apple 的 JS 引擎（Safari 使用），RN 曾经的默认引擎 |
| Hermes | Meta 专为 RN 优化的 JS 引擎，支持字节码预编译，启动速度更快，内存占用更低 |

### 3.4 JS Bundle 加载

```objc
// RNViewFactory.m
- (NSURL *)bundleURL {
    return [[RCTBundleURLProvider sharedSettings]
        jsBundleURLForBundleRoot:@"index"];
}
```

`RCTBundleURLProvider` 根据构建模式自动选择 Bundle 来源：

| 模式 | Bundle 来源 | URL |
|---|---|---|
| Debug | Metro 开发服务器 | `http://localhost:8081/index.bundle?platform=ios` |
| Release | 本地预打包文件 | `file:///...app.bundle/ios/main.jsbundle` |

---

## 四、RNViewFactory — 本地桥接 Pod

### 4.1 为什么需要 RNViewFactory？

React Native 的核心 API（`RCTRootView`、`RCTBridge` 等）是 Objective-C 编写的。Swift 代码无法直接使用这些 API（除非通过 Bridging Header 暴露大量 RN 头文件）。`RNViewFactory` 封装了所有 RN 交互，对 Swift 层只暴露一个简洁的接口。

### 4.2 公开接口

```objc
// RNViewFactory.h
NS_ASSUME_NONNULL_BEGIN

@interface RNViewFactory : NSObject
+ (UIView *)createRootViewWithModuleName:(NSString *)moduleName;
+ (UIView *)createRootViewWithModuleName:(NSString *)moduleName
                       initialProperties:(NSDictionary *_Nullable)initialProperties;
@end

NS_ASSUME_NONNULL_END
```

- `NS_ASSUME_NONNULL_BEGIN/END`：在这对宏之间声明的参数默认为非空（nonnull），减少到处写 `nonnull` 的冗余
- `_Nullable`：显式标记 `initialProperties` 可以传 `nil`（无初始参数时使用第一个便捷方法即可）

| 方法 | 说明 |
|---|---|
| `createRootViewWithModuleName:` | 创建指定模块名的 RN 视图，无初始参数 |
| `createRootViewWithModuleName:initialProperties:` | 创建 RN 视图并传入初始参数（会作为 React 组件的 props） |

### 4.3 单例模式

```objc
+ (RCTReactNativeFactory *)sharedReactNativeFactory {
    static RCTReactNativeFactory *factory = nil;
    static RNFactoryDelegate *delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [RNFactoryDelegate new];
        factory = [[RCTReactNativeFactory alloc] initWithDelegate:delegate];
    });
    return factory;
}
```

使用 GCD `dispatch_once` 确保 `RCTReactNativeFactory` 只初始化一次。这意味着：
- 所有 RN 页面共享同一个 JS 运行时
- JS 全局状态（包括 Redux Store）在所有 RN 视图间共享
- 第一次创建 RN 视图时会有启动延迟（JS 引擎初始化），后续创建几乎无延迟

### 4.4 initialProperties 参数传递

`initialProperties` 是 Native → RN 的数据传递机制：

```objc
// Native 侧
UIView *rnView = [RNViewFactory createRootViewWithModuleName:@"NewsDetail"
                                           initialProperties:@{
    @"title": @"Breaking News",
    @"body": @"...",
    @"image": @"https://..."
}];
```

```tsx
// RN 侧 — initialProperties 作为组件 props 传入
const NewsDetail: React.FC<Props> = ({title, body, image, source, time}) => {
    // 直接使用 props
};
```

NSDictionary 会被自动转换为 JS 对象。支持的类型映射：

| ObjC 类型 | JS 类型 |
|---|---|
| `NSString` | `string` |
| `NSNumber` | `number` / `boolean` |
| `NSDictionary` | `object` |
| `NSArray` | `array` |
| `NSNull` | `null` |

### 4.5 module.modulemap

```
framework module RNViewFactory {
    umbrella header "RNViewFactory.h"

    export *
    module * { export * }
}
```

Module Map 是 Clang Modules 系统的配置文件，它让 Swift 可以通过 `import RNViewFactory` 直接使用 ObjC 库，而不需要 Bridging Header。本项目在 `RNViewFactory.podspec` 中通过 `MODULEMAP_FILE` 构建设置显式指定了这个 modulemap 文件的路径。

---

## 五、Native Module 桥接机制

### 5.1 什么是 Native Module？

Native Module 是 React Native 的机制，允许 JS 代码调用原生（ObjC/Swift/Java/Kotlin）方法。本项目有两个 Native Module：

### 5.2 NavigationBridge

**文件：** `demo/NavigationBridge.m`

**用途：** 允许 RN 的 NewsList 页面触发原生导航操作（推入 NewsDetail 页面）。

```objc
// 完整代码见 demo/NavigationBridge.m（此处省略了 topViewController 辅助方法）
@implementation NavigationBridge

RCT_EXPORT_MODULE();  // 将此类注册为 RN Native Module，模块名默认为类名

+ (BOOL)requiresMainQueueSetup {
    return YES;  // 模块初始化必须在主线程（因为操作 UI）
}

RCT_EXPORT_METHOD(pushNewsDetail:(NSDictionary *)newsData) {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1. 获取当前导航控制器
        UIViewController *topVC = [self topViewController];
        UINavigationController *nav = topVC.navigationController;
        if (!nav) return;

        // 2. 创建 NewsDetail 的 RN 视图，将 newsData 作为 props 传入
        UIView *rnView = [RNViewFactory createRootViewWithModuleName:@"NewsDetail"
                                                   initialProperties:newsData];

        // 3. 创建视图控制器，添加 RN 视图
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.11 alpha:1.0];
        rnView.frame = vc.view.bounds;
        rnView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [vc.view addSubview:rnView];
        vc.title = @"Detail";

        // 4. 推入导航栈
        [nav pushViewController:vc animated:YES];
    });
}
```

**RN 侧调用：**

```tsx
import {NativeModules, TurboModuleRegistry} from 'react-native';

// 兼容写法：优先尝试 TurboModule，回退到传统 NativeModules
const NavigationBridge =
  TurboModuleRegistry.get('NavigationBridge') ||
  NativeModules.NavigationBridge;

// 调用
NavigationBridge?.pushNewsDetail({
  title: item.title,
  body: item.body,
  image: item.image,
  source: item.source,
  time: item.time,
});
```

**数据流：**

```
NewsList.tsx (RN)
  │ 用户点击新闻条目
  ▼
NavigationBridge.pushNewsDetail({title, body, ...})
  │ JS → Native Bridge 调用（异步）
  ▼
NavigationBridge.m (ObjC)
  │ dispatch_async(main_queue)
  ▼
RNViewFactory.createRootView("NewsDetail", newsData)
  │ 创建新的 RCTRootView
  ▼
nav.pushViewController(vc, animated: YES)
  │ UINavigationController 推入
  ▼
NewsDetail.tsx (RN) — newsData 作为 props 传入
```

### 5.3 SettingsBridge

**文件：** `demo/SettingsBridge.m`

**用途：** 将 RN Settings 页面中的主题切换同步到原生 UIKit 层。

```objc
RCT_EXPORT_METHOD(applyTheme:(NSString *)theme) {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isDark = [theme isEqualToString:@"dark"];

        // 1. 切换 window 的 userInterfaceStyle
        window.overrideUserInterfaceStyle = isDark
            ? UIUserInterfaceStyleDark
            : UIUserInterfaceStyleLight;

        // 2. 更新 NavigationBar 外观
        UINavigationBarAppearance *appearance = ...;
        appearance.backgroundColor = isDark ? darkColor : lightColor;
        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = appearance;
    });
}
```

**RN 侧调用：**

```tsx
const {SettingsBridge} = NativeModules;

const onThemeChange = (value: ThemeMode) => {
  dispatch(setTheme(value));            // 更新 Redux（RN 侧状态）
  SettingsBridge?.applyTheme(value);    // 同步到原生 UIKit
};
```

### 5.4 RCT_EXPORT_MODULE 与 RCT_EXPORT_METHOD 宏

| 宏 | 作用 |
|---|---|
| `RCT_EXPORT_MODULE()` | 将 ObjC 类注册为 RN 模块。可选传入自定义名称，如 `RCT_EXPORT_MODULE(MyBridge)`，默认使用类名 |
| `RCT_EXPORT_METHOD(method)` | 将方法暴露给 JS 调用。方法签名中的参数类型会被自动转换 |
| `requiresMainQueueSetup` | 返回 `YES` 表示模块必须在主线程初始化。涉及 UI 操作的模块必须返回 YES |

### 5.5 线程模型

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Main Thread │     │  JS Thread  │     │ Shadow Thread│
│  (UI 渲染)   │     │ (JS 执行)   │     │ (布局计算)   │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                    │                    │
       │ UI 更新            │ JS 逻辑            │ Yoga 布局
       │ 手势处理            │ 事件处理            │
       │ Native Module      │ 状态管理            │
```

- **Main Thread**：所有 UI 操作必须在此线程。Native Module 的方法默认在后台线程调用，需要 `dispatch_async(dispatch_get_main_queue(), ...)` 切回主线程操作 UI
- **JS Thread**：运行 JavaScript 代码的线程
- **Shadow Thread**：运行 Yoga 布局引擎的线程，将 Flexbox 布局转换为原生坐标

---

## 六、React Native 页面层

### 6.1 NewsList — 新闻列表

**文件：** `src/NewsList.tsx`

**核心组件：** `FlatList`

```tsx
<FlatList
  data={NEWS_DATA}
  keyExtractor={item => item.id}
  renderItem={({item}) => (
    <NewsListItem item={item} onPress={() => onPressItem(item)} ... />
  )}
  contentContainerStyle={styles.listContent}
  ItemSeparatorComponent={() => <View style={styles.separator} />}
  automaticallyAdjustContentInsets={true}
  contentInsetAdjustmentBehavior="automatic"
/>
```

**FlatList vs ScrollView：**

| 组件 | 说明 |
|---|---|
| `ScrollView` | 一次性渲染所有子项，适合少量内容 |
| `FlatList` | 虚拟化列表，只渲染可见区域的项目。适合长列表，内存占用恒定 |

FlatList 内部使用 **窗口化渲染（windowed rendering）**：仅在内存中维护当前可见区域 ± 缓冲区的项目，滚动时动态回收和创建项目。

**contentInsetAdjustmentBehavior：**

设置为 `"automatic"` 让 FlatList 自动适配安全区域（Safe Area）和导航栏高度，避免内容被刘海或底部指示条遮挡。

### 6.2 NewsDetail — 新闻详情

**文件：** `src/NewsDetail.tsx`

接收 `initialProperties` 作为 props：

```tsx
interface Props {
  title: string;
  body: string;
  image: string;
  source: string;
  time: string;
}

const NewsDetail: React.FC<Props> = ({title, body, image, source, time}) => {
    // 从 Redux 读取主题和字号设置
    const {theme, fontSize} = useAppSelector(state => state.settings);
    const colors = getColors(theme);
    const fonts = getFontSizes(fontSize);

    return (
        <ScrollView>
            <Image source={{uri: image}} />
            <Text style={{fontSize: fonts.detailTitle}}>{title}</Text>
            <Text style={{fontSize: fonts.detail}}>{body}</Text>
        </ScrollView>
    );
};
```

**Image 组件：**

```tsx
<Image source={{uri: image}} style={styles.image} />
```

`source={{uri: ...}}` 表示从网络加载图片。RN 的 Image 组件内置：
- 异步网络加载
- 内存缓存（通过 iOS 的 `NSURLCache` 提供有限的 HTTP 缓存，非专用图片磁盘缓存）
- 自动处理图片解码

> **注意：** 如果需要更强大的图片缓存能力（如独立磁盘缓存、缓存策略控制、预加载等），建议使用第三方库如 `react-native-fast-image`。原生侧的 Kingfisher 已具备完整的多级缓存能力。

### 6.3 SettingsPage — 设置页面

**文件：** `src/SettingsPage.tsx`

提供主题和字号的选择界面。使用 `TouchableOpacity` 作为可点击元素：

```tsx
<TouchableOpacity onPress={() => onThemeChange(opt.value)}>
    <Text>{opt.label}</Text>
    {theme === opt.value && <Text style={styles.check}>✓</Text>}
</TouchableOpacity>
```

`TouchableOpacity` 在按下时会降低子组件的透明度，提供触觉反馈。

### 6.4 withProvider — Redux Provider 封装

**文件：** `src/withProvider.tsx`

```tsx
import React from 'react';
import {Provider} from 'react-redux';
import {store} from './store';

export function withProvider<P extends object>(
  Component: React.ComponentType<P>,
): React.FC<P> {
  return (props: P) => (
    <Provider store={store}>
      <Component {...props} />
    </Provider>
  );
}
```

这是一个高阶组件（HOC），将任意 React 组件用 Redux Provider 包裹。在 `index.js` 中注册每个模块时使用：

```javascript
AppRegistry.registerComponent('NewsList', () => withProvider(NewsList));
```

**为什么每个模块都要包裹？**

每个 `AppRegistry.registerComponent` 注册的组件在创建 `RCTRootView` 时会独立渲染。如果不包裹 Provider，组件内部的 `useSelector`/`useDispatch` 会因找不到 Store 而报错。

**关键：** 虽然每个模块独立注册，但它们引用的是同一个 `store` 实例（JavaScript 模块的单例特性）。因此所有 RN 页面的状态是共享的。

---

## 七、Redux 状态管理

### 7.1 为什么使用 Redux？

在多入口 RN 架构中，不同的 RN 页面（NewsList、NewsDetail、SettingsPage）需要共享状态（如主题、字号）。Redux 提供了一个全局单例 Store，任何页面的状态变更都能被其他页面感知。

### 7.2 Store 配置

**文件：** `src/store/index.ts`

```tsx
import {configureStore} from '@reduxjs/toolkit';
import {useDispatch, useSelector, TypedUseSelectorHook} from 'react-redux';
import settingsReducer from './settingsSlice';

export const store = configureStore({
  reducer: {
    settings: settingsReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// 类型安全的自定义 Hooks
export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

`configureStore` 是 Redux Toolkit 的工厂函数，内部做了以下事情：
- 自动配置 Redux DevTools 支持
- 自动添加 `redux-thunk` 中间件
- 自动添加序列化检查中间件（开发模式）
- 创建 Store 实例

### 7.3 Settings Slice

**文件：** `src/store/settingsSlice.ts`

```tsx
export type ThemeMode = 'dark' | 'light';
export type FontSize = 'small' | 'medium' | 'large';

interface SettingsState {
  theme: ThemeMode;
  fontSize: FontSize;
}

const initialState: SettingsState = {
  theme: 'dark',
  fontSize: 'medium',
};

const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {
    setTheme(state, action: PayloadAction<ThemeMode>) {
      state.theme = action.payload;
    },
    setFontSize(state, action: PayloadAction<FontSize>) {
      state.fontSize = action.payload;
    },
  },
});
```

**Slice 概念：** Redux Toolkit 的 `createSlice` 将 action 定义和 reducer 合并在一起。内部使用 Immer 库，允许以"可变"语法编写 reducer（`state.theme = action.payload`），实际上生成的是不可变更新。

### 7.4 状态流动图

```
用户在 SettingsPage 切换主题
         │
         ▼
dispatch(setTheme('light'))    ──→  Redux Store 更新
         │                              │
         ▼                              ▼
SettingsBridge.applyTheme('light')   所有 useAppSelector 的组件重新渲染
         │                              │
         ▼                              ▼
原生 NavigationBar 更新            NewsList / NewsDetail 应用新主题颜色
```

---

## 八、主题系统

### 8.1 双层主题同步

主题切换需要同时更新两个层面：

| 层面 | 机制 | 影响范围 |
|---|---|---|
| RN 层 | Redux `setTheme` → 组件重新渲染 | 所有 RN 页面的背景色、文字颜色、卡片颜色等 |
| Native 层 | `SettingsBridge.applyTheme` → UIKit API | UINavigationBar 颜色、window 的 userInterfaceStyle |

### 8.2 颜色定义

**文件：** `src/theme.ts`

```tsx
const darkColors: ThemeColors = {
  background: '#171719',        // 页面背景
  card: '#1C1C21',              // 卡片/列表项背景
  textPrimary: '#E8E8ED',       // 主要文字（标题等）
  textSecondary: '#8E8E93',     // 次要文字（正文等）
  textTertiary: '#5A5A5E',      // 辅助文字（时间等）
  accent: '#6690FF',            // 强调色（来源标签、链接等）
  divider: '#2A2A30',           // 分割线
  imagePlaceholder: '#2A2A30',  // 图片占位符背景
};

const lightColors: ThemeColors = {
  background: '#F2F2F7',
  card: '#FFFFFF',
  textPrimary: '#1C1C1E',
  textSecondary: '#6C6C70',
  textTertiary: '#AEAEB2',
  accent: '#4A6EE0',
  divider: '#E5E5EA',
  imagePlaceholder: '#E5E5EA',
};
```

颜色方案参考了 Apple Human Interface Guidelines 的系统颜色：
- 深色模式使用低亮度、高对比度配色
- 浅色模式使用 Apple 的 `systemGroupedBackground` 等系统色

### 8.3 原生侧主题同步

```objc
// SettingsBridge.m
if (isDark) {
    appearance.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.13 alpha:1.0]; // #1C1C21
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.40 green:0.56 blue:1.0 alpha:1.0]; // #6690FF
} else {
    appearance.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.98 alpha:1.0];
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.29 green:0.43 blue:0.88 alpha:1.0];
}
```

原生导航栏的颜色与 RN `theme.ts` 中的颜色保持视觉一致。

---

## 九、字号系统

### 9.1 三档预设

**文件：** `src/theme.ts`

```tsx
export function getFontSizes(size: FontSize): FontSizes {
  switch (size) {
    case 'small':
      return {body: 13, title: 14, caption: 11, detail: 14, detailTitle: 19};
    case 'large':
      return {body: 17, title: 18, caption: 14, detail: 18, detailTitle: 26};
    default: // medium
      return {body: 15, title: 16, caption: 12, detail: 16, detailTitle: 22};
  }
}
```

| 字号名 | 用途 | small | medium | large |
|---|---|---|---|---|
| `body` | 列表摘要文字 | 13 | 15 | 17 |
| `title` | 列表标题 | 14 | 16 | 18 |
| `caption` | 来源、时间标签 | 11 | 12 | 14 |
| `detail` | 详情页正文 | 14 | 16 | 18 |
| `detailTitle` | 详情页标题 | 19 | 22 | 26 |

### 9.2 应用方式

字号通过内联样式动态应用：

```tsx
const fonts = getFontSizes(fontSize);

<Text style={{fontSize: fonts.title, color: colors.textPrimary}}>
  {item.title}
</Text>
```

使用内联样式而非 StyleSheet 是因为 `fontSize` 值是动态的（来自 Redux），`StyleSheet.create()` 仅在模块加载时执行一次。

---

## 十、第三方原生依赖详解

### 10.1 Kingfisher 8.0 — 图片加载

```ruby
pod 'Kingfisher', '~> 8.0'
```

**功能：**
- 异步网络图片下载
- 多级缓存（内存 + 磁盘）
- 图片处理管线（缩放、圆角、模糊等）
- 支持 GIF、WebP、SVG
- SwiftUI 原生支持（`KFImage`）

**典型用法（SwiftUI）：**

```swift
KFImage(URL(string: "https://example.com/image.jpg"))
    .resizable()
    .scaledToFill()
```

### 10.2 Lottie 4.5 — 动画

```ruby
pod 'lottie-ios', '~> 4.5'
```

**功能：**
- 播放 Adobe After Effects 导出的 JSON 动画
- 支持交互式动画（进度控制）
- 矢量渲染，缩放无损
- 远比 GIF 体积更小

**典型用法：**

```swift
LottieView(animation: .named("loading"))
    .playing()
    .looping()
```

### 10.3 SwiftProtobuf 1.28 — Protocol Buffers

```ruby
pod 'SwiftProtobuf', '~> 1.28'
```

**功能：**
- Protocol Buffers 的 Swift 实现
- 将 `.proto` 文件编译为 Swift struct
- 比 JSON 序列化更快、体积更小（二进制格式）
- 类型安全，编译时校验

**使用场景：** 与后端 API 通信时使用 Protobuf 而非 JSON，减少网络传输体积和解析耗时。

### 10.4 Alamofire 5.9 — 网络请求

```ruby
pod 'Alamofire', '~> 5.9'
```

**功能：**
- 基于 URLSession 的 HTTP 网络库
- 链式请求构建 API
- 自动 JSON/Codable 解析
- 请求重试、拦截器
- 证书固定（Certificate Pinning）
- 网络可达性监控

**典型用法：**

```swift
AF.request("https://api.example.com/news")
    .validate()
    .responseDecodable(of: [NewsItem].self) { response in
        switch response.result {
        case .success(let items): ...
        case .failure(let error): ...
        }
    }
```

### 10.5 SnapKit 5.7 — Auto Layout

```ruby
pod 'SnapKit', '~> 5.7'
```

**功能：**
- Auto Layout 的 DSL（领域特定语言）封装
- 用简洁的链式语法替代冗长的 `NSLayoutConstraint`

**对比：**

```swift
// 原生 Auto Layout
NSLayoutConstraint.activate([
    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: 20),
    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16),
    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16),
])

// SnapKit
view.snp.makeConstraints { make in
    make.top.equalToSuperview().offset(20)
    make.leading.trailing.equalToSuperview().inset(16)
}
```

> **注意：** 本项目的 SwiftUI 视图不使用 SnapKit（SwiftUI 有自己的布局系统），SnapKit 用于 UIKit 视图。

---

## 十一、React Native 依赖详解

### 11.1 React 19.2

```json
"react": "^19.2.3"
```

React 19 的核心特性：
- **自动批处理（Automatic Batching）**：多个 setState 调用合并为一次渲染
- **并发渲染（Concurrent Rendering）**：可中断的渲染流程
- **use() Hook**：直接在渲染中读取 Promise 和 Context
- **Actions**：简化表单提交和异步状态管理

### 11.2 React Native 0.84

```json
"react-native": "^0.84.1"
```

React Native 0.84 的关键特性：
- 基于 React 19
- Hermes 引擎默认启用
- New Architecture 可选启用（本项目未启用）
- 改进的 Metro 配置 API

### 11.3 Redux Toolkit 2.11

```json
"@reduxjs/toolkit": "^2.11.2"
```

Redux Toolkit（RTK）是 Redux 官方推荐的开发工具包：

| API | 说明 |
|---|---|
| `configureStore` | 简化 Store 创建，自动配置中间件和 DevTools |
| `createSlice` | 合并 Action 定义和 Reducer，使用 Immer 支持"可变"写法 |
| `createAsyncThunk` | 异步操作的标准模式（本项目未使用） |
| `createEntityAdapter` | 规范化数据管理（本项目未使用） |

### 11.4 React Redux 9.2

```json
"react-redux": "^9.2.0"
```

Redux 的 React 绑定库，提供：

| API | 说明 |
|---|---|
| `<Provider store={store}>` | 通过 React Context 将 Store 注入组件树 |
| `useSelector(selector)` | 从 Store 中读取状态，状态变更时触发组件重渲染 |
| `useDispatch()` | 获取 dispatch 函数，用于派发 Action |

---

## 十二、入口注册机制

### 12.1 index.js

**文件：** `index.js`

```javascript
import {AppRegistry} from 'react-native';
import App from './src/App';
import NewsList from './src/NewsList';
import NewsDetail from './src/NewsDetail';
import SettingsPage from './src/SettingsPage';
import {withProvider} from './src/withProvider';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => withProvider(App));
AppRegistry.registerComponent('NewsList', () => withProvider(NewsList));
AppRegistry.registerComponent('NewsDetail', () => withProvider(NewsDetail));
AppRegistry.registerComponent('SettingsPage', () => withProvider(SettingsPage));
```

### 12.2 AppRegistry 机制

`AppRegistry` 是 React Native 的组件注册表。每次调用 `registerComponent(name, componentProvider)` 时：

1. 以 `name` 为键，将 `componentProvider`（一个返回 React 组件的工厂函数）存入全局注册表
2. 当原生侧通过 `RCTRootView(moduleName: name)` 创建视图时，RN 运行时从注册表中查找对应的组件并渲染

**多入口注册的意义：**

传统 RN 应用只注册一个入口（App），内部使用 React Navigation 管理页面。本项目注册了 4 个独立入口，因为：

- 导航由原生 `UINavigationController` 管理（而非 JS 侧的 React Navigation）
- 每个 RN 页面在原生侧是独立的 `UIViewController`
- 这种模式更适合 Brownfield（混合）架构

---

## 十三、导航体系

### 13.1 导航架构

本项目的导航完全由原生 `UINavigationController` 管理：

```
UINavigationController（导航栈）
  │
  ├─ [0] UIHostingController<ContentView>   ← SwiftUI 首页
  │
  ├─ [1] RNViewController("NewsList")       ← RN 新闻列表（用户点击分类后推入）
  │
  └─ [2] UIViewController + RCTRootView     ← RN 新闻详情（从 RN 侧触发推入）
         ("NewsDetail")
```

### 13.2 两种推入方式

**方式一：Swift → RN（ContentView 推入 NewsList）**

```swift
// ContentView.swift
let vc = RNViewController(moduleName: "NewsList")
nav.pushViewController(vc, animated: true)
```

直接在 SwiftUI 中调用 UIKit 导航。

**方式二：RN → Native → RN（NewsList 推入 NewsDetail）**

```tsx
// NewsList.tsx
NavigationBridge?.pushNewsDetail({title, body, ...});
```

```objc
// NavigationBridge.m
UIView *rnView = [RNViewFactory createRootViewWithModuleName:@"NewsDetail"
                                           initialProperties:newsData];
[nav pushViewController:vc animated:YES];
```

RN 无法直接操作原生导航栈，必须通过 Native Module 桥接。

### 13.3 返回导航

返回按钮由 `UINavigationController` 自动管理。当用户点击左上角返回箭头或滑动返回时：

1. `UINavigationController` 弹出当前 VC
2. VC 被销毁时，其持有的 `RCTRootView` 也被销毁
3. 对应的 React 组件树执行 unmount 和清理

---

## 十四、Bridging Header 与模块化

### 14.1 demo-Bridging-Header.h

```objc
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <RNViewFactory/RNViewFactory.h>
```

Bridging Header 是 Swift 与 Objective-C 混编的桥梁。Swift 文件可以直接使用 Bridging Header 中 `#import` 的所有 ObjC 类。

| 头文件 | 说明 |
|---|---|
| `RCTRootView.h` | RN 根视图类，承载 React 组件树的 UIView 子类 |
| `RCTBridge.h` | RN Bridge 核心类，管理 Native ↔ JS 通信 |
| `RCTBundleURLProvider.h` | JS Bundle URL 提供者，自动根据 Debug/Release 选择加载来源 |
| `RNViewFactory/RNViewFactory.h` | 本项目的本地 Pod，封装 RN 视图创建逻辑 |

### 14.2 模块化策略

```
┌──────────────────────────────────────────┐
│                  demo target             │
│  Swift 代码 + ObjC Bridging Header       │
│  AppDelegate / ContentView / Bridges     │
├──────────────────────────────────────────┤
│         import RNViewFactory             │
├──────────────────────────────────────────┤
│           RNViewFactory (Pod)            │
│  ObjC 代码 + module.modulemap            │
│  封装所有 RCT* API 的直接调用             │
├──────────────────────────────────────────┤
│        React Native Pods                 │
│  React-Core / React-RCTAppDelegate ...   │
└──────────────────────────────────────────┘
```

`RNViewFactory` 作为中间层，隔离了 Swift 代码与 React Native ObjC API 的直接依赖。

---

## 十五、Podfile post_install 钩子详解

### 15.1 React Native 官方 post_install

```ruby
react_native_post_install(
  installer,
  'node_modules/react-native',
  :mac_catalyst_enabled => false
)
```

此宏由 React Native 提供（`node_modules/react-native/scripts/react_native_pods.rb`），作用包括：
- 配置头文件搜索路径
- 设置 Clang 编译选项
- 处理 Hermes 引擎的集成
- 配置 Flipper 调试工具（如启用）

### 15.2 统一部署目标

```ruby
installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
  end
end
```

某些第三方 Pod 的默认部署目标低于 18.0（如 iOS 13.0），会导致 Xcode 产生大量 deprecation 警告。此钩子强制所有 Pod 使用相同的部署目标。

### 15.3 Xcode swiftinterface 修复

```ruby
config.build_settings['SWIFT_VERIFY_EMITTED_MODULE_INTERFACE'] = 'NO'
config.build_settings['SWIFT_EMIT_MODULE_INTERFACE'] = 'NO'
```

Xcode 新版本会验证 `.swiftinterface` 文件（Swift 模块的公开接口描述）的一致性。某些第三方 Pod 的 swiftinterface 与实际代码不匹配，导致编译失败。关闭验证可以绕过此问题。

### 15.4 RCTSwiftUI 重复符号修复

```ruby
# 从 xcconfig 移除 -l"RCTSwiftUI" 和 -l"RCTSwiftUIWrapper"
Dir.glob("Pods/Target Support Files/Pods-demo/*.xcconfig").each do |path|
  content = File.read(path)
  content = content.gsub(' -l"RCTSwiftUI"', '').gsub(' -l"RCTSwiftUIWrapper"', '')
  File.write(path, content)
end

# 清空这两个 target 的源文件，防止重复编译
%w[RCTSwiftUI RCTSwiftUIWrapper].each do |name|
  target = installer.pods_project.targets.find { |t| t.name == name }
  next unless target
  target.source_build_phase.files.to_a.each do |f|
    target.source_build_phase.remove_build_file(f)
  end
end
```

**问题原因：** React Native 0.84 的预编译 `React.framework` 中已经包含了 `RCTSwiftUI` 和 `RCTSwiftUIWrapper` 的符号。但 CocoaPods 又会生成这两个 target 并编译其源码，导致链接时出现 "duplicate symbol" 错误。

**解决方案：**
1. 从 Pods 的 xcconfig 中移除对这两个库的 `-l` 链接标记
2. 清空它们的 source_build_phase，不再编译源文件

---

## 十六、数据模型

### 16.1 新闻列表数据

```tsx
interface NewsItem {
  id: string;       // 唯一标识
  title: string;    // 标题
  summary: string;  // 摘要（列表显示）
  body: string;     // 全文（详情显示）
  image: string;    // 配图 URL
  source: string;   // 来源（如 "Space News", "Reuters Health"）
  time: string;     // 发布时间（相对时间，如 "2h ago"）
}
```

当前数据为硬编码的模拟数据（`NEWS_DATA` 数组），共 7 条。实际生产中应通过 Alamofire 从后端 API 获取。

### 16.2 Settings 状态

```tsx
interface SettingsState {
  theme: 'dark' | 'light';
  fontSize: 'small' | 'medium' | 'large';
}
```

当前状态仅保存在内存中（Redux Store）。应用重启后恢复为默认值（dark / medium）。如需持久化，可集成 `redux-persist` 或 `AsyncStorage`。

### 16.3 分类数据

```swift
struct Category: Identifiable {
    let id: String      // 标识（如 "medical", "tech"）
    let name: String    // 显示名（如 "Medical", "Tech"）
    let icon: String    // SF Symbols 图标名
    let accent: Color   // 强调色
}
```

共 6 个分类：Medical、Tech、World、Science、Business、Sports。使用 Apple SF Symbols 作为图标。

---

## 十七、文件完整清单与职责

### 原生层（demo/）

| 文件 | 语言 | 职责 |
|---|---|---|
| `AppDelegate.swift` | Swift | 应用入口（`@main`）。创建 UIWindow、UINavigationController，配置深色导航栏 |
| `demoApp.swift` | Swift | 原始 SwiftUI 入口文件（已废弃）。入口已迁移到 AppDelegate.swift 以支持 RN，此文件仅保留注释说明 |
| `ContentView.swift` | Swift | SwiftUI 首页。展示分类宫格（LazyVGrid）、热门入口、设置入口。包含 RNViewController 定义和 pushRNPage 导航方法 |
| `Constants.swift` | Swift | 共享常量定义 |
| `INMONavigationBar.swift` | Swift | 自定义导航栏组件 |
| `TranslationOnboardingView.swift` | Swift | 翻译功能引导页 |
| `NavigationBridge.m` | ObjC | RN Native Module。暴露 `pushNewsDetail` 方法给 JS，实现从 NewsList 导航到 NewsDetail |
| `SettingsBridge.m` | ObjC | RN Native Module。暴露 `applyTheme` 方法给 JS，实现主题同步到原生 UIKit |
| `demo-Bridging-Header.h` | ObjC | Swift ↔ ObjC 桥接头文件。暴露 RCT 和 RNViewFactory 头文件给 Swift |
| `Assets.xcassets/` | - | Xcode 资源目录。存放 App 图标（AppIcon）和主题色（AccentColor） |
| `Info.plist` | XML | 应用元数据配置（Bundle ID、权限声明等） |

### React Native 层（src/）

| 文件 | 语言 | 职责 |
|---|---|---|
| `App.tsx` | TypeScript | RN 默认首页组件（演示/调试用途） |
| `NewsList.tsx` | TypeScript | 新闻列表页。FlatList 虚拟化列表，响应主题/字号变更，通过 NavigationBridge 导航 |
| `NewsDetail.tsx` | TypeScript | 新闻详情页。接收 initialProperties 作为 props，ScrollView 展示全文 |
| `SettingsPage.tsx` | TypeScript | 设置页面。主题和字号选择器，通过 Redux + SettingsBridge 双向同步 |
| `withProvider.tsx` | TypeScript | 高阶组件。为每个 RN 模块注入 Redux Provider |
| `theme.ts` | TypeScript | 主题系统。定义深色/浅色调色板和三档字号预设 |
| `store/index.ts` | TypeScript | Redux Store 配置。导出类型安全的 useAppDispatch / useAppSelector |
| `store/settingsSlice.ts` | TypeScript | Settings Slice。定义 theme/fontSize 状态和 setTheme/setFontSize actions |

### 桥接层（LocalPods/RNViewFactory/）

| 文件 | 语言 | 职责 |
|---|---|---|
| `RNViewFactory.h` | ObjC | 公开接口声明（`createRootViewWithModuleName:` 等） |
| `RNViewFactory.m` | ObjC | 核心实现。单例管理 RCTReactNativeFactory，提供 createRootView 工厂方法 |
| `NavigationBridge.h` | ObjC | NavigationBridge 的头文件声明 |
| `NavigationBridge.m` | ObjC | NavigationBridge 在 Pod 内的实现 |
| `module.modulemap` | - | Clang Module 映射文件，使 Swift 可以 `import RNViewFactory` |
| `RNViewFactory.podspec` | Ruby | Pod 规格文件，定义源码路径、依赖等元数据 |

> **注意：** `demo/NavigationBridge.m` 和 `LocalPods/RNViewFactory/NavigationBridge.m` 包含相同的业务逻辑，区别在于 import 方式不同（前者使用框架 import `<RNViewFactory/RNViewFactory.h>`，后者使用本地 import `"RNViewFactory.h"`）。实际编译时由 Xcode 的 target membership 决定使用哪个版本。如果修改 NavigationBridge 的逻辑，请确认你编辑的是正确的文件——检查 Xcode 左侧 Project Navigator 中文件属于哪个 target。

### 配置文件（根目录）

| 文件 | 职责 |
|---|---|
| `demo.xcworkspace/` | **Xcode 工作区（开发时必须打开这个）**。由 CocoaPods 生成，整合主工程和 Pods 依赖 |
| `demo.xcodeproj/` | Xcode 项目文件。包含编译设置、文件引用等。**不要单独打开此文件**，否则缺少 Pod 依赖 |
| `index.js` | RN 入口文件。注册 4 个 AppRegistry 组件 |
| `package.json` | npm 依赖声明和脚本定义 |
| `package-lock.json` | npm 依赖锁文件（精确版本，必须纳入 git） |
| `Podfile` | CocoaPods 依赖声明和 post_install 钩子 |
| `Podfile.lock` | CocoaPods 依赖锁文件（精确版本，必须纳入 git） |
| `app.json` | RN 应用名称配置（`{"name": "demo", "displayName": "demo"}`） |
| `metro.config.js` | Metro Bundler 配置 |
| `babel.config.js` | Babel 转译配置 |
| `.gitignore` | Git 忽略规则 |
| `.xcode.env` | Xcode 构建时的 Node.js 路径（已 gitignore，每台机器不同） |
| `PrivacyInfo.xcprivacy` | Apple 隐私清单（声明应用使用的隐私相关 API） |

---

## 十八、日常开发工作流

### 18.1 开发环境启动

每次开始开发，需要：

1. **终端窗口 1**：启动 Metro 开发服务器

```bash
cd /path/to/News
npm start
```

2. **终端窗口 2 / Xcode**：编译运行 App

```bash
open demo.xcworkspace
# Cmd+R 编译运行
```

> Metro 窗口必须保持打开。它负责实时打包 JS 代码并推送到模拟器中的 App。

### 18.2 修改 React Native 代码（热更新）

修改 `src/` 下的 `.tsx` / `.ts` 文件后：

1. **保存文件** → Metro 会自动检测变更
2. **模拟器中的 App 自动刷新**（Hot Module Replacement，简称 HMR）
3. 通常 1-2 秒内就能看到变更效果

如果自动刷新没生效：
- 在 Metro 终端按 `r` 手动刷新
- 或在模拟器中按 `Cmd+D` 打开开发菜单 → Reload

**什么情况需要重新编译（Cmd+R）？**

| 变更类型 | 需要的操作 |
|---|---|
| 修改 `src/` 下的 `.tsx` / `.ts` 文件 | 无需操作，HMR 自动刷新 |
| 修改 `index.js`（新增 registerComponent） | 重启 Metro（Ctrl+C 后 `npm start`）+ Xcode 重新编译 |
| 修改 Swift / ObjC 文件（`demo/` 目录） | **Xcode 重新编译（Cmd+R）** |
| 修改 `Podfile`（增减原生依赖） | `pod install` → Xcode 重新编译 |
| 新增纯 JS 的 npm 依赖 | `npm install <包名>` → 重启 Metro |
| 新增含原生代码的 npm 依赖 | `npm install <包名>` → `pod install` → Xcode 重新编译 |

### 18.3 修改原生代码

修改 `demo/` 目录下的 Swift 或 ObjC 文件后：

1. 回到 Xcode
2. 按 **Cmd+R** 重新编译运行
3. Xcode 会增量编译（只编译改动的文件），通常几秒到几十秒

### 18.4 添加新的 npm 依赖

```bash
# 安装新依赖
npm install <package-name>

# 如果新依赖包含原生代码（如 react-native-xxx），还需要：
pod install

# 然后在 Xcode 中重新编译（Cmd+R）
```

### 18.5 添加新的 CocoaPods 依赖

1. 编辑 `Podfile`，在 `target 'demo' do` 内添加新 Pod：

```ruby
pod 'SDWebImage', '~> 5.0'
```

2. 安装：

```bash
pod install
```

3. 在 Xcode 中 **Cmd+R** 重新编译

---

## 十九、调试指南

### 19.1 RN 侧调试 — console.log

在 `.tsx` 文件中使用 `console.log()`：

```tsx
const onPressItem = (item: NewsItem) => {
  console.log('点击了新闻:', item.title);   // 调试输出
  NavigationBridge?.pushNewsDetail({...});
};
```

**查看日志输出的三种方式：**

**方式一：Metro 终端（最简单）**

`console.log` 的输出会直接显示在运行 `npm start` 的终端窗口中。

**方式二：Xcode 控制台**

在 Xcode 底部的 Debug Area（如果没看到，按 `Cmd+Shift+Y` 打开）中也能看到 RN 的 `console.log` 输出。

**方式三：Safari Web Inspector（可以断点调试）**

1. 在模拟器中按 `Cmd+D` 打开开发菜单
2. 选择 "Open Debugger"
3. Safari 的 Web Inspector 会连接到 App 的 JS 运行时
4. 在 Console 标签看日志，在 Sources 标签设断点

### 19.2 RN 侧调试 — React DevTools

```bash
# 安装 React DevTools（全局一次性安装）
npm install -g react-devtools

# 启动
react-devtools
```

然后在模拟器中按 `Cmd+D` → "Open Debugger"。React DevTools 可以：
- 查看组件树层级结构
- 实时查看和修改组件的 props 和 state
- 查看 Redux Store 状态（需安装 Redux DevTools 扩展）

### 19.3 RN 侧调试 — 红屏/黄屏错误

| 类型 | 含义 | 处理方式 |
|---|---|---|
| **红屏（Red Screen）** | JS 运行时错误，App 崩溃 | 阅读错误信息和堆栈，找到出错的文件和行号，修复后保存，App 会自动重新加载 |
| **黄屏（Yellow Box）** | 警告，App 仍可运行 | 通常是废弃 API 的提示或性能建议，开发时可先忽略，上线前处理 |

红屏错误示例：

```
TypeError: Cannot read property 'pushNewsDetail' of null

This error is located at:
    in NewsList (at withProvider.tsx:7)
```

这表示 `NavigationBridge` 为 null，可能是 Native Module 未正确注册。

### 19.4 原生侧调试 — Xcode

**查看原生日志：**

Xcode 底部 Debug Area 会显示 `print()` 和 `NSLog()` 的输出。

**断点调试：**

1. 在 Xcode 中打开 `.swift` 或 `.m` 文件
2. 点击行号左侧设置断点（蓝色箭头）
3. 运行 App（Cmd+R），代码执行到断点时会暂停
4. 在底部查看变量值，使用工具栏的 Step Over / Step Into / Continue 控制执行

**原生崩溃排查：**

如果 App 闪退：

1. 查看 Xcode 控制台的崩溃日志
2. 关注 `*** Terminating app due to uncaught exception` 之后的信息
3. 常见原因：
   - `NSInvalidArgumentException`：方法调用参数错误
   - `EXC_BAD_ACCESS`：访问已释放的内存
   - `Unrecognized selector sent to instance`：调用了不存在的方法

### 19.5 网络调试

在模拟器中按 `Cmd+D` → "Open Debugger" 后，可以在 Network 标签查看所有网络请求（包括 RN 发出的请求和图片加载请求）。

### 19.6 查看 App 内的 Redux 状态

在任何 RN 组件中临时添加以下代码即可打印当前完整状态：

```tsx
import {useAppSelector} from './store';

// 在组件内部
const state = useAppSelector(state => state);
console.log('当前 Redux 状态:', JSON.stringify(state, null, 2));
```

---

## 二十、实操教程：新增一个 RN 页面

以下以新增一个 "关于我们"（AboutPage）页面为例，展示完整的新增页面流程。

### 步骤 1：创建 React 组件

新建文件 `src/AboutPage.tsx`：

```tsx
import React from 'react';
import {StyleSheet, Text, View, ScrollView} from 'react-native';
import {useAppSelector} from './store';
import {getColors, getFontSizes} from './theme';

const AboutPage: React.FC = () => {
  const {theme, fontSize} = useAppSelector(state => state.settings);
  const colors = getColors(theme);
  const fonts = getFontSizes(fontSize);

  return (
    <View style={[styles.container, {backgroundColor: colors.background}]}>
      <ScrollView
        contentContainerStyle={styles.content}
        automaticallyAdjustContentInsets={true}
        contentInsetAdjustmentBehavior="automatic">
        <Text style={{fontSize: fonts.detailTitle, fontWeight: '700', color: colors.textPrimary}}>
          News App
        </Text>
        <Text style={{fontSize: fonts.body, color: colors.textSecondary, marginTop: 12}}>
          版本 1.0.0
        </Text>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {flex: 1},
  content: {padding: 20},
});

export default AboutPage;
```

### 步骤 2：注册到 AppRegistry

编辑 `index.js`，添加注册：

```javascript
import AboutPage from './src/AboutPage';

AppRegistry.registerComponent('AboutPage', () => withProvider(AboutPage));
```

### 步骤 3：从原生侧调用

在 `ContentView.swift` 中添加入口按钮，调用：

```swift
pushRNPage(moduleName: "AboutPage", title: "About")
```

`moduleName` 必须与 `AppRegistry.registerComponent` 的第一个参数**完全一致**。

### 步骤 4：重新运行

由于修改了 `index.js`（新增了 registerComponent），需要：

1. 停止 Metro（在 Metro 终端按 `Ctrl+C`）
2. 重新启动：`npm start`
3. 由于修改了 Swift 文件，在 Xcode 中 `Cmd+R` 重新编译

---

## 二十一、实操教程：新增一个 Native Module

以下以新增一个 "ClipboardBridge"（复制到剪贴板）为例。

### 步骤 1：创建 ObjC 原生模块

新建文件 `demo/ClipboardBridge.m`：

```objc
#import <React/RCTBridgeModule.h>
#import <UIKit/UIKit.h>

@interface ClipboardBridge : NSObject <RCTBridgeModule>
@end

@implementation ClipboardBridge

// 注册模块，JS 侧通过 NativeModules.ClipboardBridge 访问
RCT_EXPORT_MODULE();

// 不涉及 UI 操作，可以在后台线程初始化
+ (BOOL)requiresMainQueueSetup {
    return NO;
}

// 暴露方法给 JS
RCT_EXPORT_METHOD(copyText:(NSString *)text) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIPasteboard generalPasteboard].string = text;
    });
}

@end
```

> **注意：** 新建 `.m` 文件后需要在 Xcode 中确认它被添加到了 `demo` target 的 Compile Sources 中。通常 Xcode 会自动处理，但如果运行时 JS 报 "Module not found"，请手动检查：Xcode → demo target → Build Phases → Compile Sources。

### 步骤 2：在 RN 侧调用

```tsx
import {NativeModules} from 'react-native';

const {ClipboardBridge} = NativeModules;

// 调用
ClipboardBridge.copyText('要复制的文字');
```

### 步骤 3：重新编译

修改了原生代码，必须在 Xcode 中 `Cmd+R` 重新编译。

### Native Module 开发要点总结

| 要点 | 说明 |
|---|---|
| 文件位置 | 放在 `demo/` 目录下 |
| 语言 | Objective-C（推荐）或 Swift（需额外配置） |
| 注册 | `RCT_EXPORT_MODULE()` |
| 暴露方法 | `RCT_EXPORT_METHOD(methodName:(Type *)param)` |
| UI 操作 | 必须用 `dispatch_async(dispatch_get_main_queue(), ^{ ... })` |
| JS 调用 | `NativeModules.ModuleName.methodName(args)` |
| 调试 | 如果 JS 侧拿到 `undefined`，检查模块是否注册、方法是否导出、是否重新编译了 |
