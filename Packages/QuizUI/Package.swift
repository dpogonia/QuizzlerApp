// swift-tools-version: 6.0
//
//  Package.swift
//  QuizUI
//
//  Created by Dmitrii Pogonia on 18.04.2026.
//

import PackageDescription

let package = Package( // локальный пакет: iOS 17, одна библиотека, без зависимостей
    name: "QuizUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "QuizUI", targets: ["QuizUI"]) // приложение делает import QuizUI
    ],
    targets: [
        .target(name: "QuizUI")
    ]
)
