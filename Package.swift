// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Whiteboard",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "PerfectHTTPServer", url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
        .package(name: "PerfectMySQL", url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", from: "3.0.0"),
        .package(name: "PerfectLogger", url: "https://github.com/PerfectlySoft/Perfect-Logger.git", from: "3.0.0"),
        .package(name: "Kanna", url: "https://github.com/tid-kijyun/Kanna.git", from: "5.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Whiteboard",
            dependencies: ["PerfectHTTPServer", "PerfectMySQL", "PerfectLogger", "Kanna"]),
        .testTarget(
            name: "WhiteboardTests",
            dependencies: ["Whiteboard"]),
    ])
