// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-rfc-5322-coder",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "RFC 5322 Coder",
            targets: ["RFC 5322 Coder"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main", traits: ["Coder", "Parser", "Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-coder.git", branch: "main", traits: ["Checkpoint", "Map", "Pair", "Predicate", "Repetition", "Skip", "Choice", "Either", "IteratorLeaves", "Carrier"]),
        .package(url: "https://github.com/swift-atoms/swift-cursor.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-either.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-parser.git", branch: "main", traits: ["Always", "Choice", "Either", "FlatMap", "IteratorLeaves", "Map", "Repetition", "Append", "Pair", "Predicate", "Product", "Skip", "Iterator"]),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main", traits: ["Either", "Map", "Pair", "Repetition"]),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5322.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-binary.git", branch: "main", traits: ["Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-pair.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RFC 5322 Coder",
            dependencies: [
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "RFC 5322", package: "swift-rfc-5322"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),
        .testTarget(
            name: "RFC 5322 Coder Tests",
            dependencies: [
                "RFC 5322 Coder",
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "RFC 5322", package: "swift-rfc-5322"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Binary", package: "swift-binary"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
