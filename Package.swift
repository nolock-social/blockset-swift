// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BlockSet",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BlockSet",
            targets: ["BlockSet"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-html.git", from: "0.5.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BlockSet",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Html", package: "swift-html"),
            ]
        ),
        .testTarget(
            name: "BlockSetTests",
            dependencies: ["BlockSet"]
        ),
    ]
)
