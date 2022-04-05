// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AsyncBluetooth",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "AsyncBluetooth",
            targets: ["AsyncBluetooth"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AsyncBluetooth",
            dependencies: []),
        .testTarget(
            name: "AsyncBluetoothTests",
            dependencies: ["AsyncBluetooth"]),
    ]
)
