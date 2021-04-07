#
# Be sure to run `pod lib lint MMRtcKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMRtcKit'
  s.version          = '0.3.0'
  s.summary          = 'A short description of MMRtcKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitea.bjx.cloud/RTCgroup/mmsdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cf_olive@163.com' => 'songchaofei@bjx.cloud' }
#  s.source           = { :git => 'https://gitea.bjx.cloud/RTCgroup/mmsdk-ios.git', :tag => s.version.to_s }
  s.source           = { :git => 'https://gitea.bjx.cloud/RTCgroup/mmsdk-ios.git', :branch => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.requires_arc = true
#  s.static_framework = true

  s.source_files = 'MMRtcKit/MMRtcKit/Classes/**/*'
  
#   s.resource_bundles = {
#     'MMRtcKit' => ['MMRtcKit/Assets/*.framework']
#   }
  
  s.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    'OTHER_LDFLAGS' => '-ObjC',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }
  
  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }

  s.public_header_files = 'MMRtcKit/MMRtcKit/Classes/MMRtcKit.h','MMRtcKit/MMRtcKit/Classes/MMRtcEngineKit.h','MMRtcKit/MMRtcKit/Classes/MMRtcEnumerates.h','MMRtcKit/MMRtcKit/Classes/MMRtcInternal/Rtc/MMRtcVideoCanvas.h', 'MMRtcKit/MMRtcKit/Classes/MMRtcInternal/Rtc/MMRtcVideoConfiguration.h','MMRtcKit/MMRtcKit/Classes/MMRtcInternal/Rtc/MMRtcUser.h'

  # 系统库
  s.frameworks = 'UIKit', 'AudioToolbox', 'VideoToolbox', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'MediaPlayer', 'MobileCoreServices', 'OpenGLES', 'QuartzCore'
  s.libraries = 'bz2', 'c++', 'z'
  # 三方库
  s.vendored_frameworks = 'MMRtcKit/third_party/IJKMediaFramework.framework', 'MMRtcKit/third_party/WebRTC.framework'
  
  # s.dependency 'AFNetworking', '~> 2.3'
end
