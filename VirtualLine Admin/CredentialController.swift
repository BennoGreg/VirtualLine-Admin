//
//  CredentialController.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 16.09.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import Foundation

class CredentialsController {
    
    
    var isLoggedIn = UserDefaultsConfig.isLoggedIn
    var admin: Admin?
    var companyName = UserDefaultsConfig.companyName
    var companyPhoneNumber = UserDefaultsConfig.companyPhoneNumber
    
    public func updateLogInStatus(loggedIn: Bool) {
        
        isLoggedIn = loggedIn
        UserDefaultsConfig.isLoggedIn = loggedIn
        
    }
    
    public func updateAdminInfo() {
        companyName = UserDefaultsConfig.companyName
        companyPhoneNumber = UserDefaultsConfig.companyPhoneNumber
    }
    
    public func getCompanyPhoneNumber() -> String {
        return companyPhoneNumber
    }
    
    public static let shared = CredentialsController()
    
    private init() {}
    
}
