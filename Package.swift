// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "StringsFileLib",
    products: [
        .library(
            name: "StringsFileLib",
            targets: ["StringsFileLib"]),
        ],
    dependencies: [
        .package(url: "https://github.com/hectr/swift-regex.git", from: "1.1.0"),
        .package(url: "https://github.com/hectr/swift-stream-reader.git", from: "0.3.0"),
        .package(url: "https://github.com/hectr/swift-idioms.git", from: "1.8.0"),
    ],
    targets: [
        .target(
            name: "StringsFileLib",
            dependencies: ["RegexMatcher", "StreamReader", "Idioms"]),
        
        .testTarget(
            name: "StringsFileLibTests",
            dependencies: ["StringsFileLib"]),
        ]
)
