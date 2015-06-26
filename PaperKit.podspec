Pod::Spec.new do |s|

  s.name         = "PaperKit"
  s.version      = "0.0.1"
  s.summary      = "A short description of PaperKit."
  s.description  = <<-DESC
                   DESC

  #s.homepage     = "http://EXAMPLE/PaperKit"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = { :type => "BSD", :file => "LICENSE" }
  s.author    = "1amageek"
  s.social_media_url   = "https://twitter.com/1_am_a_geek"
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/1amageek/PaperKit", :tag => "0.0.1" }
  s.source_files  = ["PaperKit/**/*.{h,m}"]
  s.public_header_files = "PaperKit/**/*.h"
  s.dependency "POP", "~> 1.0"

end
