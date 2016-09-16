Integrating with Swift projects which use 'use_frameworks!' in the Podfile
==========================================================================
It is a known issue that adding the utility library to a Podfile which has
'use_frameworks!' will cause the error, "target has transitive dependencies
that include static binaries". Until GoogleMaps is a dynamic framework (when we
stop supporting iOS 7.0), you need to add the library manually to your project
to work around the issue.

**Follow these steps:**
- Remove Google-Maps-iOS-Utils from the Podfile (if it is there).
- In your project create a group named 'Google-Maps-iOS-Utils'.
- Download the repo into your local computer.
- Add the folders inside the src directory into your project by right clicking
on the 'Google-Maps-iOS-Utils' group and selecting "Add Files to ..." (Make sure
you select the target as your app target to avoid undefined symbols issue).
- Make sure "Use Header Map" is ON for your app target in XCode Settings (it is
ON by default in XCode).
- Add a bridging header file with ```#import "GMUMarkerClustering.h"``` (*note
the relative path*).
- Open the umbrella header ```GMUMarkerClustering.h``` (under the
Google-Maps-iOS-Utils/Cluster group) and change all the import paths to
relative. For example, change ```#import <Google-Maps-iOS-Utils/GMUCluster.h>```
to ```#import "GMUCluster.h"```. (The 'Use Header Map' setting will resolve the
relative path correctly).
- Build your project.
- That's it.
