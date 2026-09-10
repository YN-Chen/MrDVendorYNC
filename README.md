# MrDVendorYNC

A SwiftUI iOS app for discovering nearby vendors on a map, with secure session token storage.

## Requirements

- Xcode 15+ (built and tested with Xcode 26.6 / iOS 26.5 SDK)
- iOS 16+ deployment target
- No backend needed, vendor data works with local mocked JSON

## Running locally

1. Open `MrDVendorYNC/MrDVendorYNC.xcodeproj` in Xcode.
2. Select any iPhone simulator (iOS 16+) and hit **Run** (⌘R). No API keys or setup are required as it will use local mocks.
3. For the map, see **Enabling the live map** below, until then the map area shows a placeholder explaining what's missing.

## Running the tests

⌘U in Xcode


## Enabling the live map (Google Maps SDK)

The Google Maps and Google Places SPM packages are already added and linked to the project. The only thing missing is a real API key:

1. Get a Google Maps API key ([console.cloud.google.com](https://console.cloud.google.com), enable "Maps SDK for iOS").
2. Open `MrDVendorYNC/GoogleAPIConfig.plist` and replace `YOUR_GOOGLE_MAPS_API_KEY` with your real key.
3. Rebuild and run. `GoogleMapView` checks `AppConfig.hasGoogleAPIKey` before showing the real map, falling back to a friendly placeholder if no real key is present, rather than a broken/blank map.

## Places search

Tapping the search icon in the Vendors toolbar opens "Add a Vendor," where you can search by name/address and add a result as a new vendor with a marker. This ships using `PlacesService`'s mock path and no API key needed by default, flip `useLiveBackend` in `AppComposition.makePlacesService()` to `true` alongside a real key in `GoogleAPIConfig.plist` to switch to live Google Places results. See SOLUTION.md for details.
