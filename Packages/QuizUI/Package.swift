// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QuizUI",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "QuizUI", targets: ["QuizUI"])
    ],
    targets: [
        .target(name: "QuizUI")
    ]
)
