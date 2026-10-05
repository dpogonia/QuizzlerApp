// swift-tools-version: 6.0
//
//  Package.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 10.02.2026.
//

import PackageDescription

let package = Package( // сеть, диск, JSON, локатор. никого не зависит
    name: "CoreServices",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "CoreServices", targets: ["CoreServices"]) // то, что линкует приложение и QuizServices
    ],
    targets: [
        .target(name: "CoreServices") // исходники в Sources/CoreServices
    ]
)
