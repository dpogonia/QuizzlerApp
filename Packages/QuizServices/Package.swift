// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QuizServices",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "QuizServices", targets: ["QuizServices"])
    ],
    dependencies: [
        .package(path: "../CoreServices")
    ],
    targets: [
        .target(
            name: "QuizServices",
            dependencies: ["CoreServices"]
        )
    ]
)
