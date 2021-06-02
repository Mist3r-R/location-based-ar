//
//  UserDefault.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 01.06.2021.
//

import Foundation

@propertyWrapper
public struct UserDefault<T> {
    public let key: String
    public let defaultValue: T

    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            print("\(#file) -- setting \(newValue) for \(key)")
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct OptionalUserDefault<T> {
    public let key: String
    public let defaultValue: T?

    public init(_ key: String, defaultValue: T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}

@propertyWrapper
public struct OptionalCodableUserDefault<T: Codable> {
    public let key: String
    public let defaultValue: T?

    public init(_ key: String, defaultValue: T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T? {
        get {
            return try? UserDefaults.standard.getObject(forKey: key, castTo: T?.self) ?? defaultValue
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                try? UserDefaults.standard.setObject(new: newValue, forKey: key)
            }
        }
    }
}

@propertyWrapper
public struct ArrayUserDefault<T> {
    public let key: String
    public let defaultValue: [T]

    public init(_ key: String, defaultValue: [T] = []) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: [T] {
        get {
            return UserDefaults.standard.array(forKey: key) as? [T] ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
