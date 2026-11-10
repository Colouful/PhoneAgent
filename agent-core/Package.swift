// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PhoneAgentCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "PhoneAgentCore", targets: ["PhoneAgentCore"])],
    targets: [
        .target(name: "PhoneAgentCore"),
        .testTarget(name: "PhoneAgentCoreTests", dependencies: ["PhoneAgentCore"])
    ]
)
