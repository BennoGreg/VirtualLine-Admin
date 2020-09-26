//
//  AddQueueViewController.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 30.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import Firebase
import UIKit

class AddQueueViewController: UIViewController {
    @IBOutlet var queueReminderTextfield: UITextField!
    @IBOutlet var queueAverageWaitingTimeTextfield: UITextField!
    @IBOutlet var queueNameTextField: UITextField!
    @IBOutlet var createQueueButton: UIButton!
    override func viewDidLoad() {
        setUpUI()
        queueReminderTextfield.keyboardType = .numberPad
        queueAverageWaitingTimeTextfield.keyboardType = .numberPad
        // ready for receiving notification
        hideKeyboardWhenTappedAround()
    }

    func setUpUI() {
        createQueueButton.applyDesign()
        createQueueButton.setTitle("Warteschlange erstellen", for: .normal)
    }

    @IBAction func createQueueButtonPressed(_ sender: UIButton) {
        
       
            if queueNameTextField.text != "" && queueAverageWaitingTimeTextfield.text != "" && queueReminderTextfield.text != "" {
                if let navController = navigationController {
                    if let name = queueNameTextField.text {
                        if let waitTime = queueAverageWaitingTimeTextfield.text {
                            if let reminder = queueReminderTextfield.text {
                                createQueue(queueName: name, averageTimeCustomer: waitTime, minutesBeforeNotifyingCustomer: reminder) {
                                    UserDefaultsConfig.isQueueCreated = true
                                    navController.popViewController(animated: true)
                                }
                               
                            }
                        }
                    }
                
            }
        }
    }
   
}
