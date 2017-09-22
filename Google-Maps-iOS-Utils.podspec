Pod::Spec.new do |s|

  s.name         = "Google-Maps-iOS-Utils"
  s.version      = "2.1.0"
  s.summary      = "A utilities library for use with Google Maps SDK for iOS."
  s.description  = <<-DESC
                   This library contains classes that are useful for a wide range of applications
                   using the Google Maps SDK for iOS.
                   It is designed to be used with Google Maps SDK for iOS, but it is not
                   dependent on it.
                   DESC
  s.homepage     = "https://github.com/googlemaps/google-maps-ios-utils"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.authors      = "Google Inc."
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/googlemaps/google-maps-ios-utils.git",
                     :tag => "v#{s.version.to_s}" }
  s.requires_arc = true
  s.dependency 'GoogleMaps'
  s.compiler_flags = '-fno-modules'

  s.subspec 'QuadTree' do |sp|
    sp.source_files = 'src/QuadTree/**/*.{h,m}'
  end

  s.subspec 'Clustering' do |sp|
    sp.source_files = 'src/Clustering/**/*.{h,m}'
    sp.dependency 'Google-Maps-iOS-Utils/QuadTree'
  end

  s.subspec 'Geometry' do |sp|
    sp.source_files = 'src/Geometry/**/*.{h,m}'
  end

  s.subspec 'Heatmap' do |sp|
    sp.source_files = 'src/Heatmap/**/*.{h,m}'
    sp.dependency 'Google-Maps-iOS-Utils/QuadTree'
  end
end
