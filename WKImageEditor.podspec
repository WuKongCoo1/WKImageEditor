#
# Be sure to run `pod lib lint WKImageEditor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WKImageEditor'
  s.version          = '1.0.0'
  s.summary          = '图片编辑工具'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  提供快捷的图片编辑功能
                       DESC

  s.homepage         = 'http://www.edu-yun.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WuKongCoo1' => 'wu_kong_coo1@163.com' }
  s.source           = { :git => 'https://github.com/WuKongCoo1/WKImageEditor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'WKImageEditor/**/*.{h,m}'

   # s.resource_bundles = {
   #   'WKImageEditor' => ['WKImageEditor/Assets/*', 'WKImageEditor/Resources/*']
   # }
   # s.resources = ['WKImageEditor/Assets/*', 'WKImageEditor/Resources/*']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'CGBase'
  s.dependency 'SDWebImage'
  # s.dependency 'CGNetworkingHub'
  # s.dependency 'CGAlertView'
  # s.dependency 'SDWebImage'
  # s.dependency 'SAMKeychain'
  # s.dependency 'Aspects'
  # s.dependency 'CGOwnLibraries'
  # s.dependency 'CGHomeHub'
  # s.dependency 'CGStudentModuleHub'
  


    # s.subspec 'Haders' do |ss|
    # ss.source_files = 'WKImageEditor/Classes/WKDefine.h'
    # end
    # s.subspec 'Model' do |ss|
    # ss.source_files = 'WKImageEditor/Classes/Model/*.{h,m}'
    # # ss.dependency 'WKImageEditor/Category'
    # end
    # s.subspec 'ViewModel' do |ss|
    # ss.source_files = 'WKImageEditor/Classes/ViewModel/*.{h,m}'
    # # ss.dependency 'WKImageEditor/Category'
    # ss.dependency 'WKImageEditor/Model'
    # ss.dependency 'WKImageEditor/View'
    # ss.dependency 'WKImageEditor/Haders'
    # end
    # s.subspec 'Controller' do |ss|
    # ss.source_files = 'WKImageEditor/Classes/Controller/*.{h,m}'
    # # ss.dependency 'WKImageEditor/Category'
    # ss.dependency 'WKImageEditor/Model'
    # ss.dependency 'WKImageEditor/ViewModel'
    # ss.dependency 'WKImageEditor/View'
    # ss.dependency 'WKImageEditor/Haders'
    # end
    # s.subspec 'View' do |ss|
    # ss.source_files = 'WKImageEditor/Classes/View/*.{h,m}'
    # # ss.dependency 'WKImageEditor/Category'
    # ss.dependency 'WKImageEditor/Model'
    # ss.dependency 'WKImageEditor/Haders'
    # end
    # s.subspec 'Target' do |ss|
    # ss.source_files = 'WKImageEditor/Classes/Target/*.{h,m}'
    # ss.dependency 'WKImageEditor/Controller'
    # end
    
end
