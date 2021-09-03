// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name:"CustomViewPresenter",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "CustomViewPresenter",
            targets: ["CustomViewPresenter"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/Vignesh-Thangamariappan/DeviceUtility",
            from: "0.1.0"
        )
    ],
    targets: [
        .target(
            name: "CustomViewPresenter",
            dependencies: ["DeviceUtility"],
            path: "CustomViewPresenter"
        )
    ])
