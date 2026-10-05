// swift-tools-version: 6.0
//
//  Package.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 02.03.2026.
//

import PackageDescription

let package = Package( // квиз: API, кэш банков, сессия, настройки. зависит от CoreServices
    name: "QuizServices",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "QuizServices", targets: ["QuizServices"])
    ],
    dependencies: [
        .package(path: "../CoreServices") // соседняя папка, не GitHub
    ],
    targets: [
        .target(
            name: "QuizServices",
            dependencies: ["CoreServices"] // сеть/диск/парсер оттуда
        )
    ]
)
