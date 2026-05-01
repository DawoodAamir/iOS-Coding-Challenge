# Challenge

A simple iOS app with login, posts feed, and favorites — built with SwiftUI, RxSwift, Realm, and Alamofire.

## Requirements

- Xcode 16+
- iOS 16 minimum deployment target

## Setup

1. Clone the repository.
2. Open `Challenge.xcodeproj` in Xcode and let SPM resolve packages.
3. If Realm fails to build (e.g. `is_pod` errors on newer SDKs), run:
   ```
   sh Scripts/patch-realm-core.sh
   ```
4. Build and run.
