// swift-tools-version: 6.0
//
//  Package.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 10.02.2026.
//

import PackageDescription

let package = Package(
    name: "CoreServices",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "CoreServices", targets: ["CoreServices"])
    ],
    targets: [
        .target(name: "CoreServices")
    ]
)
