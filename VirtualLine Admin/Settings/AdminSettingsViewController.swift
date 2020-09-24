//
//  AdminSettingsViewController.swift
//  VirtualLine Admin
//
//  Created by Niklas Wagner on 31.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreData

import Firebase

private let reuseIdentifier = "SettingsCell"

class AdminSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties

    var tableView: UITableView!
    var userInfoHeader: AdminInfoHeader!
    var isLoggedIn = false


    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        checkUserLoggedIn()
        configureUI()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
    }

    // MARK: - Helper Functions

    
    func checkUserLoggedIn() {
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        }
    }
    
    func configureTableView() {
        tableView = UITableView()
       // let color = UIColor(displayP3Red: 6 / 255, green: 14 / 255, blue: 79 / 255, alpha: 1)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60

        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame

        if isLoggedIn {
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = AdminInfoHeader(frame: frame)
        tableView.tableHeaderView = userInfoHeader
        }
        tableView.tableFooterView = UIView()
    }

    func configureUI() {
        configureTableView()

        parent?.title = "User"
    }

    // MARK: TableView:

    func numberOfSections(in tableView: UITableView) -> Int {
           return SettingsSection.allCases.count
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           guard let section = SettingsSection(rawValue: section) else { return 0 }
           switch section {
           case .profile:
               if isLoggedIn {
               return LoggedInProfileOptions.allCases.count
               } else {
               return LoggedOutProfileOptions.allCases.count
               }
           case .settings:
               return SettingsOptions.allCases.count
           case .aboutUs:
               return AboutUsOptions.allCases.count
           }
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell

           guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
           switch section {
               
           case .profile:
               if isLoggedIn {
               let profile = LoggedInProfileOptions.init(rawValue: indexPath.row)
               cell.sectionType = profile
               } else {
                   let profile = LoggedOutProfileOptions.init(rawValue: indexPath.row)
                   cell.sectionType = profile
               }
               
           case .settings:

               let setting = SettingsOptions.init(rawValue: indexPath.row)
               cell.sectionType = setting
           case .aboutUs:
               
               let aboutUs = AboutUsOptions.init(rawValue: indexPath.row)
                 cell.sectionType = aboutUs
           }
           
           

           return cell
       }

       func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let view = UIView()

           let title = UILabel()
           title.font = UIFont.boldSystemFont(ofSize: 24)
           title.textColor = .black
           view.addSubview(title)
           title.translatesAutoresizingMaskIntoConstraints = false
           title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
           title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true

           title.text = SettingsSection(rawValue: section)?.description

           return view
       }

       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 40
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           guard let section = SettingsSection(rawValue: indexPath.section) else { return}
           
           
           switch section {
               
           case .profile:
               
              
               if isLoggedIn {
                if indexPath.row == 1 {
                   CredentialsController.shared.updateLogInStatus(loggedIn: false)
                   configureUI()
                   logOutPhoneNumber()
                   
                   }
                   
               } else {
                    
                  performSegue(withIdentifier: Segues.phoneLoginSegue, sender: nil)
                   
                   
               }
               
           case .settings:

               print(SettingsOptions.init(rawValue: indexPath.row)?.description)
              
           case .aboutUs:
               
               print(AboutUsOptions.init(rawValue: indexPath.row)?.description)
                 
           }
       }
       
       func logOutPhoneNumber() {
           
           let firebaseAuth = Auth.auth()
           
           do {
               try firebaseAuth.signOut()
            print("succesfully logged out")
            isLoggedIn = false
            CredentialsController.shared.admin = nil
            CredentialsController.shared.companyName = ""
            CredentialsController.shared.companyPhoneNumber = "no number saved"
            UserDefaultsConfig.companyName = ""
            UserDefaultsConfig.companyPhoneNumber = ""
            tableView.reloadData()
            viewWillAppear(false)
           } catch let signOutError as NSError {
               print("Sign out error: \(signOutError)")
           }
           
       }
       
       
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              if segue.identifier == Segues.phoneLoginSegue {
                    let vc = segue.destination as! PhoneLoginViewController
                    let phoneLoginVC = vc.self
              }
            }
       
       
}


