

Pod::Spec.new do |s|

  s.name         = "Google-Maps-iOS-Utils"
  s.version      = "6.1.2" # x-release-please-version
  s.summary      = "A utilities library for use with Google Maps SDK for iOS."
  s.description  = "
                   This library contains classes that are useful for a wide range of applications
                   using the Google Maps SDK for iOS.
                   It is designed to be used with Google Maps SDK for iOS, but it is not
                   dependent on it.
                   "
  s.homepage     = "https://github.com/googlemaps/google-maps-ios-utils"
  s.readme       = "https://github.com/googlemaps/google-maps-ios-utils/blob/main/README.md"
  s.changelog    = "https://github.com/googlemaps/google-maps-ios-utils/blob/main/CHANGELOG.md"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.authors      = "Google Inc."
  s.platform     = :ios, '16.0'
  s.source       = { :git => "https://github.com/googlemaps/google-maps-ios-utils.git",
                     :tag => "v#{s.version.to_s}" }
  s.source_files = "Sources/GoogleMapsUtilsObjC/include/*.{h,m}", "Sources/GoogleMapsUtils/**/*.{swift}"
  s.exclude_files = "Sources/GoogleMapsUtils/Exports.swift"
  s.requires_arc = true
  s.module_name = "GoogleMapsUtils"
  s.swift_version = '5.9'

  s.dependency 'GoogleMaps', '~> 10.0'
  s.static_framework = true

  s.test_spec 'Tests' do |unit_tests|
    unit_tests.source_files = [
      "Tests/GoogleMapsUtilsObjCTests/unit/**/*.{h,m}",
      "Tests/GoogleMapsUtilsSwiftTests/unit/**/*.swift",
      "Tests/GoogleMapsUtilsTestsHelper/include/*.{h,m}"
    ]
    unit_tests.exclude_files = "Tests/GoogleMapsUtilsTestsHelper/include/GoogleMapsUtilsSwiftTests-Bridging-Header.h"
    unit_tests.resources = [
      "Tests/GoogleMapsUtilsSwiftTests/Resources/GeoJSON/*.geojson",
      "Tests/GoogleMapsUtilsSwiftTests/Resources/KML/*.kml"
    ]
    unit_tests.pod_target_xcconfig = {
      'SWIFT_OBJC_BRIDGING_HEADER' => "$(PODS_TARGET_SRCROOT)/Tests/GoogleMapsUtilsTestsHelper/include/GoogleMapsUtilsSwiftTests-Bridging-Header.h"
    }
    unit_tests.dependency 'GoogleMaps'
    unit_tests.dependency 'OCMock'
  end
end
