//
//  QueueData.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 01.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//


import Firebase
import FirebaseFirestoreSwift


struct Queue: Codable {
    
    let name: String?
    let currentCustomerID: Int?
    let queueCount: Int?
    let timePerCustomer: Int?
    let userQueue: [DocumentReference]?
   
}


struct User: Codable, Identifiable {
 
    @DocumentID var id: String?
    let name: String?
    let queueID: DocumentReference?
    let numberInQueue: Int?
}
