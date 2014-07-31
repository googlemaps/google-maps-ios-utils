Pod::Spec.new do |s|

  s.name         = "Google-Maps-iOS-Utils-QuadTree"
  s.version      = "0.1"
  s.summary      = "A QuadTree library for use with Google Maps iOS SDK."
  s.description  = <<-DESC
                   This library enables you to store geographic points in a QuadTree.
                   It is designed to be used with Google Maps iOS SDK, but it is not
                   dependent on it.
                   DESC
  s.homepage     = "https://github.com/googlemaps/google-maps-ios-utils"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author       = { "Brett Morgan" => "brettmorgan@google.com" }
  s.platform     = :ios, '5.0'
  s.source       = { :git => "https://github.com/googlemaps/google-maps-ios-utils.git", 
                     :tag => "0.1" }
  s.source_files = '{QuadTree,Clustering}/**/*.{h,m}'
  s.requires_arc = true

end
