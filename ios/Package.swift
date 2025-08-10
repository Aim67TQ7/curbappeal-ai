// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CurbAppealAI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CurbAppealAI",
            targets: ["CurbAppealAI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "CurbAppealAI",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .testTarget(
            name: "CurbAppealAITests",
            dependencies: ["CurbAppealAI"]),
    ]
)