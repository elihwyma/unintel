// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "unintel",
    platforms: [
       .macOS(.v11)
    ],
    dependencies: [
        
    ],
    targets: [
        .executableTarget(
            name: "unintel",
            dependencies: [
                
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
