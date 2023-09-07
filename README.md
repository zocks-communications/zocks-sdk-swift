# iOS Swift SDK for Zocks

## Installation

This SDK is available as a Swift Package.

### Using as Swift Package

```swift title="Package.swift"
let package = Package(
  ...
  dependencies: [
    .package(name: "Zocks", url: "https://github.com/zocks-communications/zocks-sdk-swift.git", .upToNextMajor("1.0.0")),
  ],
  targets: [
    .target(
      name: "MyApp",
      dependencies: ["Zocks"]
    )
  ]
}
```

### XCode

Go to File -> Add Packages.

In the search field enter: `https://github.com/zocks-communications/zocks-sdk-swift`

Select the package and click Add Package.


## Usage

Populate the roomId, accountId and token with your data in this sample app.

```swift
import SwiftUI
import Zocks

let roomId = "<enter room id here>"
let configuration = Configuration(
    accountId: "<enter your account id>",
    getToken: { "<enter token here or call a function acquiring the token>" }
)

@main
struct ZocksExampleApp: App {
    
    init() {
        Zocks.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            MeetingView(configuration: configuration, id: roomId)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
}
```
