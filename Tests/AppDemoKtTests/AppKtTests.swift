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
        try await gradle(actions: ["assembleDebug"])

        // Verbose/Debug/Info/Warn/Error/Fatal/Silent
        // be verbose with "app.demo:V" and silence everything else ("*:S")
        try await launchAndroidApp(appid: "app.demo/.MainActivity", log: ["app.demo:V", "app.demo.App:V", "*:S"], apk: "/opt/src/github/skiptools/skipapp.swiftpm/Packages/Skip/skipapp.swiftpm.output/AppDemoKtTests/skip-transpiler/AppDemo/.build/AppDemo/outputs/apk/debug/AppDemo-debug.apk")
    }

    private func launchAndroidApp(appid: String, log: [String] = [], apk: String) async throws {
        let env: [String: String] = [:]

        // adb install -r Packages/Skip/skipapp.swiftpm.output/AppDemoKtTests/skip-transpiler/AppDemo/.build/AppDemo/outputs/apk/debug/AppDemo-debug.apk
        let adbInstall = [
            "adb",
            "install",
            "-r",
            apk,
        ]

        for try await outputLine in Process.streamLines(command: adbInstall, environment: env, onExit: { result in
            guard case .terminated(0) = result.exitStatus else {
                // we failed, but did not expect an error
                throw ADBError(failureReason: "error installing APK: \(result)")
            }
        }) {
            print("ADB>", outputLine)
        }

        // adb shell am start -n app.demo/.MainActivity
        var adbStart = [
            "adb",
            "shell",
            "am",
            "start-activity",
            "-S", // force stop the target app before starting the activity
            "-W", // wait for launch to complete
            "-n", appid,
        ]

        for try await outputLine in Process.streamLines(command: adbStart, environment: env, onExit: { result in
            guard case .terminated(0) = result.exitStatus else {
                throw ADBError(failureReason: "error launching APK: \(result)")
            }
        }) {
            print("ADB>", outputLine)
        }

        // GOOD:
        // ADB> Starting: Intent { cmp=app.demo/.MainActivity }

        // BAD:
        // ADB> Error: Activity not started, unable to resolve Intent { act=android.intent.action.VIEW dat= flg=0x10000000 }


        if !log.isEmpty {
            // adb shell am start -n app.demo/.MainActivity
            let logcat = [
                "adb",
                "logcat",
                // "-v", "time",
                // "-d", // dump then exit
            ]
            + log // e.g., ["*:W"] or ["app.demo*:E"],


            for try await outputLine in Process.streamLines(command: logcat, environment: env, onExit: { result in
                guard case .terminated(0) = result.exitStatus else {
                    throw ADBError(failureReason: "error watching log: \(result)")
                }
            }) {
                print("LOGCAT>", outputLine)
            }
        }
    }
}

struct ADBError : LocalizedError {
    var failureReason: String?
}

#endif
