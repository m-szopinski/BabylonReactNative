require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-babylon"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "12.0", :osx => "10.15" }
  s.source       = { :git => package["repository"]["url"], :tag => s.version }

  s.ios.source_files = "ios/**/*.{h,m,mm}"
  s.osx.source_files = "macos/**/*.{h,m,mm}"
  s.requires_arc = true
  s.xcconfig     = { 'USER_HEADER_SEARCH_PATHS' => '$(inherited) ${PODS_TARGET_SRCROOT}/shared ${PODS_TARGET_SRCROOT}/../react-native/shared' }

  s.vendored_libraries = 'ios/libs/*.a'

  s.ios.frameworks = "MetalKit", "ARKit"
  s.osx.frameworks = "MetalKit"

  s.dependency "React"
end

