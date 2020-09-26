//
//  CredentialController.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 16.09.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import Firebase

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
        
        if let adminID = Auth.auth().currentUser?.uid {
        
        db.collection("admin").document(adminID).updateData(["name": companyName])
            
        }
    }
    
    public func getCompanyPhoneNumber() -> String {
        return companyPhoneNumber
    }
    
    public static let shared = CredentialsController()
    
    private init() {}
    
}
