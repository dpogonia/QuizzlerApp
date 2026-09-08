// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoreServices",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "CoreServices", targets: ["CoreServices"])
    ],
    targets: [
        .target(name: "CoreServices")
    ]
)
