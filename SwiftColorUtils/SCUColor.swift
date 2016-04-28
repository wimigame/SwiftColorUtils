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
    func toCMYK() -> CMYK {
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
    func toHSV() -> HSV {
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
    func toRGB() -> RGB {
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
    func toRGB() -> RGB {
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
extension UInt32 {
    /**
     Extracts `RGB` and alpha from compacted ARGB 32 unsigned integer
     */
    func toRGBA() -> (RGB, alpha: Double) {
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
extension String {
    /**
     Extracts `RGB` from hex string in format RRGGBB
     - Returns: `RGB` holder with extracted values or `nil`
     */
    func toRGB() -> RGB? {
        if self.characters.count < 6 {
            return nil
        }
        let str = self.clipFromEnd(6)
        if let value = UInt32(str, radix: 16) {
            let (rgb, _) = value.toRGBA()
            return rgb
        } else {
            return nil
        }
    }
    /**
     Extracts `RGB` and alpha from hex string in format AARRGGBB
     - Returns: tuple with `RGB` and alpha values or `nil`
     */
    func toRGBA() -> (RGB, alpha: Double)? {
        if self.characters.count < 8 {
            return nil
        }
        let str = self.clipFromEnd(8)
        if let value = UInt32(str, radix: 16) {
            return value.toRGBA()
        } else {
            return nil
        }
    }
    /**
     Clips this strip from end to limit characters count within specified range
     - Parameter limit the maximal number of characters to be in string after clipping
     - Returns: clipped by specified length string
     */
    private func clipFromEnd(limit: Int) -> String {
        if self.characters.count > limit {
            let index = self.endIndex.advancedBy(-limit)
            return self.substringFromIndex(index)
        }
        return self
    }
}

// MARK: SCUColor implementation start
/**
 The `RGB` extension providing color check facilities
 */
extension RGB {
    /**
     Maximum rgb component value for a color to be classified as black.
     */
    static let blackPoint = 0.08
    
    /**
     Minimum rgb component value for a color to be classified as white.
     */
    static let whitePoint = 1.0
    /**
     Method to check whether this RGB holder holds color which can be considered black
     - Returns: true if this holder holds color close enough to black to be considered the one
     */
    func isBlack() -> Bool {
        return self.R <= RGB.blackPoint && self.R == self.G && self.R == self.B
    }
    /**
     Method to check whether this RGB holder holds color which can be considered white
     - Returns: true if this holder holds color close enough to white to be considered the one
     */
    func isWhite() -> Bool {
        return self.R >= RGB.whitePoint && self.R == self.G && self.R == self.B
    }
}
/**
 The `HSV` extension providing color check facilities
 */
extension HSV {
    /**
     Maximum saturations value for a color to be classified as grey
     */
    static let greyThreshold = 0.01
    
    /**
     Method to check whether color described by this holder may be considered as grey
     - Returns: true if color described by this holder may be considered as grey
     */
    func isGrey() -> Bool {
        return self.S < HSV.greyThreshold
    }
    
    /**
     Method to check whether color described by this holder may be considered as primary one 
     - Returns: true if color described by this holder may be considered as primary one
     */
    func isPrimary() -> Bool {
        return NamedHues.instance.isPrimary(self.H)
    }
}

/**
 The color implementation based on floating point values for color's components
 */
public struct SCUColor {
    public var rgb : RGB
    public var hsv : HSV
    public var cmyk : CMYK
    public var alpha : Double
}
/**
 Extension with common color constructors
 */
extension SCUColor {
    /**
     Creates new instance from provided compacted color value
     - Parameters:
     - argb the compacted color value
     */
    public init(argb: UInt32) {
        let (rgb, a) = argb.toRGBA()
        self.init(rgb : rgb, alpha : a)
    }
    
    /**
     Creates new instance from provided hex encoded String
     - Parameters:
     - argb the compacted color value
     */
    public init?(argb: String) {
        if argb.characters.count < 8 {
            if let rgb = argb.toRGB() {
                self = SCUColor(rgb : rgb, alpha : 1.0)
            } else {
                // return nil, discarding self is implied
                return nil
            }
        } else {
            if let (rgb, alpha) = argb.toRGBA() {
                self = SCUColor(rgb: rgb, alpha: alpha)
            } else {
                // return nil, discarding self is implied
                return nil
            }
        }
    }
    
    /**
     Creates new instance
     - Parameters:
     - rgb the `RGB` components holder
     - alpha the alpha component
     */
    public init(rgb : RGB, alpha : Double) {
        self.rgb = rgb
        self.alpha = alpha
        self.hsv = rgb.toHSV()
        self.cmyk = rgb.toCMYK()
    }
    
    /**
     Creates new instance
     - Parameters:
     - cmyk the `CMYK` components holder
     - alpha the alpha component
     */
    public init(cmyk : CMYK, alpha : Double) {
        self.cmyk = cmyk
        self.alpha = alpha
        self.rgb = cmyk.toRGB()
        self.hsv = self.rgb.toHSV()
    }
    
    /**
     Creates new instance
     - Parameters:
     - hsv the `HSV` components holder
     - alpha the alpha component
     */
    public init(hsv : HSV, alpha : Double) {
        self.hsv = hsv
        self.rgb = hsv.toRGB()
        self.cmyk = self.rgb.toCMYK()
        self.alpha = alpha
    }
}

/**
 The extension providing method to quick check major color properties
 */
extension SCUColor {
    /**
     Method to check whether this color can be considered black
     - Returns: true if this color close enough to black to be considered the one
     */
    public func isBlack() -> Bool {
        return self.rgb.isBlack()
    }
    /**
     Method to check whether this color can be considered white
     - Returns: true if this color close enough to white to be considered the one
     */
    public func isWhite() -> Bool {
        return self.rgb.isWhite()
    }
    /**
     Method to check whether this color may be considered as grey
     - Returns: true if this color may be considered as grey
     */
    public func isGrey() -> Bool {
        return self.hsv.isGrey()
    }
    /**
     Method to check whether this color may be considered as primary one
     - Returns: true if this color may be considered as primary one
     */
    public func isPrimary() -> Bool {
        return self.hsv.isPrimary()
    }
    /**
     Method to get color luminance assuming sRGB Primaries as per http://en.wikipedia.org/wiki/Luminance_(relative).
     - Returns: color luminance
     */
    public func luminance() -> Double{
        return self.rgb.R * 0.2126 + self.rgb.G * 0.7152 + self.rgb.B * 0.0722
    }
}
/**
 Extension with common color manipulation methods 
 */
extension SCUColor {
    /**
     Method to get darken by specified amount version of this color
     - Parameter step the step (0.1 -> 10%)
     - Returns: darken version of this color
     */
    public func darken(step : Double) -> SCUColor {
        let brightness = self.hsv.V - step.clipColor()
        let newHSV = HSV(h: self.hsv.H, s: self.hsv.S, v: brightness)
        return SCUColor(hsv: newHSV, alpha: self.alpha)
    }
}