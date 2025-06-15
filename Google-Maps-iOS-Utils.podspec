

Pod::Spec.new do |s|

  s.name         = "Google-Maps-iOS-Utils"
  s.version      = "6.1.0" # x-release-please-version
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
  s.platform     = :ios, '15.0'
  s.source       = { :git => "https://github.com/googlemaps/google-maps-ios-utils.git",
                     :tag => "v#{s.version.to_s}" }
  s.source_files = "Sources/GoogleMapsUtils/**/*.{swift}"
  s.exclude_files = "Sources/GoogleMapsUtils/Exports.swift"
  s.requires_arc = true
  s.module_name = "GoogleMapsUtils"
  s.swift_version = '5.9'

  s.dependency 'GoogleMaps', '~> 9.0'
  s.static_framework = true

  s.test_spec 'Tests' do |unit_tests|
    unit_tests.source_files = [
      "Tests/GoogleMapsUtilsTests/unit/**/*.swift",
      "Tests/GoogleMapsUtilsTests/Common/**/*.swift"
    ]
    unit_tests.resources = [
      "Tests/GoogleMapsUtilsTests/Resources/GeoJSON/*.geojson",
      "Tests/GoogleMapsUtilsTests/Resources/KML/*.kml",
      "GoogleMaps.bundle"
    ]
    unit_tests.dependency 'GoogleMaps'
    unit_tests.dependency 'OCMock'
  end
end
