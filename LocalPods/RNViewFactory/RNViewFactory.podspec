Pod::Spec.new do |s|
  s.name         = 'RNViewFactory'
  s.version      = '1.0.0'
  s.summary      = 'React Native View Factory for Swift projects'
  s.homepage     = 'https://example.com'
  s.license      = { :type => 'MIT' }
  s.author       = { 'NewsApp' => 'newsapp@example.com' }
  s.source       = { :path => '.' }
  s.platforms   = { :ios => '15.1' }
  s.source_files = '*.{h,m}'
  s.public_header_files = 'RNViewFactory.h'
  s.dependency 'React-Core'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'MODULEMAP_FILE' => '$(PODS_TARGET_SRCROOT)/module.modulemap'
  }
end
