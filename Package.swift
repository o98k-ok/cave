// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "cave",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "cave",
            path: ".",
            exclude: ["Info.plist", "Cave.entitlements", "Resources", "build.sh", "build"]
        )
    ]
)
