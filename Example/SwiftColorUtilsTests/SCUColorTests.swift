//
//  SCUColorTests.swift
//  SwiftColorUtils
//
//  Created by Iaroslav Omelianenko on 4/26/16.
//  Copyright © 2016 nologin. All rights reserved.
//
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
 Tests to check SCUColor implementation
 */
class SCUColorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
     Tests for conversions between color SCHEMES
     */
    func testSchemeConversions() {
        let rgb = RGB(r: 0.5, g: 0.5, b: 0.5)
        let hsvFromRgb = rgb.toHSV()
        let cmykFromRgb = rgb.toCMYK()
        
        XCTAssertEqual(rgb, hsvFromRgb.toRGB(), "Converted HSV scheme expected to match source RGB scheme")
        XCTAssertEqual(rgb, cmykFromRgb.toRGB(), "Converted CMYK scheme expected to match source RGB scheme")
    }
    
    func testUint32Conversions() {
        let alpha = 128, r  = 120, g = 100, b = 50
        let compact = UInt32((alpha << 24) | (r << 16) | (g << 8) | b)
        
        let (rgb, a) = compact.toRGBA()
        let aExpected = Double(alpha) * INV8BIT
        XCTAssertEqual(a, aExpected, "Alpha expected \(aExpected), but found \(a)")
        let rExpected = Double(r) * INV8BIT
        XCTAssertEqual(rgb.R, rExpected, "Red expected \(rExpected), but found \(rgb.R)")
        let gExpected = Double(g) * INV8BIT
        XCTAssertEqual(rgb.G, gExpected, "Green expected \(gExpected), but found \(rgb.G)")
        let bExpected = Double(b) * INV8BIT
        XCTAssertEqual(rgb.B, bExpected, "Blue expected \(bExpected), but found \(rgb.B)")
        
    }
    
    func testHexStringConversions() {
        // test positive normal
        let expectedRGB = RGB(r: 80 * INV8BIT, g: 80 * INV8BIT, b: 80 * INV8BIT)
        if let rgb = "505050".toRGB() {
            XCTAssertEqual(rgb, expectedRGB, "Converted RGB failed to match expected one")
        } else {
            XCTFail("Failed to invoke String.toRGB()")
        }
        
        let expectedAlpha = 80 * INV8BIT
        if let (rgb, a) = "50505050".toRGBA() {
            XCTAssertEqual(rgb, expectedRGB, "Converted RGB failed to match expected one")
            XCTAssertEqual(a, expectedAlpha, "Converted Alpha failed to match expected one")
        } else {
            XCTFail("Failed to invoke String.toRGBA()")
        }
        
        // test positive oversize
        if let rgb = "60505050".toRGB() {
            XCTAssertEqual(rgb, expectedRGB, "Converted RGB failed to match expected one")
        } else {
            XCTFail("Failed to invoke String.toRGB()")
        }
        if let (rgb, a) = "6050505050".toRGBA() {
            XCTAssertEqual(rgb, expectedRGB, "Converted RGB failed to match expected one")
            XCTAssertEqual(a, expectedAlpha, "Converted Alpha failed to match expected one")
        } else {
            XCTFail("Failed to invoke String.toRGBA()")
        }
        
        // test negative
        XCTAssertNil("5050".toRGB())
        XCTAssertNil("505050".toRGBA())
    }
    
    func testIsBlack() {
        // test isBlack()
        XCTAssertTrue(SCUColor(rgb: RGB(r: 10 * INV8BIT, g: 10 * INV8BIT, b: 10 * INV8BIT), alpha: 1.0).isBlack())
        XCTAssertFalse(SCUColor(rgb: RGB(r: 30 * INV8BIT, g: 30 * INV8BIT, b: 30 * INV8BIT), alpha: 1.0).isBlack())
    }

    func testIsWhite() {
        XCTAssertTrue(SCUColor(rgb: RGB(r: 255 * INV8BIT, g: 255 * INV8BIT, b: 255 * INV8BIT), alpha: 1.0).isWhite())
        XCTAssertFalse(SCUColor(rgb: RGB(r: 250 * INV8BIT, g: 250 * INV8BIT, b: 250 * INV8BIT), alpha: 1.0).isWhite())
    }
    
    func testIsGray() {
        XCTAssertTrue(SCUColor(rgb: RGB(r: 30 * INV8BIT, g: 30 * INV8BIT, b: 30 * INV8BIT), alpha: 1.0).isGrey())
        XCTAssertFalse(SCUColor(rgb: RGB(r: 30 * INV8BIT, g: 230 * INV8BIT, b: 130 * INV8BIT), alpha: 1.0).isGrey())
    }
    
    func testIsPrimary() {
        let orange = NamedHues.Standard.Orange.hue
        XCTAssertTrue(SCUColor(hsv: HSV(h: orange.hue, s: 1.0, v: 1.0), alpha: 1.0).isPrimary())
        let teal = NamedHues.Standard.Teal.hue
        XCTAssertFalse(SCUColor(hsv: HSV(h: teal.hue, s: 1.0, v: 1.0), alpha: 1.0).isPrimary())
    }
}
