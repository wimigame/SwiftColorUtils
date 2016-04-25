//
//  HUE.swift
//  SwiftColorUtils
//
//  Created by Iaroslav Omelianenko on 4/20/16.
//  Copyright © 2016 nologin. All rights reserved.
//

import Foundation

/**
 This class defines color hue associated with specific name.
 */
public struct NamedHue : CustomStringConvertible {
    // The name associated with this hue
    public let name: String
    // The actual value
    public let hue: Double
    // The flag to indicate whether it is primary hue
    public let primary: Bool
    
    // MARK: CustomStringConvertible
    public var description: String {
        get {
            return "NamedHue, name: \(self.name), at \(self.hue * 360.0) degrees"
        }
    }
}

// MARK: Equatable implementation
extension NamedHue : Equatable {}
public func ==(lhs: NamedHue, rhs: NamedHue) -> Bool {
    let areEqual = (lhs.name == rhs.name &&
                    lhs.hue == lhs.hue &&
                    lhs.primary == lhs.primary)
    return areEqual
}

/**
 The registry of named hues holding `NamedHue` instances for some standard colors and
 providing method to check whether hue value is one of seven primary colors (rainbow)
 or is within specific variance value to it.
 */
public class NamedHues {
    // The singleton instance
    static let instance = NamedHues()
    // The tolerance to check for primary hue value
    public static let PRIMARY_VARIANCE = 0.01
    /**
     The enumeration of hues' names for standard colors
     */
    public enum Standard: String {
        case Red = "red"
        case Orange = "orange"
        case Yellow = "yellow"
        case Lime = "lime"
        case Green = "green"
        case Teal = "teal"
        case Cyan = "cyan"
        case Azure = "azure"
        case Blue = "blue"
        case Indigo = "indigo"
        case Purple = "purple"
        case Pink = "pink"
        
        var hue: NamedHue {
            get {
                switch self {
                case .Red:
                    return NamedHue(name: self.rawValue, hue: 0, primary: true)
                case .Orange:
                    return NamedHue(name: self.rawValue, hue: 30 / 360.0, primary: true)
                case .Yellow:
                    return NamedHue(name: self.rawValue, hue: 60 / 360.0, primary: true)
                case .Lime:
                    return NamedHue(name: self.rawValue, hue: 90 / 360.0, primary: false)
                case .Green:
                    return NamedHue(name: self.rawValue, hue: 120 / 360.0, primary: true)
                case .Teal:
                    return NamedHue(name: self.rawValue, hue: 150 / 360.0, primary: false)
                case .Cyan:
                    return NamedHue(name: self.rawValue, hue: 180 / 360.0, primary: false)
                case .Azure:
                    return NamedHue(name: self.rawValue, hue: 210 / 360.0, primary: false)
                case .Blue:
                    return NamedHue(name: self.rawValue, hue: 240 / 360.0, primary: true)
                case .Indigo:
                    return NamedHue(name: self.rawValue, hue: 270 / 360.0, primary: false)
                case .Purple:
                    return NamedHue(name: self.rawValue, hue: 300 / 360.0, primary: true)
                case .Pink:
                    return NamedHue(name: self.rawValue, hue: 330 / 360.0, primary: true)
                }
            }
        }
        
        var name: String {
            return self.rawValue
        }
    }
    
    // The dictionary of registered named hues
    private var namedHues = [String: NamedHue]()
    // The array of known primary hues
    private var primaryHues = [NamedHue]()
    
    /**
     Initialize with particular hues
    */
    private init() {
        self.registerHue(Standard.Red.hue)
        self.registerHue(Standard.Orange.hue)
        self.registerHue(Standard.Yellow.hue)
        self.registerHue(Standard.Lime.hue)
        self.registerHue(Standard.Green.hue)
        self.registerHue(Standard.Teal.hue)
        self.registerHue(Standard.Cyan.hue)
        self.registerHue(Standard.Azure.hue)
        self.registerHue(Standard.Blue.hue)
        self.registerHue(Standard.Indigo.hue)
        self.registerHue(Standard.Purple.hue)
        self.registerHue(Standard.Pink.hue)
    }
    
    /**
     Register specified `NamedHue`
     - Parameter namedHue the `NamedHue` to be registered
    */
    public func registerHue(namedHue: NamedHue) {
        if namedHue.primary && !self.primaryHues.contains(namedHue) {
            // store into primary dictionary
            self.primaryHues.append(namedHue)
        }
        // add to the dictionary of known
        self.namedHues[namedHue.name] = namedHue
    }
    
    /**
     Register specific hue value under specified name
     - Parameters:
        - name the name of this hue
        - hue the value associated
        - primary the flag to indicate whether it is primary hue (true)
    */
    public func registerHue(name: String, hue: Double, primary: Bool) {
        let nHue = NamedHue(name: name, hue: hue, primary: primary)
        
        self.registerHue(nHue)
    }
    
    /**
     Returns `NamedHue` registered under given name if any
     - Parameter name the name of Hue to look
     - Returns: `NamedHue` if found
    */
    public func hueForName(name: String) -> NamedHue? {
        return self.namedHues[name]
    }
    
    /**
     Finds nearest `NamedHue` to the provided hue value
     - Parameters:
        - hue the hue value to check against
        - primaryOnly if set to true than search will be only through primary hues
     */
    public func find(hue: Double, primaryOnly: Bool) -> NamedHue? {
        let hueVal = hue % 1
        var dist = Double.infinity
        var closest: NamedHue?
        
        // the function to find closest
        func findClosest(value: NamedHue) -> NamedHue {
            let d = fmin(Double.abs(value.hue - hueVal), Double.abs(1 + value.hue - hueVal))
            if d < dist {
                dist = d
                closest = value
            }
            return value
        }
        if primaryOnly {
            for namedHue in self.primaryHues {
                findClosest(namedHue)
            }
        } else {
            for (_, namedHue) in self.namedHues {
                findClosest(namedHue)
            }
        }
        return closest
    }
    
    /**
     Allow to check whether provided value is within `variance` tolerance from one of registered primary hues.
     - Parameters:
        - hue the hue value to check against
        - variance the allowed tolerance to check against
     - Returns: `true` if provided hue value is within `variance` tolerance from one of registered primary hues.
    */
    public func isPrimary(hue: Double, variance: Double) -> Bool {
        if let closest = find(hue, primaryOnly: true) {
            return Double.abs(closest.hue - hue) < variance
        } else {
            return false
        }
    }
    
    /**
     Allow to check whether provided value is within default tolerance range from one of registered primary hues.
     - Parameters:
     - hue the hue value to check against
     - Returns: `true` if provided hue value is within default tolerance range from one of registered primary hues.
     */
    public func isPrimary(hue: Double) -> Bool {
        return self.isPrimary(hue, variance: NamedHues.PRIMARY_VARIANCE)
    }
}
