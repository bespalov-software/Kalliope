// swift-tools-version: 6.2
// Package.swift configured to use xcframework
//
// This uses an xcframework containing frameworks for iOS (arm64) and macOS
// (arm64 + x86_64 universal)

import PackageDescription

let package = Package(
    name: "Kalliope",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1),
        .macCatalyst(.v15),
    ],
    products: [
        .library(
            name: "Kalliope",
            targets: ["Kalliope"]
        ),
        .library(
            name: "Linus",
            targets: ["Linus"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.1.0"
        ),
    ],
    targets: [
        .target(
            name: "Kalliope",
            dependencies: ["CKalliope", "CKalliopeBridge"]
        ),
        .testTarget(
            name: "KalliopeTests",
            dependencies: ["Kalliope"]
        ),
        .binaryTarget(
            name: "CKalliope",
            path: "./Sources/CKalliope/extra/CKalliope.xcframework"
        ),
        .target(
            name: "CKalliopeBridge",
            dependencies: ["CKalliope"],
            path: "Sources/CKalliopeBridge",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("."),
            ]
        ),
        .binaryTarget(
            name: "CLinus",
            path: "./Sources/CLinus/extra/CLinus.xcframework"
        ),
        .target(
            name: "CLinusBridge",
            dependencies: ["CLinus", "CKalliope"],
            path: "Sources/CLinusBridge",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("."),
                // Common headers location - headers are copied here during
                // xcframework build
                // This avoids platform-specific paths since headers are
                // identical across platforms
                .headerSearchPath("../CLinus/extra/headers"),
                .headerSearchPath("../CKalliope/extra/headers"),
            ]
        ),
        .target(
            name: "Linus",
            dependencies: ["CLinus", "CKalliope", "CLinusBridge", "Kalliope"]
        ),
        .testTarget(
            name: "LinusTests",
            dependencies: ["Linus", "CLinus", "CKalliope", "CKalliopeBridge"]
        ),
    ]
)
