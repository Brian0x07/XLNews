# 部署指南

本文档详细说明项目所依赖的所有工具链的作用、安装方式、配置细节以及从零到运行的完整流程。

---

## 目录

- [一、环境总览](#一环境总览)
- [二、macOS 系统要求](#二macos-系统要求)
- [三、Xcode 安装与配置](#三xcode-安装与配置)
- [四、Node.js 与 npm](#四nodejs-与-npm)
- [五、Ruby 环境](#五ruby-环境)
- [六、CocoaPods](#六cocoapods)
- [七、从零部署完整流程](#七从零部署完整流程)
- [八、Metro Bundler（开发服务器）](#八metro-bundler开发服务器)
- [九、构建 Release 版本](#九构建-release-版本)
- [十、真机调试](#十真机调试)
- [十一、CI/CD 环境部署](#十一cicd-环境部署)
- [十二、常见问题排查](#十二常见问题排查)

---

## 一、环境总览

| 工具 | 最低版本 | 推荐版本 | 用途 |
|---|---|---|---|
| macOS | 14 (Sonoma) | 15 (Sequoia) | 开发操作系统 |
| Xcode | 16.0 | 16.x 最新 | iOS 编译工具链、模拟器 |
| Node.js | 18.0 | 20 LTS | 运行 Metro、npm 包管理 |
| npm | 9.0 | 10.x（随 Node 安装） | JavaScript 依赖管理 |
| Ruby | 2.7 | 3.2+（系统自带或 rbenv） | CocoaPods 运行时 |
| CocoaPods | 1.14 | 1.16+ | iOS 原生依赖管理 |
| apollo-ios-cli | 1.25 | 1.25.x | GraphQL 代码生成（可选，仅修改 Schema 时需要） |

---

## 二、macOS 系统要求

### 为什么需要 macOS？

iOS 应用开发必须在 macOS 上进行，因为：
- Xcode（包含 iOS SDK、模拟器、签名工具）仅在 macOS 上提供
- Apple 的代码签名和公证机制绑定 macOS 内核
- iOS 模拟器依赖 macOS 的虚拟化框架

### 推荐配置

- **系统版本：** macOS 14 Sonoma 或更高（Xcode 16 的最低要求）
- **磁盘空间：** 至少 30 GB 可用（Xcode 约 12 GB + 模拟器 5-10 GB + 项目依赖）
- **内存：** 8 GB 以上（16 GB 推荐，编译大型项目时内存消耗较高）

---

## 三、Xcode 安装与配置

### 3.1 什么是 Xcode？

Xcode 是 Apple 官方的集成开发环境（IDE），包含：
- **编译器（Clang/Swift）**：将 Swift、Objective-C、C/C++ 源码编译为 ARM/x86 二进制
- **iOS SDK**：提供 UIKit、SwiftUI、Foundation 等框架的头文件和库
- **模拟器（Simulator）**：无需真机即可测试应用
- **代码签名工具（codesign）**：为应用签名，真机和 App Store 分发必需
- **Interface Builder**：可视化 UI 编辑器（本项目未使用）
- **Instruments**：性能分析工具

### 3.2 安装步骤

**方法一：App Store（推荐）**

1. 打开 Mac App Store
2. 搜索 "Xcode"
3. 点击"获取"并等待下载安装（约 12 GB）

**方法二：Apple Developer 网站**

1. 访问 https://developer.apple.com/download/
2. 登录 Apple ID
3. 下载 Xcode .xip 文件
4. 解压到 `/Applications/`

**方法三：命令行工具（仅安装编译工具，不含 IDE）**

```bash
xcode-select --install
```

> 注意：仅安装命令行工具不够，本项目需要完整 Xcode（包含模拟器和 SDK）。

### 3.3 安装后配置

```bash
# 确认 Xcode 路径
xcode-select -p
# 应输出: /Applications/Xcode.app/Contents/Developer

# 如果路径不对，手动指定
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# 接受许可协议
sudo xcodebuild -license accept

# 安装额外组件（首次运行 Xcode 时也会提示）
xcodebuild -runFirstLaunch
```

### 3.4 安装 iOS 模拟器

```bash
# 列出可用的模拟器运行时
xcrun simctl list runtimes

# 如果没有 iOS 18 运行时，在 Xcode 中安装：
# Xcode → Settings → Platforms → 点击 "+" → iOS 18.x
```

### 3.5 部署目标

本项目的部署目标（Deployment Target）设置为 **iOS 18.0**，这意味着：
- 编译产物仅支持 iOS 18.0 及以上版本
- 可以使用 iOS 18 引入的所有新 API
- Podfile 中通过 `platform :ios, '18.0'` 指定

---

## 四、Node.js 与 npm

### 4.1 什么是 Node.js？

Node.js 是一个 JavaScript 运行时环境。在本项目中，Node.js 用于：
- **运行 Metro Bundler**：React Native 的 JavaScript 打包开发服务器
- **运行 npm**：管理和安装 JavaScript 依赖
- **执行 Babel 编译**：将 TypeScript/JSX 转译为 React Native 可执行的 JavaScript
- **运行 React Native CLI 命令**

### 4.2 什么是 npm？

npm（Node Package Manager）是 Node.js 的默认包管理器，功能类似 iOS 的 CocoaPods 或 Python 的 pip。本项目使用 npm 管理以下依赖：

| 依赖 | 版本 | 类型 | 说明 |
|---|---|---|---|
| `react` | ^19.2.3 | 运行时 | UI 框架核心 |
| `react-native` | ^0.84.1 | 运行时 | React Native 框架 |
| `@reduxjs/toolkit` | ^2.11.2 | 运行时 | Redux 状态管理工具包 |
| `react-redux` | ^9.2.0 | 运行时 | Redux 的 React 绑定 |
| `@babel/core` | ^7.25.2 | 开发 | Babel 编译器核心 |
| `@babel/preset-env` | ^7.25.3 | 开发 | Babel 环境预设，按目标平台转译语法 |
| `@babel/runtime` | ^7.25.0 | 开发 | Babel 运行时辅助函数 |
| `@react-native-community/cli` | ^20.1.3 | 开发 | React Native 命令行工具（`npx react-native` 命令） |
| `@react-native/babel-preset` | ^0.84.1 | 开发 | RN 专用 Babel 预设 |
| `@react-native/metro-config` | ^0.84.1 | 开发 | Metro 默认配置 |

> **运行时依赖**会被打包到最终 App 中，**开发依赖**仅在编译/打包过程中使用。

### 4.3 安装 Node.js

**方法一：nvm（推荐，支持多版本管理）**

```bash
# 安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# 重新加载 shell 配置
source ~/.zshrc

# 安装 Node.js 20 LTS
nvm install 20

# 验证
node --version   # v20.x.x
npm --version    # 10.x.x
```

**方法二：Homebrew**

```bash
# 安装最新 LTS 版 Node.js（推荐）
brew install node

# 或安装指定大版本（注意：版本化 formula 是 keg-only，需额外配置 PATH）
brew install node@20
# Apple Silicon Mac：
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zshrc
# Intel Mac：
# echo 'export PATH="/usr/local/opt/node@20/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

> **注意：** `brew install node@20` 安装的是 keg-only formula，不会自动加入 PATH。推荐直接使用 `brew install node` 安装最新版，或使用上面的 nvm 方法管理多版本。

**方法三：官方安装包**

从 https://nodejs.org/ 下载 LTS 版本安装包。

### 4.4 npm vs yarn vs pnpm

本项目使用 **npm** 并通过 `package-lock.json` 锁定依赖版本。

| 工具 | 锁文件 | 说明 |
|---|---|---|
| npm | `package-lock.json` | Node.js 自带，本项目使用 |
| yarn | `yarn.lock` | Facebook 开发的替代方案，速度更快 |
| pnpm | `pnpm-lock.yaml` | 使用硬链接节省磁盘空间 |

> **重要：** 不要混用包管理器。本项目使用 npm，请始终用 `npm install` 安装依赖。

### 4.5 package.json 中的脚本

```json
{
  "scripts": {
    "start": "react-native start",
    "bundle:ios": "react-native bundle --platform ios --dev false --entry-file index.js --bundle-output ios/main.jsbundle --assets-dest ios"
  }
}
```

| 命令 | 说明 |
|---|---|
| `npm start` | 启动 Metro 开发服务器（端口 8081） |
| `npm run bundle:ios` | 生成 iOS 离线 JS Bundle（生产构建用） |

---

## 五、Ruby 环境

### 5.1 为什么需要 Ruby？

CocoaPods 是用 Ruby 编写的，运行 `pod install` 需要 Ruby 运行时。macOS 自带 Ruby，但版本可能较旧。

### 5.2 检查系统 Ruby

```bash
ruby --version
# macOS 14+ 通常自带 Ruby 2.6.x 或更高
```

### 5.3 安装更新版本（可选）

如果系统 Ruby 版本太旧或遇到权限问题：

**方法一：rbenv（推荐）**

```bash
brew install rbenv ruby-build
rbenv install 3.2.3
rbenv global 3.2.3

# 添加到 shell 配置
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**方法二：Homebrew**

```bash
brew install ruby
# 需要将 Homebrew Ruby 路径添加到 PATH
# Apple Silicon Mac：
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
# Intel Mac：
# echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc
```

---

## 六、CocoaPods

### 6.1 什么是 CocoaPods？

CocoaPods 是 iOS/macOS 开发的依赖管理器，功能类似 npm 之于 Node.js。它的核心职责：

1. **依赖解析**：根据 `Podfile` 中声明的依赖，递归解析所有直接和传递依赖
2. **下载源码**：从 CocoaPods 中央仓库或指定源下载依赖的源码
3. **集成到 Xcode**：自动配置 Xcode workspace，将依赖编译为静态库/框架并链接到主工程
4. **版本锁定**：通过 `Podfile.lock` 锁定精确版本

### 6.2 核心概念

| 概念 | 文件 | 说明 |
|---|---|---|
| Pod | - | 一个 CocoaPods 管理的依赖库（类似 npm package） |
| Podfile | `Podfile` | 依赖声明文件（类似 `package.json`） |
| Podfile.lock | `Podfile.lock` | 锁文件，记录精确版本（类似 `package-lock.json`） |
| Podspec | `*.podspec` | Pod 的元数据描述文件，定义源码路径、依赖等（类似 `package.json` 对于库作者） |
| Pods 目录 | `Pods/` | 下载的依赖源码和编译产物 |
| Workspace | `*.xcworkspace` | CocoaPods 生成的 Xcode 工作区，整合主工程和 Pods 工程 |

### 6.3 安装 CocoaPods

```bash
# 方法一：gem 安装（推荐）
sudo gem install cocoapods

# 方法二：Homebrew
brew install cocoapods

# 验证安装
pod --version
```

### 6.4 本项目的 Podfile 解析

```ruby
source 'https://cdn.cocoapods.org/'    # 使用 CDN 源（比 git clone 快得多）
platform :ios, '18.0'                   # 最低部署目标

target 'NewsApp' do
  # 第三方原生依赖
  pod 'Kingfisher', '~> 8.0'          # 图片下载与缓存
  pod 'lottie-ios', '~> 4.5'          # Lottie JSON 动画
  pod 'SwiftProtobuf', '~> 1.28'      # Protocol Buffers
  pod 'Alamofire', '~> 5.9'           # HTTP 网络请求
  pod 'Apollo', '~> 1.15'             # GraphQL 客户端
  pod 'SnapKit', '~> 5.7'             # Auto Layout DSL

  # React Native 集成
  use_react_native!(...)               # RN 官方宏，自动配置所有 RN 相关 Pods

  # 本地 Pod
  pod 'RNViewFactory', :path => 'LocalPods/RNViewFactory'
end
```

**版本约束语法：**

| 语法 | 含义 | 示例 |
|---|---|---|
| `'~> 8.0'` | 大于等于 8.0，小于 9.0 | 8.0, 8.1, 8.9.9 均可 |
| `'~> 5.7'` | 大于等于 5.7，小于 6.0 | 5.7, 5.8, 5.9 均可 |
| `'>= 1.0'` | 大于等于 1.0 | 任何 1.0+ 版本 |
| `'1.2.3'` | 精确版本 | 仅 1.2.3 |

### 6.5 本地 Pod（RNViewFactory）

```ruby
pod 'RNViewFactory', :path => 'LocalPods/RNViewFactory'
```

与从远程仓库下载不同，本地 Pod 直接指向项目内的源码目录。本项目的 `RNViewFactory` 是自行编写的 ObjC 桥接层，封装了 RN 视图创建逻辑，以本地 Pod 形式集成有以下好处：

- 代码与主工程解耦，可独立编译和测试
- 通过 `module.modulemap` 暴露给 Swift 使用（`import RNViewFactory`）
- 将 RN 相关的 ObjC 代码隔离，保持主工程 Swift-only

### 6.6 pod install vs pod update

| 命令 | 行为 |
|---|---|
| `pod install` | 根据 `Podfile.lock` 安装锁定版本；新增 Pod 时解析最新兼容版本并写入 lock 文件 |
| `pod update` | 忽略 lock 文件，重新解析所有依赖的最新兼容版本 |
| `pod update Alamofire` | 仅更新指定 Pod |

> **日常开发请始终使用 `pod install`。** 仅在需要主动升级依赖时使用 `pod update`。

### 6.7 Podfile 的 post_install 钩子

本项目的 Podfile 包含四个 post_install 处理：

```ruby
post_install do |installer|
  # 1. React Native 官方 post_install
  react_native_post_install(installer, ...)

  # 2. 强制所有 Pods 部署目标为 18.0
  # 避免某些 Pod 默认目标较低导致的编译警告

  # 3. 修复 Xcode 26 swiftinterface 验证问题
  # 设置 SWIFT_VERIFY_EMITTED_MODULE_INTERFACE = NO

  # 4. 修复 RCTSwiftUI 重复类链接问题
  # 从 xcconfig 中移除重复的 -l 链接标记
end
```

### 6.8 Apollo iOS CLI（代码生成工具）

Apollo iOS 使用 CLI 工具从 GraphQL Schema 和查询文件生成强类型的 Swift 代码。**日常开发不需要安装此工具**——只有在修改 `NewsApp/GraphQL/schema.graphqls` 或 `NewsApp/GraphQL/Operations/*.graphql` 时才需要重新生成。

**安装方式：**

```bash
# 从 GitHub Releases 下载（需要与 Pod 版本匹配）
curl -sL https://github.com/apollographql/apollo-ios/releases/download/1.25.2/apollo-ios-cli.tar.gz -o apollo-ios-cli.tar.gz
tar xzf apollo-ios-cli.tar.gz

# 验证
./apollo-ios-cli --version   # ✅ 期望: 1.25.2
```

> **重要：CLI 版本必须与 Apollo Pod 版本匹配。** 本项目使用 Apollo 1.25.2（CocoaPods），CLI 也必须使用 1.25.2。版本不匹配会导致生成的代码无法编译（例如 2.x CLI 生成 struct，而 1.x 期望 class）。

**使用方式：**

```bash
# 在项目根目录执行（读取 apollo-codegen-config.json）
./apollo-ios-cli generate
```

**CocoaPods 兼容注意：** 生成的代码默认使用 `import ApolloAPI`，但 CocoaPods 将 ApolloAPI 打包在 `Apollo` 模块中。生成后需要执行：

```bash
# 将 import ApolloAPI 替换为 import Apollo，将 ApolloAPI. 前缀替换为 Apollo.
find NewsApp/GraphQL/Generated -name "*.swift" -exec sed -i '' 's/import ApolloAPI/import Apollo/g; s/ApolloAPI\./Apollo./g' {} \;
```

---

## 七、从零部署完整流程

以下是在一台全新 Mac 上从零开始到成功运行项目的完整步骤。

> **重要提示：** 本项目的开发需要**同时打开两个终端窗口**——一个运行 Metro 开发服务器（持续运行），另一个用于执行其他命令。请在开始前了解这一点。

### 第一步：安装 Xcode（最耗时，优先进行）

1. 从 Mac App Store 安装 Xcode 16+（约 12 GB，下载时间较长，建议优先开始）
2. 安装完成后，打开 Xcode 一次，等待它安装额外组件（模拟器、平台工具等）
3. 安装 iOS 18 模拟器运行时：Xcode → Settings → Platforms → 点击 "+" → iOS 18.x

```bash
# 命令行确认 Xcode 路径是否正确
xcode-select -p
# ✅ 期望输出: /Applications/Xcode.app/Contents/Developer
# ❌ 如果路径不对，执行以下命令修正：
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# 接受许可协议（必须，否则后续编译会报错）
sudo xcodebuild -license accept
```

**验证：** 运行 `xcrun simctl list devices available`，应看到包含 "iPhone" 的可用模拟器列表。

### 第二步：安装 Homebrew

```bash
# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> **Apple Silicon（M1/M2/M3/M4）注意：** Homebrew 安装在 `/opt/homebrew/`。安装脚本结束后会提示你执行两行命令将其添加到 PATH，**请务必执行**，否则后续 `brew` 命令会找不到：
>
> ```bash
> echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
> eval "$(/opt/homebrew/bin/brew shellenv)"
> ```
>
> Intel Mac 上 Homebrew 安装在 `/usr/local/`，通常不需要额外配置 PATH。

**验证：** 运行 `brew --version`，应输出版本号（如 `Homebrew 4.x.x`）。

### 第三步：安装 Node.js

```bash
# 推荐方式：安装最新稳定版
brew install node

# 验证
node --version   # ✅ 期望: v20.x.x 或更高
npm --version    # ✅ 期望: 10.x.x 或更高
```

> 如果需要精确控制版本，推荐使用 nvm（见上文 4.3 节），而非 `brew install node@20`（该方式需要额外配置 PATH）。

### 第四步：安装 CocoaPods

```bash
sudo gem install cocoapods
```

如果遇到权限错误（macOS 较新版本可能限制系统 Ruby），改用 Homebrew 安装：

```bash
brew install cocoapods
```

**验证：** 运行 `pod --version`，应输出版本号（如 `1.16.x`）。

### 第五步：克隆项目

```bash
git clone <repo-url>
cd News
```

### 第六步：安装依赖

```bash
# 1. 安装 JavaScript 依赖
npm install
```

**验证：** 项目根目录出现 `node_modules/` 文件夹，且命令没有报错（WARNING 可以忽略，ERROR 不行）。

```bash
# 2. 安装 iOS 原生依赖
pod install
```

> **首次运行可能较慢**（需要下载依赖源码）。本项目 Podfile 配置了 CDN 源（`source 'https://cdn.cocoapods.org/'`），比传统 git 源快得多，但首次仍需要下载所有 Pod 的源码。
>
> 如果报错 "Unable to find a specification for..."，执行 `pod install --repo-update` 更新仓库索引后重试。

**验证：**
- 项目根目录出现 `Pods/` 文件夹
- 终端最后几行输出类似 `Pod installation complete! There are XX dependencies`
- `NewsApp.xcworkspace` 文件存在

### 第七步：启动 Metro 开发服务器

**打开第一个终端窗口（此窗口将持续运行，不要关闭）：**

```bash
cd /path/to/News   # 进入项目目录
npm start
```

看到如下 Metro 启动画面表示成功：

```
                 Metro

  i - run on iOS
  a - run on Android
  r - reload app
  d - open Dev Menu
```

> **注意：** 这个终端窗口必须保持打开状态。Metro 是实时的 JS 打包服务器，App 运行时会持续从它加载代码。如果关闭 Metro，App 中的 RN 页面会白屏。

### 第八步：编译运行

**打开第二个终端窗口（或直接使用 Xcode）：**

**方法一：通过 Xcode（推荐新手使用）**

```bash
open NewsApp.xcworkspace
```

1. Xcode 打开后，在顶部工具栏确认：
   - **Scheme** 选择 `NewsApp`（左侧下拉菜单）
   - **目标设备** 选择一个 iPhone 模拟器（如 `iPhone 16`）
2. 按 **Cmd+R** 编译运行
3. 首次编译需要 2-5 分钟（取决于电脑性能），后续增量编译会快很多

**方法二：纯命令行**

```bash
npx react-native run-ios --scheme NewsApp
```

> **关键提醒：** 始终打开 `NewsApp.xcworkspace`（**不是** `NewsApp.xcodeproj`）。`.xcodeproj` 不包含 CocoaPods 配置的依赖，打开它编译必定失败。

### 第九步：验证运行成功

如果一切正常，模拟器中应该看到：

1. **首页（SwiftUI）**：深色背景，顶部显示 "Good Morning"，下方是 6 个分类卡片（Medical、Tech、World 等），底部有 Trending 和 Settings 入口
2. **点击任意分类**：跳转到新闻列表页（React Native 渲染），显示多条新闻卡片，每条有标题、摘要、配图和来源
3. **点击新闻条目**：跳转到新闻详情页，显示大图、标题和全文
4. **返回首页 → 点击 Settings**：进入设置页面，可以切换 Dark/Light 主题和 Small/Medium/Large 字号

如果看到以上画面，恭喜，项目部署成功！

### 常见失败场景

| 现象 | 原因 | 解决方案 |
|---|---|---|
| 首页正常但点击分类后白屏 | Metro 开发服务器未启动 | 确保 `npm start` 在另一个终端持续运行 |
| Xcode 编译报 "No such module 'RNViewFactory'" | 打开了 `.xcodeproj` 而非 `.xcworkspace` | 关闭 Xcode，用 `open NewsApp.xcworkspace` 重新打开 |
| `pod install` 报错 | CocoaPods 版本过旧或仓库索引缺失 | 运行 `sudo gem install cocoapods && pod install --repo-update` |
| 模拟器中 App 闪退 | 可能是 JS Bundle 加载失败 | 查看 Metro 终端是否有红色报错信息 |

---

## 八、Metro Bundler（开发服务器）

### 8.1 什么是 Metro？

Metro 是 React Native 专用的 JavaScript 打包器（Bundler），类似前端开发中的 Webpack 或 Vite。它的职责：

1. **文件监听**：监控项目根目录下所有 JS/TS/JSON 文件的变更（包括 `src/`、`index.js` 等）
2. **依赖解析**：从 `index.js` 入口递归解析所有 `import`/`require`
3. **代码转译**：通过 Babel 将 TypeScript、JSX 转译为标准 JavaScript
4. **打包输出**：将所有模块打包为单个 JS Bundle
5. **热更新（HMR）**：将代码变更实时推送到正在运行的 App，无需重新编译

### 8.2 配置文件

**metro.config.js：**

```javascript
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');
const config = {};
module.exports = mergeConfig(getDefaultConfig(__dirname), config);
```

本项目使用 RN 默认配置，未做自定义修改。

**babel.config.js：**

```javascript
module.exports = {
  presets: ['@react-native/babel-preset'],
};
```

使用 RN 官方 Babel 预设，包含 TypeScript、JSX、Flow 等转译插件。

### 8.3 常用操作

| 操作 | 方式 |
|---|---|
| 启动 Metro | `npm start` |
| 清除缓存启动 | `npm start -- --reset-cache` |
| 手动刷新 App | 在 Metro 终端按 `r` |
| 打开调试菜单 | 在 Metro 终端按 `d`，或在模拟器中 Cmd+D |

---

## 九、构建 Release 版本

### 9.1 生成离线 Bundle

开发模式下 App 从 Metro 服务器加载 JS；Release 模式需要预打包的离线 Bundle：

```bash
npm run bundle:ios
```

这条命令等价于：

```bash
react-native bundle \
  --platform ios \
  --dev false \
  --entry-file index.js \
  --bundle-output ios/main.jsbundle \
  --assets-dest ios
```

| 参数 | 说明 |
|---|---|
| `--platform ios` | 目标平台为 iOS |
| `--dev false` | 关闭开发模式（启用代码压缩、移除调试工具） |
| `--entry-file index.js` | 入口文件 |
| `--bundle-output` | Bundle 输出路径 |
| `--assets-dest` | 静态资源（图片等）输出目录 |

### 9.2 Xcode Release 构建

1. 确保已先执行 `npm run bundle:ios` 生成离线 Bundle
2. 在 Xcode 顶部工具栏，将目标设备改为 **Any iOS Device**（而非模拟器）
3. 选择 Product → **Archive**（Archive 默认使用 Release 配置，无需手动切换）
4. 编译完成后自动打开 Organizer 窗口
5. 在 Organizer 中选择刚生成的 Archive → **Distribute App** → 导出 IPA 或上传到 App Store Connect

> **注意：** 不要将 Run 的 Build Configuration 改为 Release 来做日常测试，这会关闭开发调试功能（如 console.log 输出、红屏报错等）。如需测试 Release 行为，使用 Archive 流程。

---

## 十、真机调试

### 10.1 前提条件

- Apple ID（免费即可用于开发测试）
- USB 数据线连接 iPhone/iPad
- 设备系统版本 >= iOS 18.0

### 10.2 配置签名

1. Xcode → NewsApp target → Signing & Capabilities
2. Team 选择你的 Apple ID 或开发者账号
3. 勾选 "Automatically manage signing"
4. Xcode 会自动创建 Provisioning Profile

### 10.3 开启开发者模式（iOS 16+ 必需）

iOS 16 起，真机调试前必须先开启开发者模式：

1. 在 iPhone 上打开：设置 → 隐私与安全性 → **开发者模式** → 开启
2. 设备会提示重启，确认重启
3. 重启后会再次弹窗确认，点击"打开"

> 如果看不到"开发者模式"选项，先用 USB 连接 Mac 并在 Xcode 中选择该设备作为目标，该选项会自动出现。

### 10.4 信任开发者证书

首次在真机运行时，还需要信任开发者证书：

设置 → 通用 → VPN 与设备管理 → 选择开发者 App → 信任

---

## 十一、CI/CD 环境部署

在无头（headless）CI 服务器上构建的要点：

```bash
# 安装依赖
npm ci                          # 使用 ci 而非 install，严格按 lock 文件安装
pod install --repo-update       # 确保 Pod 仓库索引最新

# 构建
xcodebuild \
  -workspace NewsApp.xcworkspace \
  -scheme NewsApp \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath ./build \
  clean build
```

| 要点 | 说明 |
|---|---|
| `npm ci` vs `npm install` | `ci` 严格按 lock 文件安装，更快且可重复；`install` 可能更新 lock 文件 |
| `--repo-update` | CI 环境中可能没有本地 Pod 仓库缓存 |
| 签名 | CI 上需要配置证书和 Provisioning Profile（通过 Fastlane Match 或手动） |

---

## 十二、常见问题排查

### Pod install 失败

```bash
# 清除 CocoaPods 缓存
pod cache clean --all

# 删除 Pods 重新安装
rm -rf Pods
pod install
```

### Metro 端口被占用

```bash
# 查找占用 8081 端口的进程
lsof -i :8081

# 杀掉进程
kill -9 <PID>

# 或使用指定端口启动
npm start -- --port 8082
```

### node_modules 状态异常

```bash
# 删除 node_modules 后根据 lock 文件重新安装（推荐）
rm -rf node_modules
npm install

# 如果仍有问题，尝试清除 npm 缓存
npm cache clean --force
rm -rf node_modules
npm install
```

> **警告：** 不要轻易删除 `package-lock.json`。它锁定了所有依赖的精确版本，删除后 `npm install` 可能安装不同版本的依赖，导致难以排查的兼容性问题。只有在确认 lock 文件本身损坏时才考虑删除。

### Xcode 编译错误 - 找不到模块

```bash
# 确保 workspace 正确配置
pod deintegrate
pod install
```

### Xcode 缓存问题

在 Xcode 中：
- **Clean Build Folder**：Cmd + Shift + K
- **清除 DerivedData**：`rm -rf ~/Library/Developer/Xcode/DerivedData/`

### Apollo 生成代码编译报错

**症状：** `no such module 'ApolloAPI'` 或 `non-class type cannot conform to class protocol 'GraphQLQuery'`

**原因：**
- `ApolloAPI` 错误：CocoaPods 将 ApolloAPI 打包在 `Apollo` 模块中，需要替换 import
- `non-class` 错误：CLI 版本与 Pod 版本不匹配（如 CLI 2.x 生成的代码无法在 Apollo 1.x 上编译）

**解决方案：**

```bash
# 1. 确认版本匹配
./apollo-ios-cli --version          # 应为 1.25.x
grep "Apollo (" Podfile.lock        # 应为 Apollo (1.25.x)

# 2. 重新生成并修复 imports
./apollo-ios-cli generate
find NewsApp/GraphQL/Generated -name "*.swift" -exec sed -i '' 's/import ApolloAPI/import Apollo/g; s/ApolloAPI\./Apollo./g' {} \;

# 3. Clean build
# Xcode: Cmd+Shift+K，然后 Cmd+R
```

### `.xcode.env` 中 Node 路径不对

```bash
# 查看当前 Node 路径
which node

# 更新 .xcode.env
echo "export NODE_BINARY=$(which node)" > .xcode.env
```
