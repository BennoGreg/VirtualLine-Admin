//
//  SettingsCell.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 31.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import Firebase
import UIKit

class SettingsCell: UITableViewCell {
    // MARK: - Properties

    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
            textLabel?.textColor = .lightGray
            textLabel?.font = UIFont(name: "Futura", size: 25)
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }

    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()

        if UserDefaultsConfig.notifcationsEnabled {
            switchControl.isOn = true
        } else {
            switchControl.isOn = false
        }
        switchControl.onTintColor = UIColor(named: "virtualLineColor")
        // switchControl.onTintColor = UIColor(displayP3Red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return switchControl
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = switchControl
        if let view = accessoryView {
            addSubview(view)
        }
        
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selectors

    @objc func handleSwitchAction(sender: UISwitch) {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        //   if let tokenData = Messaging.messaging().apnsToken {
        var token = ""
        InstanceID.instanceID().instanceID { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let result = result {
                token = result.token
                print(token)
                if sender.isOn {
                    UserDefaultsConfig.notifcationsEnabled = true
                    if let adminID = user?.uid {
                        db.collection("admin").document(adminID).updateData(["deviceToken": token, "pushEnabled": true])
                    }
                    print("Turned on")
                } else {
                    UserDefaultsConfig.notifcationsEnabled = false
                    if let adminID = user?.uid {
                        db.collection("admin").document(adminID).updateData(["deviceToken": "", "pushEnabled": false])
                    }
                    print("Turned off")
                }
            }
        }
    }
}
