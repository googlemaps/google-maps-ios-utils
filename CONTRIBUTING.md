## Contributing

Want to help out? That's awesome!

The library is open source and lives on GitHub at:
https://github.com/googlemaps/google-maps-ios-utils
Open an issue or fork the library and submit a pull request.

Keep in mind that before we can accept any pull requests we have to jump
through a couple of legal hurdles, primarily a Contributor License Agreement
(CLA):

- **If you are an individual writing original source code**
  and you're sure you own the intellectual property,
  then you'll need to sign an
  [individual CLA](https://developers.google.com/open-source/cla/individual).
- **If you work for a company that wants to allow you to contribute your work**,
  then you'll need to sign a
  [corporate CLA](https://developers.google.com/open-source/cla/corporate)

Follow either of the two links above to access the appropriate CLA and
instructions for how to sign and return it.

When preparing your code, make sure to update the AUTHORS and CONTRIBUTORS file
to reflect your contribtion.

Once we receive your CLA, we'll be able to review and accept your pull requests.

### Setup
1. git clone the repository
2. Install Carthage if you don't have it installed already
    ```
    brew install carthage
    ```
3. Run `carthage update --platform ios`
4. There should be 3 schemes: *GoogleMapsUtils*, *DevApp*, and *UnitTest*
    * The *GoogleMapsUtils* scheme builds `GoogleMapsUtils.framework`
    * The *DevApp* scheme is the test app which uses some features of *GoogleMapsUtils*
    * The *UnitTest* scheme runs unit tests
