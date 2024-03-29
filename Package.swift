// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Whiteboard",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(name: "Kanna", url: "https://github.com/tid-kijyun/Kanna.git", from: "5.2.2"),
        .package(name: "ShellOut", url: "https://github.com/JohnSundell/ShellOut", from: "2.3.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [.product(name: "Vapor", package: "vapor"), "Kanna", "ShellOut"],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
