source 'https://cdn.cocoapods.org/'
platform :ios, '18.0'

# 加载 React Native CocoaPods 辅助脚本
require_relative 'node_modules/react-native/scripts/react_native_pods'

target 'demo' do
  # 注意：移除了 use_frameworks!
  # 解决 Xcode 14+ libarclite 被移除导致的编译错误

  # 图片加载
  pod 'Kingfisher', '~> 8.0'

  # Lottie 动画
  pod 'lottie-ios', '~> 4.5'

  # Protobuf 序列化
  pod 'SwiftProtobuf', '~> 1.28'

  # 网络请求
  pod 'Alamofire', '~> 5.9'

  # 布局
  pod 'SnapKit', '~> 5.7'

  # =============================================
  # React Native 集成
  # =============================================
  use_react_native!(
    :path => 'node_modules/react-native',
    :fabric_enabled => false,
    :app_path => __dir__,
    :config_file_dir => __dir__
  )

  # =============================================
  # ObjC 桥接层
  # =============================================
  pod 'RNViewFactory', :path => 'LocalPods/RNViewFactory'

end

# RN post_install 钩子
post_install do |installer|
  react_native_post_install(
    installer,
    'node_modules/react-native',
    :mac_catalyst_enabled => false
  )

  # 强制所有 pods 部署目标为 18.0
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
    end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 修复 Xcode 26 swiftinterface 验证失败
      config.build_settings['SWIFT_VERIFY_EMITTED_MODULE_INTERFACE'] = 'NO'
      config.build_settings['SWIFT_EMIT_MODULE_INTERFACE'] = 'NO'
    end
  end

  # 修复 RCTSwiftUI 重复类：预编译 React.framework 已包含这些类，
  # 需要从 xcconfig 中移除对应的 -l 链接，并清空源文件避免重复编译
  Dir.glob("Pods/Target Support Files/Pods-demo/*.xcconfig").each do |path|
    content = File.read(path)
    content = content.gsub(' -l"RCTSwiftUI"', '').gsub(' -l"RCTSwiftUIWrapper"', '')
    File.write(path, content)
  end

  # 清空 RCTSwiftUI/RCTSwiftUIWrapper 的源文件列表，防止重复编译
  %w[RCTSwiftUI RCTSwiftUIWrapper].each do |name|
    target = installer.pods_project.targets.find { |t| t.name == name }
    next unless target
    target.source_build_phase.files.to_a.each do |f|
      target.source_build_phase.remove_build_file(f)
    end
  end
  installer.pods_project.save
end
