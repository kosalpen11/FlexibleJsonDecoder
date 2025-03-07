//
//  File.swift
//  FlexibleJsonDecoder
//
//  Created by Kosal Pen on 6/3/25.
//

import Foundation

public protocol DefaultValueProvider {
    associatedtype ValueType
    static func defaultValue() -> ValueType
}

// ✅ Default Values for Non-Optional Types
extension Int: DefaultValueProvider {
    public static func defaultValue() -> Int { 0 }
}

extension String: DefaultValueProvider {
    public static func defaultValue() -> String { "" }
}

extension Bool: DefaultValueProvider {
    public static func defaultValue() -> Bool { false }
}

extension Double: DefaultValueProvider {
    public static func defaultValue() -> Double { 0.0 }
}

extension Array: DefaultValueProvider where Element: DefaultValueProvider {
    public static func defaultValue() -> [Element] { [] }
}

extension Dictionary: DefaultValueProvider where Key: Hashable, Value: DefaultValueProvider {
    public static func defaultValue() -> [Key: Value] { [:] }
}

// ✅ Default Value for Optionals
extension Optional: DefaultValueProvider where Wrapped: DefaultValueProvider {
    public static func defaultValue() -> Wrapped? { nil }
}

public protocol DefaultEnumProvider: RawRepresentable, Codable, DefaultValueProvider where ValueType == Self {
    static var defaultCase: Self { get }
}

extension DefaultEnumProvider {
    public static func defaultValue() -> Self {
        return defaultCase
    }
}

extension DefaultEnumProvider {
    /// ✅ Custom Decoding to Handle Invalid or Missing Values
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)

        if let rawValue, let value = Self(rawValue: rawValue as! Self.RawValue) {
            self = value
        } else {
            self = Self.defaultCase  // ✅ Fallback to default case on failure
        }
    }
}
