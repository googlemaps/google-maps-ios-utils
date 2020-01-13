Version 2.1.0 - September 2017
==============================
Features:
- Added Heatmaps rendering.
- Added a constructor for setting custom background colors of cluster icons.

Resolved Issues:
- Forwarded mapView:didTapPOIWithPlaceID:name:location to underlying mapDelegate.
- Fixed a minor Swift compatibility issue.

Version 2.0.0 - May 2017
========================
Features:
- KML and GeoJSON rendering.
- Changed GMUClusterManagerDelegate's methods to return a BOOL to indicate
whether the event should pass through to other handlers. This will give
applications the ability to allow the default info window to be shown
when tapping on a marker. Please note this is a breaking change so existing
code needs to be updated.

Version 1.1.2 - October 2016
============================
Resolved Issues:
- Fixed include paths to work properly with cocoapods.

Version 1.1.1 - October 2016
============================
Resolved Issues:
- Added missing CHANGELOG.

Version 1.1.0 - October 2016
============================
Features:
- Allowed easy customization of markers by introducing GMUClusterRendererDelegate
delegate on GMUDefaultClusterRenderer.

Version 1.0.1 - July 2016
=========================
Resolved Issues:
- Added a workaround for cocoapods issue with GoogleMaps 2.0.0.

Version 1.0.0 - July 2016
=========================
Initial release of Marker Clustering.
