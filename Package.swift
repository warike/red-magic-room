// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "RedMagicRoom",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "RedMagicRoom", targets: ["RedMagicRoom"])
    ],
    targets: [
        .executableTarget(
            name: "RedMagicRoom",
            path: "RedMagicRoom",
            exclude: ["Info.plist", "RedMagicRoom.entitlements", "Assets.xcassets"]
        )
    ]
)
