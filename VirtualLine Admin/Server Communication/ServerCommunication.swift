//
//  ServerCommunication.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 01.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions

var db: Firestore!
var ref: DocumentReference?
var functions = Functions.functions(region: "europe-west1")
var token: String?

var dataDictionary = [String: Any]()


func setUpFirebase(){
    
    let settings = FirestoreSettings()

          Firestore.firestore().settings = settings
          // [END setup]
          db = Firestore.firestore()
    
    InstanceID.instanceID().instanceID { (result, error) in
        if let error = error{
            print(error.localizedDescription)
        }else if let result = result{
            token = result.token
            //print(result.token)
        }
        
    }

}

func createQueue(queueName: String, averageTimeCustomer: String, minutesBeforeNotifyingCustomer: String){
    
    
    guard let adminID = CredentialsController.shared.admin?.id else {return}
    let adminRef = db.document("admin/\(adminID)")
    print("called createQueue")
    
    ref = db.collection("queue").addDocument(data: [
        "adminRef": adminRef,
        "totalCustomersServed": 0,
                "currentCustomerID": 0,
               "name": queueName,
               "reminder": Int(minutesBeforeNotifyingCustomer),
               "timePerCustomer": Int(averageTimeCustomer),
               "userQueue" : [DocumentReference](),
                "queueCount": 0
           ]){error in
               if let error = error{
                   print("Error adding document: \(error)")
               }else{
                    UserDefaultsConfig.isQueueCreated = true
                   print("Document added with ID: \(ref!.documentID)")
                if let adminID = Auth.auth().currentUser?.uid, let docRef = ref{
                    db.collection("admin").document(adminID).updateData(["queueID": docRef]) { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }else {
                            print("Admin updated")
                        }
                    }
                }
                
               }
           }
    
    
           db.collection("queue").document(ref!.documentID).addSnapshotListener { (documentSnapshot, error) in
               guard let document = documentSnapshot else {
                   print("Error fetching document: \(error!)")
                   return
               }
               guard let data = document.data() else {
                   print("Document data was empty")
                   return
               }
               let referenceArray = data["userQueue"] as! [DocumentReference]
               var totalTime = data["timePerCustomer"] as! Int
               totalTime = totalTime * referenceArray.count

            if !referenceArray.isEmpty{
                let firstUser = referenceArray[0]
                getUser(ref: firstUser, totalTime: totalTime, count: referenceArray.count)
            }
            
           }
    
}


func getUser(ref: DocumentReference, totalTime: Int, count: Int){
    
    ref.getDocument { (document, error) in
        guard let document = document else{
            print(error?.localizedDescription)
            return
        }
        if let name = document.data()?["Name"] as? String {
            
          
            let newTotalTime = String(totalTime)
            let newLength = String(count)
            print("Total Time: \(totalTime); First Customer: \(name)")
            dataDictionary["name"] = name
            dataDictionary["waitingTime"] = totalTime
            dataDictionary["queueLength"] = count
            
            ViewController.updateQueue(waitingTime: newTotalTime, queueLength: newLength)
            
            
            print("Total Time: \(totalTime); First Customer: \(name)")
            print("Total in queue: \(count)")
        }else{
            getUser(ref: ref, totalTime: totalTime, count: count)
        }
    }
}




