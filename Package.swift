// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-rfc-5322-coder",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
    ],
    products: [
        .library(
            name: "RFC 5322 Coder",
            targets: ["RFC 5322 Coder"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cursor.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-either.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-parser.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-ascii-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-binary-serializer.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-cursor-parser.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-cursor-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-iterator-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5322.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RFC 5322 Coder",
            dependencies: [
                .product(name: "ASCII Decimal Coder", package: "swift-ascii-coder"),
                .product(name: "Binary Serializable", package: "swift-binary-serializer"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Cursor Standard Library Integration", package: "swift-cursor"),
                .product(name: "Cursor Coder", package: "swift-cursor-coder"),
                .product(name: "Cursor Parser Many", package: "swift-cursor-parser"),
                .product(name: "Cursor Parser Optionally", package: "swift-cursor-parser"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Iterator Coder", package: "swift-iterator-coder"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Error", package: "swift-parser"),
                .product(name: "RFC 5322", package: "swift-rfc-5322"),
                .product(name: "Serializer", package: "swift-serializer"),
            ]
        ),
        .testTarget(
            name: "RFC 5322 Coder Tests",
            dependencies: [
                "RFC 5322 Coder",
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Coder Standard Library Integration", package: "swift-coder"),
                .product(name: "Cursor Standard Library Integration", package: "swift-cursor"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "RFC 5322", package: "swift-rfc-5322"),
                .product(name: "Serializer", package: "swift-serializer"),
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
