// swift-tools-version: 6.0
//
//  Package.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 02.03.2026.
//

import PackageDescription

let package = Package(
    name: "QuizServices",
    platforms: [
        .iOS(.v17)
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
