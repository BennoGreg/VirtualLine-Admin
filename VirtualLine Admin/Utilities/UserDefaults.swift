//
//  UserDefaults.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 16.09.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefaultsWrapper<Value: Codable> {
    public let key: String
    public let defaultValue: Value
    public let userDefaults = UserDefaults.standard

    public var wrappedValue: Value {
        get {
            let data = userDefaults.data(forKey: key)
            let value = data.flatMap { try? JSONDecoder().decode(Value.self, from: $0) }
            return value ?? defaultValue
        }

        set {
            let data = try? JSONEncoder().encode(newValue)
            userDefaults.set(data, forKey: key)
        }
    }
}

public struct UserDefaultsConfig {
    @UserDefaultsWrapper(key: "isLoggedIn", defaultValue: false)
    public static var isLoggedIn: Bool
    
    @UserDefaultsWrapper(key: "verificationID", defaultValue: "defaultå")
    public static var verificationID: String
    
    @UserDefaultsWrapper(key: "notifcationsEnabled", defaultValue: false)
    public static var notifcationsEnabled: Bool
    
   
}
