

Pod::Spec.new do |s|
  s.name             = 'MFExtractColor'
  s.version          = '1.0.0'
  s.summary          = 'Fetches the most dominant and prominent colors from an image.'



  s.homepage         = 'https://github.com/GodzzZZZ/MFExtractColor'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GodzzZZZ' => 'GodzzZZZ@qq.com' }
  s.source           = { :git => 'https://github.com/GodzzZZZ/MFExtractColor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MFExtractColorDemo/MFExtractColorDemo/MFExtractColor/*.{h,m}'
  

  s.frameworks = "UIKit", "Foundation"
end
