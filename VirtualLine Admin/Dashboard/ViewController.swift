//
//  ViewController.swift
//  VirtualLine Admin
//
//  Created by Benedikt Langer on 04.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import UIKit

class ViewController: UIViewController {
    @IBOutlet var newQueueButton: UIButton!

    @IBOutlet var queueWaitingTimeLabel: UILabel!
    @IBOutlet var queueLengthLabel: UILabel!
    @IBOutlet var nextCustomerIDLabel: UILabel!
    @IBOutlet var nextCustomerNameLabel: UILabel!
    @IBOutlet var currenCustomerIDLabel: UILabel!
    @IBOutlet var currentCustomerLabel: UILabel!
    @IBOutlet var customerDoneButton: UIButton!
    @IBOutlet var isCustomerHereButtonStackView: UIStackView!
    @IBOutlet var currentCustomerView: UIView!
    @IBOutlet var customerNotAvailableButton: UIButton!
    @IBOutlet var acceptCustomerButton: UIButton!
    @IBOutlet var bigStackView: UIStackView!
    var waitingNumber = 1
    var currentCustomer: User?
    var nextCustomer: User?

//    var testQueue = [User(name: "Niklas Wagner", userID: "A219"), User(name: "Benedikt Langer", userID: "B372"), User(name: "Jan Cortiel", userID: "D234"), User(name: "Antonia Langer", userID: "A282"), User(name: "Maria Rohnefeld", userID: "A232"), User(name: "Philip Müller", userID: "O281")]

    override func viewDidLoad() {
        super.viewDidLoad()

        bigStackView?.isHidden = true
        customerDoneButton?.isHidden = true
        setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        setUpFirebase()
        if Auth.auth().currentUser != nil {
            if UserDefaultsConfig.isQueueCreated {
                getQueueReference()
                newQueueButton.removeFromSuperview()
                bigStackView.isHidden = false
            }
        }
    }

    func setUpUI() {
        newQueueButton?.applyGradient(colors: [ViewController.UIColorFromRGB(0x69BDD2).cgColor, ViewController.UIColorFromRGB(0x44BCDA).cgColor])
        newQueueButton?.setTitle("Warteschlange erstellen", for: .normal)
    }

    @IBAction func createNewQueueButtonPressed(_ sender: UIButton) {
        let user = Auth.auth().currentUser

        if user == nil {
            presentNotLoggedInAlert()
        } else {
            performSegue(withIdentifier: Segues.newQueueSegue, sender: nil)
        }
    }

    static func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
        return UIColor(red: (CGFloat)((rgbValue & 0xFF0000) >> 16) / 255.0, green: (CGFloat)((rgbValue & 0x00FF00) >> 8) / 255.0, blue: (CGFloat)(rgbValue & 0x0000FF) / 255.0, alpha: 1.0)
    }

    @IBAction func customerDoneButtonPressed(_ sender: UIButton) {
        currentCustomerView.bringSubviewToFront(isCustomerHereButtonStackView)
        currentCustomerView.sendSubviewToBack(customerDoneButton)
        acceptCustomerButton.isHidden = false
        customerNotAvailableButton.isHidden = false
        customerDoneButton.isHidden = true

        removeCurrentCostumer(customerWasAvailable: true)
        //   nextCustomer()
    }

    @IBAction func customerNotAvailableButtonPressed(_ sender: UIButton) {
        //  if !testQueue.isEmpty {
        acceptCustomerButton.isHidden = false
        customerNotAvailableButton.isHidden = false
        customerDoneButton.isHidden = true
        removeCurrentCostumer(customerWasAvailable: false)
        //  }
    }

    @IBAction func acceptCustomerButtonPressed(_ sender: UIButton) {
        // if !testQueue.isEmpty {
        acceptCustomerButton.isHidden = true
        customerNotAvailableButton.isHidden = true
        customerDoneButton.isHidden = false
        currentCustomerView.bringSubviewToFront(customerDoneButton)
        currentCustomerView.sendSubviewToBack(isCustomerHereButtonStackView)
        // }
    }

    func removeCurrentCostumer(customerWasAvailable: Bool) {
        
        guard let queueID = CredentialsController.shared.admin?.queueID?.documentID else {return}
        
        if let currentCustomer = currentCustomer {
            let dataDict: [String: Any] = ["id": queueID, "reference": currentCustomer.id, "position": currentCustomer.numberInQueue, "done": customerWasAvailable ]

            functions.httpsCallable("deleteReference").call(dataDict) { [weak self] _, error in
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        print(message, details)
                    } else {
                        self?.getQueueWith(id: queueID)
                    }
                    // ...
                }
            }
        }
    }


    static func updateQueue(waitingTime: String, queueLength: String) {
        // queueLengthLabel.text = queueLength
        // queueWaitingTimeLabel.text = waitingTime
        print("test")
    }

    func getQueueReference() {
        guard let adminID = Auth.auth().currentUser?.uid else {
            print("user Not Found")
            return
        }
        print(adminID)
        db.collection("admin").document(adminID).getDocument { [weak self] result, error in

            if let error = error {
                print(error.localizedDescription)
            } else if let result = result {
                do {
                    if let admin = try result.data(as: Admin.self) {
                        let queue = admin.queueID
                        CredentialsController.shared.admin = admin
                        guard let id = queue?.documentID else { return }
                        self?.newQueueButton.removeFromSuperview()
                        self?.bigStackView.isHidden = false
                        self?.getQueueWith(id: id)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func getQueueWith(id: String) {
        db.collection("queue").document(id).addSnapshotListener { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let document = result {
                do {
                    if let queue = try document.data(as: Queue.self) {
                        self?.updateQueueInfo(queue: queue)
                        
                        guard let userQueue = queue.userQueue else { return }
                        if userQueue.count < 1 {
                            self?.updateQueueUI()
                        }
                        
                        if userQueue.count == 1 {
                            self?.updateNextCustomerUI()
                        }
                        
                        if userQueue.count > 0 {
                            if let currentCustomer = queue.userQueue?[0] {
                                self?.getCustomer(CustomerRef: currentCustomer, currentCustomer: true)
                            }
                        }
                        if userQueue.count > 1 {
                            if let nextCustomer = queue.userQueue?[1] {
                                self?.getCustomer(CustomerRef: nextCustomer, currentCustomer: false)
                            }
                        }
                    }
                } catch let error as NSError {
                    print("error: \(error)")
                }
            }
        }
    }

    func updateQueueUI() {
        
    acceptCustomerButton.isHidden = true
    customerNotAvailableButton.isHidden = true
    currenCustomerIDLabel.text = "Warteschlange leer."
    currentCustomerLabel.text = ""
        
    nextCustomerNameLabel.text = "Warteschlange leer."
    nextCustomerIDLabel.text = ""
    }
    
    func updateNextCustomerUI() {
        nextCustomerNameLabel.text = "Kein nächster Kunde."
        nextCustomerIDLabel.text = ""
    }

    func updateQueueInfo(queue: Queue) {
        
        acceptCustomerButton.isHidden = false
        customerNotAvailableButton.isHidden = false
        if let queueCount = queue.queueCount, let timePerCustomer = queue.timePerCustomer {
            queueWaitingTimeLabel.text = String(queueCount * timePerCustomer)
            queueLengthLabel.text = String(queueCount)
        }
    }

    func getCustomer(CustomerRef: DocumentReference, currentCustomer: Bool) {
        CustomerRef.getDocument { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let Customer = result {
                do {
                    if let customer = try Customer.data(as: User.self) {
                        if currentCustomer {
                            self?.updateCurrentCustomer(customer: customer)

                        } else {
                            self?.updateNextCustomer(customer: customer)
                        }
                    }
                } catch let error as NSError {
                    print("error: \(error)")
                }
            }
        }
    }

    func updateCurrentCustomer(customer: User) {
        currentCustomer = customer
        if let customerQueueID = customer.customerQueueID {
            currenCustomerIDLabel.text = "Nummer: \(customerQueueID)"
        }
        currentCustomerLabel.text = customer.name
    }

    func updateNextCustomer(customer: User) {
        nextCustomer = customer
        if let customerQueueID = customer.customerQueueID {
            nextCustomerIDLabel.text = "Nummer: \(customerQueueID)"
        }
        nextCustomerNameLabel.text = customer.name
    }

    func presentNotLoggedInAlert() {
        let alert = UIAlertController(title: "Nicht eingeloggt", message: "Bitte loggen Sie sich ein um eine Queue erstellen zu können.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
        }))
        present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.newQueueSegue {
            let vc = segue.destination as! AddQueueViewController
            let newQueueVC = vc.self
        }
    }
}

extension UIButton {
    func applyGradient(colors: [CGColor]) {
        backgroundColor = nil
        layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = frame.height / 2

        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false
        layer.insertSublayer(gradientLayer, at: 0)
        contentVerticalAlignment = .center
        setTitleColor(UIColor.white, for: .normal)
        // self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel?.textColor = UIColor.white
    }
}
