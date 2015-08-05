Pod::Spec.new do |s|

  s.name         = "PaperKit"
  s.version      = "0.5.4"
  s.summary      = "Paper like user interface for iOS"
  s.homepage     = "https://github.com/1amageek/PaperKit"
  s.screenshots  = "https://github.com/1amageek/PaperKit/blob/master/PaperKit.gif"
  s.license      = { :type => "BSD" }
  s.author    = "1amageek"
  s.social_media_url   = "https://twitter.com/1_am_a_geek"
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/1amageek/PaperKit.git", :tag => "0.5.4" }
  s.source_files  = ["PaperKit/**/*.{h,m}"]
  s.exclude_files = ['PaperKit/AppDelegate.*', 'main.m', 'PaperKit.mov', 'PaperKit.gif']
  s.public_header_files = "PaperKit/**/*.h"
  s.dependency "pop", "~> 1.0"

end
