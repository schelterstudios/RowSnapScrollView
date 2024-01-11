RowSnapScrollView
========================

[![platform](https://img.shields.io/badge/platform-macOS%20|%20iOS%20|%20watchOS%20|%20tvOS%20|%20Linux-blue.svg)]()
[![SwiftPM-compatible](https://img.shields.io/badge/SwiftPM-✔-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

__RowSnapScrollView__ is a view written in SwiftUI. It expands on ScrollView with custom scroll target behavior to enable it to behave like a table view that snaps to variable-height rows.


## Usage

```swift
import RowSnapScrollView
import SwiftUI

struct ContentView: View {
    let myData: [MyRowData]
    @State private var snappedData: MyRowData?

    var body: some View {
        RowSnapScrollView(myData, snappedItem: $snappedData) { item in
            let height: CGFloat = ## // Determine item height here
            return height
        } content: { item in
            MyRowDataView(data: item)
        }
    }
}
```


## Installation

RowSnapScrollView is SwiftPM-compatible. To install, add this package to your `Package.swift` or your Xcode project.

```swift
dependencies: [
    .package(name: "RowSnapScrollView", url: "https://github.com/schelterstudios/RowSnapScrollView", from: Version(1, 0, 2)),
],
```
