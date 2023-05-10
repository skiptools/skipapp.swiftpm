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
        try await gradle(actions: ["test", "assembleDebug"])
    }
}
#endif
