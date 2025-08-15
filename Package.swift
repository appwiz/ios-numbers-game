// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "NumbersGame",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "NumbersGame", targets: ["NumbersGame"])
    ],
    targets: [
        .target(
            name: "NumbersGame",
            dependencies: []
        ),
        .testTarget(
            name: "NumbersGameTests",
            dependencies: ["NumbersGame"]
        )
    ]
)