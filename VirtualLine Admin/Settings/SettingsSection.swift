//
//  SettingsSection.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 31.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import Foundation


protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool {get}
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible{
    
    case profile
    case settings
    case aboutUs
    
  
    var description: String {
        
        switch self {
        case .profile:
            return "Profil"
        case .settings:
            return "Einstellungen"
        case .aboutUs:
            return "Über uns"
        }
        
    }
    
    
}

enum LoggedInProfileOptions: Int, CaseIterable, CustomStringConvertible, SectionType{
    var containsSwitch: Bool {return false}
    
    
    case editProfile
    case logOut
    
    var description: String {
           
           switch self {
           case .editProfile:
               return "Profil bearbeiten"
           case .logOut:
               return "Ausloggen"
           }
           
       }
}

enum LoggedOutProfileOptions: Int, CaseIterable, CustomStringConvertible, SectionType{
    var containsSwitch: Bool {return false}
    
    
    case logIn
    
    var description: String {
           
           switch self {
           case .logIn:
               return "Einloggen"
           }
    }
}

enum SettingsOptions: Int, CaseIterable, SectionType{
  
   
    
    case notification
    case deleteQueue
    
    var containsSwitch: Bool {
        
        switch self {
        case .notification:
            return true
        case .deleteQueue:
            return false
        default:
            return false
        }
        
    }
    
    var description: String {
        
        switch self {
        case .notification:
            return "Benachrichtigngen"
        case .deleteQueue:
            return "Warteschlange löschen"
        }
        
    }
    
}

enum AboutUsOptions: Int, CaseIterable, CustomStringConvertible, SectionType{
    var containsSwitch: Bool {return false}
    
    
    case gtc
    case dataPrivacy
    
    var description: String {
           
           switch self {
           case .gtc:
               return "Allgemeine Geschäftsbedingungen"
           case .dataPrivacy:
               return "Datenschutz"
           }
           
       }
}

