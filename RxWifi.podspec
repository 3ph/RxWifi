#
# Be sure to run `pod lib lint RxWifi.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxWifi'
  s.version          = '0.0.1'
  s.summary          = 'RxWifi is a reactive wrapper for Wi-Fi functionality.'

# This description is used to generate tags and improve search results.

  s.description      = <<-DESC
  RxWifi is reactive wrapper is a rective wrapper for Wi-Fi functionality on iOS.
  It allows you to connect to Wi-Fi network from your app and you can also observe Wi-Fi various changes:
  - Wi-Fi is enable on the system level
  - Wi-Fi is connected to AP
  - Current connected SSID
  - Current IPv4 address
  - Current IPv6 address
                       DESC

  s.homepage         = 'https://github.com/3ph/RxWifi'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '3ph' => 'instantni.med@gmail.com' }
  s.source           = { :git => 'https://github.com/3ph/RxWifi.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'RxWifi/Classes/**/*'
  s.dependency 'RxSwift'
  s.dependency 'RxNimble'
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS[sdk=iphonesimulator*]' => '-D IOS_SIMULATOR', 'SWIFT_VERSION' => '4.0' }
end
