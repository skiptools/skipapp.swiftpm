// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import SkipUnit

#if os(Android) || os(macOS) || os(Linux) || targetEnvironment(macCatalyst)

/// This test case will run the transpiled tests for the Skip module.
final class AppKtTests: XCTestCase, XCGradleHarness {
    /// This test case will run the transpiled tests defined in the Swift peer module.
    /// New tests should be added there, not here.
    public func testSkipModule() async throws {
        // run the tests, and also build the APK at:
        // Packages/Skip/skipapp.swiftpm.output/AppDemoKtTests/skip-transpiler/AppDemo/.build/AppDemo/outputs/apk/debug/AppDemo-debug.apk
        // Packages/Skip/skipapp.swiftpm.output/AppDemoKtTests/skip-transpiler/AppDemo/.build/AppDemo/outputs/apk/release/AppDemo-release-unsigned.apk

        //try await gradle(actions: ["test", "assembleDebug", "assembleRelease"])
        try await gradle(actions: ["assembleDebug"], moduleName: "AppDemoKtTests")

        // Verbose/Debug/Info/Warn/Error/Fatal/Silent
        // be verbose with "app.demo:V" and silence everything else ("*:S")
        // Uncaught stack traces go to "AndroidRuntime:V"
        try await launchAPK(appid: "app.demo/.MainActivity", log: ["app.demo:V", "app.demo.App:V", "AndroidRuntime:V", "*:E"], apk: "Packages/Skip/skipapp.swiftpm.output/AppDemoKtTests/skip-transpiler/AppDemo/.build/AppDemo/outputs/apk/debug/AppDemo-debug.apk")
    }
}

#endif
