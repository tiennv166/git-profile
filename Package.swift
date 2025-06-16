// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "GitProfile",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "GitProfile",
            targets: ["GitProfile"]
        ),
        .library(
            name: "GitProfileServices",
            targets: ["GitProfileServices"]
        )
    ],
    dependencies: [
        // Networking
        .package(url: "https://github.com/ishkawa/APIKit", exact: "5.4.0"),
        
        // UI Utilities
        .package(url: "https://github.com/onevcat/Kingfisher", exact: "8.3.2"),
        .package(url: "https://github.com/CSolanaM/SkeletonUI", exact: "2.0.2"),
        .package(url: "https://github.com/Abedalkareem/LanguageManager-iOS.git", exact: "1.3.0")
    ],
    targets: [
        // Core services module
        .target(
            name: "GitProfileServices",
            dependencies: [
                "APIKit"
            ],
            path: "GitProfileServices",
            exclude: ["README.md"],
            resources: [.process("Resources")]
        ),
        
        // UI module
        .target(
            name: "GitProfile",
            dependencies: [
                "GitProfileServices",
                "Kingfisher",
                "SkeletonUI",
                "LanguageManager-iOS"
            ],
            path: "GitProfile",
            exclude: ["README.md"],
            resources: [.process("Resources")]
        ),
        
        // Unit tests for services
        .testTarget(
            name: "GitProfileServicesTests",
            dependencies: ["GitProfileServices"],
            path: "GitProfileServicesTests"
        ),
        
        // Unit tests for UI/view models
        .testTarget(
            name: "GitProfileTests",
            dependencies: ["GitProfile"],
            path: "GitProfileTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
