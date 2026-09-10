# SOLUTION.md

## Overview

MrDVendorYNC is a SwiftUI app (iOS 16+) with three areas, a vendor list backed by a REST JSON flow, a Google Maps view with a Places powered "add vendor by search" flow, and a Keychain backed session token screen.

## Architecture

Each capability is a small protocol with a concrete implementation swapped in from one place, `AppComposition.swift`:

View models (`VendorListViewModel`, `SettingsViewModel`, `PlaceSearchViewModel`) depend only on the protocols, not the concrete types, so views never know or care whether data is mocked. I applied the same pattern to vendor data and token storage for consistency, and because it makes the app easily testable.


## Map with markers + Places search

**Enhancement chosen**: place search → add as a new vendor with a marker over the address coordinates alternative.

- **Both SPM packages are linked dependencies** (`googlemaps/ios-maps-sdk` and `googlemaps/ios-places-sdk`, GoogleMaps + GooglePlaces products).
- **Google Maps SDK**: `GoogleMapView` wraps `GMSMapView` via `UIViewRepresentable`. Selecting a vendor from the list animates the view to that vendor's coordinate and opens its marker's info window. The only gate deciding real map vs placeholder is `AppConfig.hasGoogleAPIKey`. The variable to note is a real APIKey needs to be configured for use.
- **Places search**: The variable to note is a real APIKey needs to be configured for use.
- **Going live with both**: get an API key from Google, replace the placeholder value in `MrDVendorYNC/GoogleAPIConfig.plist` with the real key, and change `AppComposition.makePlacesService()`'s `useLiveBackend: false` to `true`.
- **API key handling**: `GoogleAPIConfig.plist` is a small physical plist containing just `GoogleAPIKey` one key, passed to both `GMSServices.provideAPIKey` and `GMSPlacesClient.provideAPIKey` in `MrDVendorYNCApp.swift`'s `init()`.

## Testing

One focused `XCTestCase` (`MrDVendorYNCTests/MrDVendorYNCTests.swift`, class `VendorServiceTests`) targets `VendorService.decodeVendors(from:)`:
- Decodes a full JSON payload into `[Vendor]`, asserting every field including the optional `coordinate`.
- Asserts malformed JSON throws `AppError.decoding` rather than an uncaught `DecodingError`, since the app handles all erros in one centralised place.

## Known trade-offs

- **Map and Places aren't tested against real Google traffic** by design, given no API key was available as I am not comfortable with inputting my credit card details to Google to generate a free tier API Key. Both SPM packages are actually linked, and the integration code compiles against and has been verified correct for the real SDKs' current API. What's still unverified is behavior against live network traffic, since there's no API key to test with.
- **No offline caching** — vendors are refetched from scratch each reload, a real app would likely cache the last successful list.
