//
//  SCUHueTests.swift
//  SwiftColorUtils
//
//  Created by Iaroslav Omelianenko on 4/25/16.
//  Copyright © 2016 nologin. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published
//  by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/lgpl.html>.
//
import XCTest
@testable import SwiftColorUtils

/**
 The test cases to test SCUHue implementation
 */
class SCUHueTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFind() {
        // register test hue
        let name = "TestColor"
        let hue = 135 / 360.0
        NamedHues.instance.registerHue(name, hue: hue, primary: false)
        
        // test find closets primary
        if let closest = NamedHues.instance.find(130 / 360.0, primaryOnly: true) {
            XCTAssertEqual(closest, NamedHues.Standard.Green.hue, "Expected Green Hue")
        } else {
            XCTFail("Failed to find nearest primary Hue")
        }
        
        // test find closest registered
        if let closest = NamedHues.instance.find(130 / 360.0, primaryOnly: false) {
            XCTAssertTrue(closest.hue == hue, "Wrong hue value found: \(closest.hue), expected: \(hue)")
            XCTAssertEqual(closest.name, name, "Wrong registered hue name found: \(closest.name), expected: \(name)")
            XCTAssertFalse(closest.primary, "Non primary hue expected")
        } else {
            XCTFail("Failed to find nearest registered Hue")
        }
    }
    
    func testRegisterNamedHue() {
        let name = "TestColor"
        let hue = 140 / 360.0
        NamedHues.instance.registerHue(name, hue: hue, primary: false)
        if let registered = NamedHues.instance.hueForName(name) {
            // check that it's what we are expecting
            XCTAssertTrue(registered.hue == hue, "Wrong hue value found: \(registered.hue), expected: \(hue)")
            XCTAssertEqual(registered.name, name, "Wrong registered hue name found: \(registered.name), expected: \(name)")
            XCTAssertFalse(registered.primary, "Non primary hue expected")
        } else {
            XCTFail("Failed to find registered Hue")
        }
        
    }
    
    func testIsPrimary() {
        var hue = 120 / 360.0 + 2 * NamedHues.PRIMARY_VARIANCE
        var result = NamedHues.instance.isPrimary(hue, variance: NamedHues.PRIMARY_VARIANCE * 1.5)
        XCTAssertFalse(result, "Expected 'non primary' response value within provided primary variance")
        result = NamedHues.instance.isPrimary(hue)
        XCTAssertFalse(result, "Expected 'non primary' response value within default primary variance")
        
        hue = 120 / 360.0 + NamedHues.PRIMARY_VARIANCE * 0.5
        result = NamedHues.instance.isPrimary(hue, variance: NamedHues.PRIMARY_VARIANCE * 0.75)
        XCTAssertTrue(result, "Expected 'primary' response value within provided primary variance")
        result = NamedHues.instance.isPrimary(hue)
        XCTAssertTrue(result, "Expected 'primary' response value within default primary variance")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
