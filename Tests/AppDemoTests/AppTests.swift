// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import SwiftUI
import XCTest
@testable import AppDemo

class AppTests : XCTestCase {
    func testSimpleTest() {
        XCTAssertEqual(1, 1)
        //XCTAssertEqual(1, 2)
    }

    func testDataModel() {
        let e1 = Entry()
        let e2 = Entry()
        XCTAssertNotEqual(e1.id, e2.id, "new entities should have distinct identities")
        XCTAssertNotEqual(e1, e2, "entity equality should incorporate id")
    }
}
