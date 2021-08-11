// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name:"CustomViewPresenter",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "CustomViewPresenter",
            targets: ["CustomViewPresenter"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CustomViewPresenter",
            path: "CustomViewPresenter"
        )
    ])
