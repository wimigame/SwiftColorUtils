//
//  SCUColor.swift
//  SwiftColorUtils
//
//  Created by Iaroslav Omelianenko on 4/26/16.
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
import Foundation

// MARK: The numeric extensions
extension Double {
    /**
     Method to clip this value within provided range
     - Parameters:
     - min the bottom range value
     - max the top range value
     - Returns: clipped value within provided range
     */
    public func clip(min: Double, max: Double) -> Double {
        return self < min ? min : (self > max ? max : self)
    }
    
    /**
     Utility method to automatically clip this value withing color component's range
     - Returns: clipped value within color component's range (0 .. 1)
     */
    public func clipColor() -> Double {
        return self.clip(0, max: 1)
    }
}
// MARK: The color components holders
/**
 The holder for RGB (Red, Green, Blue) color's components
 */
public struct RGB {
    public let R : Double
    public let G : Double
    public let B : Double
    
    /**
     Creates new instance and clips provided values to be in color's component range (0 .. 1)
     */
    public init(r: Double, g: Double, b: Double) {
        self.R = r.clipColor()
        self.G = g.clipColor()
        self.B = b.clipColor()
    }
}
extension RGB : Equatable {}
public func ==(lhs: RGB, rhs: RGB) -> Bool {
    return (lhs.R == rhs.R && lhs.G == rhs.G && lhs.B == rhs.B)
}
/**
 The holder for HSV (Hue, Saturation, Brightness) color's components
 */
public struct HSV {
    public let H : Double
    public let S : Double
    public let V : Double
    
    /**
     Creates new instance and clips provided values to be in color's component range (0 .. 1)
     */
    public init(h: Double, s: Double, v: Double) {
        self.H = h.clipColor()
        self.S = s.clipColor()
        self.V = v.clipColor()
    }
}
extension HSV : Equatable {}
public func ==(lhs: HSV, rhs: HSV) -> Bool {
    return (lhs.H == rhs.H && lhs.S == rhs.S && lhs.V == rhs.V)
}
/**
 The holder for CMYK (Cyan, Magenta, Yellow, Black) color's components
 */
public struct CMYK {
    public let C : Double
    public let M : Double
    public let Y : Double
    public let K : Double
    
    /**
     Creates new instance and clips provided values to be in color's component range (0 .. 1)
     */
    public init(c: Double, m: Double, y: Double, k: Double) {
        self.C = c.clipColor()
        self.M = m.clipColor()
        self.Y = y.clipColor()
        self.K = k.clipColor()
    }
}
extension CMYK : Equatable {}
public func ==(lhs: CMYK, rhs: CMYK) -> Bool {
    return (lhs.C == rhs.C && lhs.M == rhs.M && lhs.Y == rhs.Y && lhs.K == rhs.K)
}

// MARK: The color conversion utilities
private let INV60DEGREES = 60.0 / 360.0
let INV8BIT = 1.0 / 255.0

/**
 The `RGB` extension providing conversion to other color schemes
 */
extension RGB {
    /**
     The utility function to convert RGB value to CMYK value
     - Returns: `CMYK` values holder
     */
    public func toCMYK() -> CMYK {
        var C = 1.0 - self.R
        var M = 1.0 - self.G
        var Y = 1.0 - self.B
        var K = fmin(fmin(C, M), Y)
        C = (C - K).clipColor()
        M = (M - K).clipColor()
        Y = (Y - K).clipColor()
        K = K.clipColor()
        
        return CMYK(c: C, m: M, y: Y, k: K)
    }
    /**
     The utility function to convert RGB value to HSV value
     - Returns: `HSV` values holder
     */
    public func toHSV() -> HSV {
        let v = fmax(fmax(self.R, self.G), self.B)
        let d = v - fmin(fmin(self.R, self.G), self.B)
        
        var h = 0.0, s = 0.0
        
        if (v != 0.0) {
            s = d / v;
        }
        if s != 0.0 {
            if self.R == v {
                h = (self.G - self.B) / d
            } else if self.G == v {
                h = 2 + (self.B - self.R) / d
            } else {
                h = 4 + (self.R - self.G) / d
            }
        }
        
        h *= INV60DEGREES;
        
        if (h < 0) {
            h += 1.0
        }
        
        return HSV(h: h, s: s, v: v)
    }
}
/**
 The `CMYK` extension providing conversion to `RGB` color scheme
 */
extension CMYK {
    /**
     The utility function to convert CMYK value to RGB value
     - Returns: `RGB` values holder
     */
    public func toRGB() -> RGB {
        let r = 1.0 - fmin(1.0, self.C + self.K)
        let g = 1.0 - fmin(1.0, self.M + self.K)
        let b = 1.0 - fmin(1.0, self.Y + self.K)
        return RGB(r: r, g: g, b: b)
    }
}
/**
 The `HSV` extension providing conversion to `RGB` color scheme
 */
extension HSV {
    /**
     The utility function to convert HSV value to RGB value
     - Returns: `RGB` values holder
     */
    public func toRGB() -> RGB {
        var r : Double, g : Double, b: Double
        if self.S == 0.0 {
            r = self.V
            g = self.V
            b = self.V
        } else {
            let h = self.H / INV60DEGREES
            let i = Int(h)
            let f = h - Double(i)
            let p = self.V * (1 - self.S)
            let q = self.V * (1 - self.S * f)
            let t = self.V * (1 - self.S * (1 - f))
            
            if i == 0 {
                r = self.V
                g = t
                b = p
            } else if (i == 1) {
                r = q
                g = self.V
                b = p
            } else if (i == 2) {
                r = p
                g = self.V
                b = t
            } else if (i == 3) {
                r = p
                g = q
                b = self.V
            } else if (i == 4) {
                r = t
                g = p
                b = self.V
            } else {
                r = self.V
                g = p
                b = q
            }
        }
        return RGB(r: r, g: g, b: b);
    }
}
/**
 The `UInt32` extension providing utilities to extract/compact `RGB` value
 */
public extension UInt32 {
    /**
     Extracts `RGB` and alpha from compacted ARGB 32 unsigned integer
     */
    public func toRGBA() -> (RGB, alpha: Double) {
        let r = Double((self >> 16) & 0xff) * INV8BIT
        let g = Double((self >> 8) & 0xff) * INV8BIT
        let b = Double(self & 0xff) * INV8BIT
        let alpha = Double(self >> 24) * INV8BIT
        return (RGB(r: r, g: g, b: b), alpha)
    }
}
/**
 The String extension providing utilities to extract RGB or ARGB components from hex string
 */
public extension String {
    /**
     Extracts `RGB` from hex string
     */
    public func toRGB() -> RGB? {
        if self.characters.count < 6 {
            return nil
        }
        var str = self
        if str.characters.count > 6 {
            let index = self.startIndex.advancedBy(6)
            str = self.substringToIndex(index)
        }
        if let value = UInt32(str, radix: 16) {
            let (rgb, _) = value.toRGBA()
            return rgb
        } else {
            return nil
        }
    }
    /**
     Extracts `RGB` and alpha from hex string
     */
//    public func toRGBA() -> (RGB, alpha: Double) {
//        
//    }
}

// MARK: SCUColor implementation start

/**
 The color implementation based on floating point values for color's components
 */
public struct SCUColor {
    public var rgb : RGB
    public var hsv : HSV
    public var cmyk : CMYK
    public var alpha : Double

}