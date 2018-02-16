// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "StringsFileLib",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "StringsFileLib",
            targets: ["StringsFileLib"]),
        ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/hectr/swift-regex.git", from: "1.0.0"),
        .package(url: "https://github.com/hectr/swift-stream-reader.git", from: "0.1.0"),
        .package(url: "https://github.com/hectr/swift-idioms.git", from: "0.1.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "StringsFileLib",
            dependencies: ["RegexMatcher", "StreamReader", "Idioms"]),
        
        .testTarget(
            name: "StringsFileLibTests",
            dependencies: ["StringsFileLib"]),
        ]
)
