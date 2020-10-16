Customize cluster and item markers
==================================
As of version 1.1.0 we have added new features for easy customization of
markers. There is a new delegate [GMUClusterRendererDelegate]
[gmuclusterrendererdelegate] on ```GMUDefaultClusterRenderer``` which allows
developers to customize properties of a marker before and after it is added
to the map. Using this new delegate you can achieve something cool like this:

<p align="center"><img vspace="20" src="https://cloud.githubusercontent.com/assets/16808355/18979908/62b15fe2-8712-11e6-9931-cd66fae38cba.png"></p>


See [CustomMarkerViewController][custommarkerviewcontroller] for the
implementation.

[custommarkerviewcontroller]: https://github.com/googlemaps/google-maps-ios-utils/blob/master/app/CustomMarkerViewController.m
[gmuclusterrendererdelegate]: https://github.com/googlemaps/google-maps-ios-utils/blob/master/src/Clustering/View/GMUDefaultClusterRenderer.h
