// swift-tools-version: 5.8
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "App Demo",
    platforms: [
        .macOS("13"), .iOS("16"), .tvOS("16"), .watchOS("8"), .macCatalyst("16")
    ],
    products: [
        .iOSApplication(
            name: "Demo App",
            targets: ["DemoApp"],
            displayVersion: "1.0",
            bundleVersion: "1",
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/skiptools/skip.git", from: "0.0.0"),
        .package(url: "https://github.com/skiptools/skiphub.git", from: "0.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "DemoApp",
            dependencies: [
                "AppDemo",
                "AppDemoKt",
            ],
            resources: [
                .process("Resources")
            ],
            plugins: [
                .plugin(name: "preflight", package: "skip")
            ]
        ),

        .target(name: "AppDemo", dependencies: [
            ],
            plugins: [
                .plugin(name: "preflight", package: "skip")
            ]
        ),

        .testTarget(name: "AppDemoTests", dependencies: [
                .target(name: "AppDemo"),
            ],
            plugins: [
                .plugin(name: "preflight", package: "skip")
            ]
        ),

        .target(name: "AppDemoKt", dependencies: [
                .target(name: "AppDemo"),
                .product(name: "SkipUIKt", package: "skiphub"),
            ],
            resources: [.copy("Skip")],
            plugins: [
                .plugin(name: "transpile", package: "skip")
            ]
        ),

        .testTarget(name: "AppDemoKtTests", dependencies: [
                .target(name: "AppDemoKt"),
                .product(name: "SkipUnitKt", package: "skiphub"),
            ],
            plugins: [
                .plugin(name: "transpile", package: "skip")
            ]
        ),
    ]
)


// Note: this will only work in Xcode, not Playgrounds:
// x-xcode-log://325CBEE8-3498-47E5-9957-712303AB7A31 This Swift Playgrounds project depends on 2 targets containing non-Swift source code, and will therefore not be buildable in Swift Playgrounds.
// Target “CSystem” in package “swift-system”
// Target “TSCclibc” in package “swift-tools-support-core”

import class Foundation.ProcessInfo
// For Skip library development in peer directories, run: SKIPLOCAL=.. xed Package.swift
if let localPath = ProcessInfo.processInfo.environment["SKIPLOCAL"] {
    // locally linking SwiftSyntax requires explicit min platform targets
    package.dependencies[package.dependencies.count - 2] = .package(path: localPath + "/skip")
    package.dependencies[package.dependencies.count - 1] = .package(path: localPath + "/skiphub")
}

