// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "strings-file-lib",
    dependencies: [
        .Package(url: "https://github.com/hectr/swift-regex.git", majorVersion: 0),
        .Package(url: "https://github.com/hectr/swift-stream-reader.git", majorVersion: 0)
    ]
)
