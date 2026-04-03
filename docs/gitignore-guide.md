# .gitignore 配置说明

本文档逐条解释项目 `.gitignore` 文件中每一条规则的作用、为什么需要忽略，以及相关背景知识。

---

## 目录

- [1. macOS 系统文件](#1-macos-系统文件)
- [2. Xcode 相关](#2-xcode-相关)
- [3. Android / IntelliJ 相关](#3-android--intellij-相关)
- [4. Node.js 相关](#4-nodejs-相关)
- [5. Fastlane 相关](#5-fastlane-相关)
- [6. JS Bundle 产物](#6-js-bundle-产物)
- [7. Ruby / CocoaPods](#7-ruby--cocoapods)
- [8. Metro 打包器](#8-metro-打包器)
- [9. 测试覆盖率](#9-测试覆盖率)
- [10. Expo 相关](#10-expo-相关)
- [11. Windows 系统文件](#11-windows-系统文件)
- [12. VS Code 编辑器](#12-vs-code-编辑器)
- [13. iOS 专属](#13-ios-专属)
- [14. Xcode 调试符号](#14-xcode-调试符号)
- [15. Claude Code](#15-claude-code)
- [16. React Native 日志](#16-react-native-日志)
- [gitignore 语法速查](#gitignore-语法速查)

---

## 1. macOS 系统文件

```gitignore
.DS_Store
.AppleDouble
.LSOverride
```

| 条目 | 说明 |
|---|---|
| `.DS_Store` | macOS Finder 在每个文件夹中自动生成的隐藏文件，记录文件夹的显示属性（图标位置、排序方式、窗口大小等）。每台 Mac 的 `.DS_Store` 内容不同，提交到 git 会产生无意义的冲突。 |
| `.AppleDouble` | macOS 在非 HFS+ 文件系统（如 NFS、SMB 共享盘）上存储资源分叉（resource fork）时创建的隐藏目录。开发中几乎不会用到，属于系统垃圾文件。 |
| `.LSOverride` | macOS Launch Services 的覆盖配置文件，用于自定义文件类型的默认打开方式。属于个人偏好，不应纳入版本管理。 |

> **关于重复项：** 实际的 `.gitignore` 文件中 `.DS_Store` 出现了两次——分别在文件开头的 `# OSX` 区块和后面的 `# macOS` 区块中。这不会导致问题（gitignore 允许重复规则），但属于模板合并时的冗余，可以安全地删除其中一个。
>
> **最佳实践：** 建议在全局 gitignore（`~/.gitignore_global`）中也添加 `.DS_Store`，这样所有项目都会自动忽略。

---

## 2. Xcode 相关

```gitignore
build/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata
*.xccheckout
*.moved-aside
DerivedData
*.hmap
*.ipa
*.xcuserstate
*.xcodeproj/project.xcworkspace/
```

| 条目 | 说明 |
|---|---|
| `build/` | Xcode 的构建输出目录。包含编译后的二进制文件、中间产物等。每次构建都会重新生成，体积巨大且因机器环境不同而不同。 |
| `*.pbxuser` | Xcode 3.x 时代的用户级项目设置（断点、编辑器状态等）。属于个人偏好，不同开发者的内容不同。 |
| `!default.pbxuser` | 例外规则：保留 `default.pbxuser`。这是 Xcode 的默认用户配置模板，团队可以共享作为基准。`!` 前缀表示"不忽略"。 |
| `*.mode1v3` / `*.mode2v3` | Xcode 3.x 的窗口布局配置文件（v3 版格式）。mode1 对应单窗口模式，mode2 对应分屏模式。现代 Xcode 已不使用这些格式，但模板保留了兼容性规则。 |
| `*.perspectivev3` | Xcode 3.x 的"透视图"布局文件，记录编辑器面板排列。同样已过时。 |
| `xcuserdata` | **最重要的 Xcode 忽略项之一。** 该目录位于 `.xcodeproj` 和 `.xcworkspace` 内部，存储每个开发者的个人设置：断点、UI 状态、Scheme 配置等。内容因人而异，提交会导致频繁冲突。 |
| `*.xccheckout` | Xcode Server（持续集成）使用的源码检出信息文件。记录 SCM 仓库地址和版本，由 CI 自动生成。 |
| `*.moved-aside` | Xcode 在重构代码时自动创建的备份文件。例如重命名一个类时，原文件会被加上 `.moved-aside` 后缀。属于临时备份，不应入库。 |
| `DerivedData` | Xcode 的主要缓存目录，包含索引数据、编译缓存、预编译头、模块缓存等。默认位于 `~/Library/Developer/Xcode/DerivedData/`，但也可能出现在项目内。体积可达数 GB。 |
| `*.hmap` | Header Map 文件。Xcode 编译时生成的头文件索引映射，用于加速 `#import` 查找。属于编译中间产物。 |
| `*.ipa` | iOS App Store Package，即 iOS 应用安装包。由 Xcode Archive 导出，体积大，应通过 CI/CD 流水线分发而非 git。 |
| `*.xcuserstate` | Xcode 用户界面状态的二进制序列化文件（在 `xcuserdata` 内）。记录编辑器光标位置、展开的文件夹等。变更极其频繁，是最常见的"脏文件"来源。 |
| `*.xcodeproj/project.xcworkspace/` | `xcodeproj` 内部自动生成的 workspace 目录。注意使用了精确路径 `*.xcodeproj/` 前缀，不会影响根目录下的 `demo.xcworkspace`（那个需要入库，因为 CocoaPods 依赖它）。 |

---

## 3. Android / IntelliJ 相关

```gitignore
build/
.idea
.gradle
local.properties
*.iml
*.hprof
.cxx/
*.keystore
!debug.keystore
```

虽然本项目当前仅支持 iOS，但保留 Android 忽略规则是 React Native 项目的惯例，便于未来扩展。

| 条目 | 说明 |
|---|---|
| `build/` | Android Gradle 构建输出目录（与 Xcode 的 `build/` 规则合并）。 |
| `.idea` | IntelliJ IDEA / Android Studio 的项目配置目录。存储编辑器偏好、代码风格、运行配置等。类似 Xcode 的 `xcuserdata`，属于个人设置。 |
| `.gradle` | Gradle 的本地缓存目录，包含下载的依赖、编译缓存、守护进程日志等。 |
| `local.properties` | Android SDK 路径配置文件（如 `sdk.dir=/Users/xxx/Library/Android/sdk`）。每台机器的 SDK 安装位置不同，绝不能入库。 |
| `*.iml` | IntelliJ Module 文件。Android Studio 为每个模块生成的配置文件，记录依赖和源码路径，由 IDE 自动管理。 |
| `*.hprof` | Java/Android 堆转储文件（Heap Profile）。用于内存分析调试，体积可达数百 MB。 |
| `.cxx/` | Android NDK 的 CMake 构建缓存目录。C/C++ 编译中间产物。 |
| `*.keystore` | Android 签名密钥库文件。**包含私钥，属于机密信息**，泄漏会导致应用签名被冒用。 |
| `!debug.keystore` | 例外：保留调试签名文件。Android 的 `debug.keystore` 是所有开发者共享的调试签名，密码固定为 `android`，不含敏感信息，团队共享可以避免调试包签名不一致的问题。 |

---

## 4. Node.js 相关

```gitignore
node_modules/
npm-debug.log
yarn-error.log
```

| 条目 | 说明 |
|---|---|
| `node_modules/` | npm/yarn 安装的所有第三方依赖包。本项目约 360+ 个包，体积数十 MB。所有依赖都可以通过 `package.json` + `package-lock.json` 精确还原，无需也不应纳入 git。 |
| `npm-debug.log` | npm 命令执行失败时自动生成的调试日志。包含执行环境、错误堆栈等调试信息，属于临时文件。 |
| `yarn-error.log` | Yarn 包管理器的错误日志。即使项目使用 npm，保留此规则可防止误提交（如某次临时使用了 yarn）。 |

---

## 5. Fastlane 相关

```gitignore
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/screenshots
**/fastlane/test_output
```

Fastlane 是 iOS/Android 自动化发布工具。虽然本项目尚未集成，但预留了忽略规则。

| 条目 | 说明 |
|---|---|
| `report.xml` | Fastlane 每次执行的运行报告（XML 格式），记录每个 action 的耗时和结果。 |
| `Preview.html` | Fastlane Snapshot 生成的截图预览页面，用于在浏览器中查看多设备/多语言截图。 |
| `screenshots` | 自动化截图输出目录。截图可随时重新生成，且体积较大。 |
| `test_output` | 单元测试和 UI 测试的输出结果目录。 |

> `**/` 前缀表示匹配任意深度的子目录。

---

## 6. JS Bundle 产物

```gitignore
*.jsbundle
```

| 条目 | 说明 |
|---|---|
| `*.jsbundle` | React Native 的离线 JS Bundle 文件。由 `npm run bundle:ios` 生成（对应命令 `react-native bundle`）。这是编译产物，可随时重新生成，且体积较大（通常数百 KB 到数 MB）。生产环境通过 CI 构建，开发环境通过 Metro 实时加载，因此不需要入库。 |

---

## 7. Ruby / CocoaPods

```gitignore
/vendor/bundle/
```

| 条目 | 说明 |
|---|---|
| `/vendor/bundle/` | 当使用 `bundle install --path vendor/bundle` 将 Ruby gems 安装到项目目录时，所有 gem 包会存放在这里。类似 `node_modules`，可通过 `Gemfile.lock` 还原，不应入库。前缀 `/` 表示仅匹配项目根目录。 |

**关于 `Podfile.lock`：** 本项目**未忽略** `Podfile.lock`，这是正确的做法。CocoaPods 官方强烈建议将 `Podfile.lock` 纳入版本管理，它精确锁定每个 Pod 的版本和依赖树，确保团队所有成员安装完全相同的版本。

**关于 `Pods/` 目录：** 见下方 [iOS 专属](#13-ios-专属) 部分。

---

## 8. Metro 打包器

```gitignore
.metro-health-check*
```

| 条目 | 说明 |
|---|---|
| `.metro-health-check*` | Metro Bundler 的健康检查临时文件。Metro 是 React Native 的 JavaScript 打包器（类似 Webpack），它在运行时会创建这些文件来监控文件系统 watcher 是否正常工作。文件名格式通常为 `.metro-health-check-<timestamp>`。属于运行时临时文件。 |

---

## 9. 测试覆盖率

```gitignore
/coverage
```

| 条目 | 说明 |
|---|---|
| `/coverage` | Jest（React Native 默认测试框架）生成的代码覆盖率报告目录。包含 HTML 报告、LCOV 数据等。每次运行测试都会重新生成，且可能因本地环境不同而有差异。 |

---

## 10. Expo 相关

```gitignore
.expo/
dist/
web-build/
*.orig.*
```

Expo 是 React Native 的托管开发平台。本项目使用裸 RN（非 Expo），但保留规则以防兼容。

| 条目 | 说明 |
|---|---|
| `.expo/` | Expo CLI 的本地缓存和配置目录。 |
| `dist/` | Expo 的 production build 输出目录。 |
| `web-build/` | Expo Web 平台的构建输出目录。 |
| `*.orig.*` | 合并冲突解决后的原始文件备份。git merge 或某些工具会在解决冲突后保留 `.orig` 后缀的副本。 |

---

## 11. Windows 系统文件

```gitignore
Thumbs.db
ehthumbs.db
Desktop.ini
```

| 条目 | 说明 |
|---|---|
| `Thumbs.db` | Windows 资源管理器生成的图片缩略图缓存数据库。 |
| `ehthumbs.db` | Windows Media Center 的缩略图缓存（较旧的 Windows 版本）。 |
| `Desktop.ini` | Windows 文件夹自定义配置文件（图标、显示名称等）。 |

> 即使团队全部使用 macOS，保留这些规则也是好习惯。防止有人在 Windows 上临时 clone 项目后产生脏文件。

---

## 12. VS Code 编辑器

```gitignore
.vscode/
```

| 条目 | 说明 |
|---|---|
| `.vscode/` | VS Code 的项目级配置目录。包含 `settings.json`（编辑器设置）、`launch.json`（调试配置）、`extensions.json`（推荐扩展）等。通常属于个人偏好，但有些团队会选择保留 `extensions.json` 和 `settings.json` 来统一开发环境。如有此需求，可改为仅忽略特定文件。 |

---

## 13. iOS 专属

```gitignore
Pods/
.xcode.env
```

| 条目 | 说明 |
|---|---|
| `Pods/` | CocoaPods 安装的第三方依赖源码目录。本项目依赖包括 Kingfisher、Alamofire、SnapKit、Lottie、SwiftProtobuf 以及 React Native 核心库。所有内容可通过 `pod install` + `Podfile.lock` 精确还原。忽略 `Pods/` 可显著减小仓库体积（通常节省数百 MB）。 |
| `.xcode.env` | React Native 新架构引入的环境变量文件，主要用于指定 Node.js 的安装路径（如 `export NODE_BINARY=$(command -v node)`）。每台机器的 Node 路径可能不同，因此应忽略。 |

> **关于 `Pods/` 是否应该入库的争论：** CocoaPods 官方不做强制要求。忽略的好处是仓库更小、PR diff 更干净；入库的好处是 clone 后无需额外安装即可编译。本项目选择忽略，通过 `Podfile.lock` 保证可重复安装。

---

## 14. Xcode 调试符号

```gitignore
*.dSYM
*.dSYM.zip
```

| 条目 | 说明 |
|---|---|
| `*.dSYM` | Debug Symbol（调试符号）包。Xcode 编译时为每个二进制文件生成对应的 `.dSYM` 目录，包含符号表，用于将崩溃日志中的内存地址还原为可读的函数名和行号。体积可达数十 MB，且每次编译都会重新生成。生产环境的 dSYM 应通过 CI 上传到崩溃分析平台（如 Sentry、Firebase Crashlytics），而非存储在 git 中。 |
| `*.dSYM.zip` | dSYM 包的压缩归档。某些 CI 工具或分发平台会要求打包为 zip 上传。 |

---

## 15. Claude Code

```gitignore
.claude/
```

| 条目 | 说明 |
|---|---|
| `.claude/` | Claude Code（Anthropic 的 AI 编程助手）的本地项目配置目录。存储会话上下文、记忆文件等。属于个人开发工具配置，不应纳入版本管理。 |

---

## 16. React Native 日志

```gitignore
*.log
```

| 条目 | 说明 |
|---|---|
| `*.log` | 匹配所有 `.log` 后缀的文件。覆盖 Metro 运行日志、npm 调试日志等各类日志文件。日志是临时的运行时输出，不应入库。注意这条规则范围较广，会忽略项目中所有日志文件。 |

---

## gitignore 语法速查

| 语法 | 含义 | 示例 |
|---|---|---|
| `filename` | 匹配任意目录下的该文件名 | `.DS_Store` 匹配所有目录中的 `.DS_Store` |
| `directory/` | 匹配目录（尾部 `/` 表示仅匹配目录） | `node_modules/` |
| `/path` | 仅匹配项目根目录下的路径（前缀 `/`） | `/coverage` 只匹配根目录的 coverage |
| `*` | 匹配除 `/` 以外的任意字符 | `*.log` 匹配所有 .log 文件 |
| `**` | 匹配任意层级的目录 | `**/fastlane/` 匹配任意深度下的 fastlane |
| `!pattern` | 取反，表示不忽略 | `!default.pbxuser` 保留该文件 |
| `#` | 注释 | `# This is a comment` |

> **优先级规则：** 后面的规则覆盖前面的规则。`!` 取反规则可以"拯救"已被忽略的文件，但无法拯救已被忽略的目录中的文件。

---

## 参考链接

- [Git 官方文档 - gitignore](https://git-scm.com/docs/gitignore)
- [GitHub 官方 gitignore 模板集合](https://github.com/github/gitignore)
- [CocoaPods 官方 - 是否应该忽略 Pods 目录](https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control)
