#
# Be sure to run `pod lib lint ZKPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZKPhotoPicker'
  s.version          = '1.0.1'
  s.summary          = '基于PhotoKit的多图选择框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  #s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC

  s.homepage         = 'https://github.com/jianbinking/ZKPhotoPicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZombieKing' => '403317854@qq.com' }
  s.source           = { :git => 'https://github.com/jianbinking/ZKPhotoPicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  # s.ios.deployment_target = '11.0'
  s.platform         = :ios, '11.0'
  s.swift_versions   = '5.0'

  s.source_files = 'ZKPhotoPicker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZKPhotoPicker' => ['ZKPhotoPicker/Assets/*.png']
  # }
  s.resource =  'ZKPhotoPicker/Bundle/ZKPhotoPicker.bundle'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation', 'Photos'
  s.requires_arc = true
  # s.dependency 'AFNetworking', '~> 2.3'
end
