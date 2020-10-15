Carthage Installation Steps
===========================

1. Add this repository to your `Cartfile`.
```
github "googlemaps/google-maps-ios-utils"
```

2. Run `carthage update --platform iOS`.
3. Add the Maps SDK for iOS frameworks into your project by dragging `GoogleMaps.framework`, `GoogleMapsBase.framework` and `GoogleMapsCore.framework` in the `Carthage/Build/iOS` directory into the top level directory of your Xcode project (premium plan customers should also add `GoogleMapsM4B.framework` into the project).
4. Add the Maps SDK for iOS Utilities framework by dragging `GoogleMapsUtils.framework` in the `Carthage/Build/iOS/Static` directory into the top level directory of your Xcode project.
5. Add `GoogleMaps.bundle` by dragging `Carthage/Build/iOS/GoogleMaps.framework/Resources/GoogleMaps.bundle` into the top level directory of your Xcode project.
6. Open the _Build Phases_ tab for your application’s target, and within _Link Binary with Libraries_, add the additional following frameworks:
    * Accelerate.framework
    * CoreData.framework
    * CoreGraphics.framework
    * CoreImage.framework
    * CoreLocation.framework
    * CoreTelephony.framework
    * CoreText.framework
    * GLKit.framework
    * ImageIO.framework
    * libc++.tbd
    * libz.tbd
    * OpenGLES.framework
    * QuartzCore.framework
    * SystemConfiguration.framework
    * UIKit.framework
7. Open the _Build Settings_ tab for you application’s target, add `-ObjC` in the _Other Linker Flags_ section.
