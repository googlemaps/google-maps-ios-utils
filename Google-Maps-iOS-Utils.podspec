

Pod::Spec.new do |s|

  s.name         = "Google-Maps-iOS-Utils"
  s.version      = "5.0.0"
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
  s.source       = { :git => "https://github.com/wangela/google-maps-ios-utils.git",
                    :branch => "wangela-wip" }
  s.source_files = "Sources/CGoogleMapsUtils/include/*.{h,m}", "Sources/GoogleMapsUtils/**/*.{swift}"
  s.preserve_paths = "Sources/CGoogleMapsUtils/include/module.modulemap"
  s.requires_arc = true
  s.module_name = "GoogleMapsUtils"
  s.swift_version = '5.9'

  s.dependency 'GoogleMaps', '~> 8.0'
  s.static_framework = true

  s.test_spec 'Tests' do |unit_tests|
    unit_tests.source_files = [
      "TestsCocoapods/GoogleMapsUtilsObjCTests/unit/**/*.{h,m}",
      "TestsCocoapods/GoogleMapsUtilsSwiftTests/unit/**/*.swift",
      "TestsCocoapods/GoogleMapsUtilsTestsHelper/include/*.{h,m}"
    ]
    unit_tests.exclude_files = "TestsCocoapods/GoogleMapsUtilsObjCTests/unit/GoogleMapsUtilsSwiftTests-Bridging-Header.h"
    unit_tests.preserve_paths = "TestsCocoapods/CGoogleMapsUtilsTests/unit/GoogleMapsUtilsSwiftTests-Bridging-Header.h"
    unit_tests.resources = [
      "TestsCocoapods/GoogleMapsUtilsSwiftTests/resources/**/*.{geojson,kml}"
    ]
    unit_tests.pod_target_xcconfig = {
      'SWIFT_OBJC_BRIDGING_HEADER' => "$(PODS_TARGET_SRCROOT)/TestsCocoapods/CGoogleMapsUtilsTests/unit/GoogleMapsUtilsSwiftTests-Bridging-Header.h"
    }
    unit_tests.dependency 'GoogleMaps'
    unit_tests.dependency 'OCMock'
  end
end
