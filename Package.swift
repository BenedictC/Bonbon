// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
// import CompilerPluginSupport


let package = Package(
    name: "UICandy",
    platforms: [.iOS(.v16), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "UICandy",
            targets: ["UICandy"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [

        .target(
            name: "UICandy",
            dependencies: []
        ),

        .testTarget(
            name: "UICandyTests",
            dependencies: ["UICandy"]
        ),
    ]
)
