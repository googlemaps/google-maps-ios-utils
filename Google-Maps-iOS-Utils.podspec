

Pod::Spec.new do |s|

  s.name         = "Google-Maps-iOS-Utils"
  s.version      = "4.2.2"
  s.summary      = "A utilities library for use with Google Maps SDK for iOS."
  s.description  = "
                   This library contains classes that are useful for a wide range of applications
                   using the Google Maps SDK for iOS.
                   It is designed to be used with Google Maps SDK for iOS, but it is not
                   dependent on it.
                   "
  s.homepage     = "https://github.com/googlemaps/google-maps-ios-utils"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.authors      = "Google Inc."
  s.platform     = :ios, '14.0'
  s.source       = { :git => "https://github.com/googlemaps/google-maps-ios-utils.git",
                    :branch => "wangela/8-0-0" }
  s.requires_arc = true
  s.module_name = "GoogleMapsUtils"
  s.swift_version = '5.3'

  s.dependency 'GoogleMaps'
  s.static_framework = true

  s.subspec 'QuadTree' do |sp|
    sp.public_header_files = "Sources/GoogleMapsUtils/include/*.h"
    sp.source_files = "Sources/GoogleMapsUtils/include/*.{h,m}", "Sources/GoogleMapsUtilsSwift/#{sp.base_name}/**/*.swift"
  end

  s.subspec 'Clustering' do |sp|
    sp.public_header_files = "Sources/GoogleMapsUtils/include/*.h"
    sp.source_files = "Sources/GoogleMapsUtils/include/*.{h,m}", "Sources/GoogleMapsUtilsSwift/#{sp.base_name}/**/*.swift"
    sp.exclude_files = "Sources/GoogleMapsUtils/include/GMUMarkerClustering.h"
    sp.dependency 'Google-Maps-iOS-Utils/QuadTree'
  end

  s.subspec 'Geometry' do |sp|
     sp.public_header_files = "Sources/GoogleMapsUtils/include/*.h"
     sp.source_files = "Sources/GoogleMapsUtils/include/*.{h,m}", "Sources/GoogleMapsUtilsSwift/#{sp.base_name}/**/*.swift"
  end

  s.subspec 'Heatmap' do |sp|
    sp.public_header_files = "Sources/GoogleMapsUtils/include/*.h"
    sp.source_files = "Sources/GoogleMapsUtils/include/*.{h,m}", "Sources/GoogleMapsUtilsSwift/#{sp.base_name}/**/*.swift"
    sp.dependency 'Google-Maps-iOS-Utils/QuadTree'
    sp.dependency 'GoogleMaps'
  end

  s.subspec 'GeometryUtils' do |sp|
    sp.source_files = "Sources/GoogleMapsUtils/include/*.{h,m}", "Sources/GoogleMapsUtilsSwift/#{sp.base_name}/**/*.swift"
  end

  s.test_spec 'Tests' do |unit_tests|
    unit_tests.source_files = [
      "Sources/GoogleMapsUtils/include/GoogleMapsUtils.h",
      "Tests/GoogleMapsUtilsTests/common/Model/*.{h,m,swift}",
      "Tests/GoogleMapsUtilsTests/unit/**/*.{h,m,swift}",
    ]
    unit_tests.resources = [
      "Tests/GoogleMapsUtilsTests/resources/**/*.{geojson,kml}"
    ]
    unit_tests.pod_target_xcconfig = {
      'SWIFT_OBJC_BRIDGING_HEADER' => "$(PODS_TARGET_SRCROOT)/Tests/GoogleMapsUtilsTests/unit/BridgingHeader/UnitTest-Bridging-Header.h"
    }
    unit_tests.dependency 'OCMock'
  end
end
