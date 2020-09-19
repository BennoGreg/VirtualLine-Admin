//
//  PhoneLoginViewController.swift
//  VirtualLine User
//
//  Created by Niklas Wagner on 10.09.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class PhoneLoginViewController: ViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var confirmNumberButton: UIButton!
    @IBOutlet weak var verificationCodeLabel: UILabel!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var confirmVerificationButton: UIButton!
    
    let viewModel = PhoneLoginViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.hideKeyboardWhenTappedAround()
        
        viewModel.delegate = self
        phoneNumberTextField.delegate = self
        self.parent?.title = "Login"
         navigationItem.largeTitleDisplayMode = .always
         self.navigationController?.navigationBar.prefersLargeTitles = true
        verificationCodeLabel.isHidden = true
        verificationCodeTextField.isHidden = true
        confirmVerificationButton.isHidden = true
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    @IBAction func confirmNumberButtonPressed(_ sender: UIButton) {
        
        guard let number = phoneNumberTextField.text else {return}
        viewModel.verifyPhoneNumber(phoneNumber: number)
    }
    @IBAction func confirmVerificationButtonClicked(_ sender: UIButton) {
        
        guard let code = verificationCodeTextField.text else {return}
       
        viewModel.checkVerificationCode(verificationCode: code)
            

}
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard CharacterSet(charactersIn: "+0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
      phoneNumberTextField.text = ""
      return false
    }
        return true
    }

}
extension PhoneLoginViewController: PhoneLoginDelegate {
   
    
    
    func phoneNumberValid() {
        
        verificationCodeLabel.isHidden = false
        verificationCodeTextField.isHidden = false
        confirmVerificationButton.isHidden = false
        
    }
    
    func phoneNumberInvalid() {
        print("to do invalid number info pop up")
    }
    
    
   func verificationCodeValid() {
          CredentialsController.shared.updateLogInStatus(loggedIn: true)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
     }
     
     func verificationCodeInvalid() {
         print("invalid code")
     }
    
    func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
       alert.addAction(okAction)
       present(alert, animated: false, completion: nil)
       }
       
       func showTextInputPrompt(withMessage message: String, completionBlock: @escaping ((Bool, String?) -> Void)) {
            let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
             completionBlock(false, nil)
           }
           weak var weakPrompt = prompt
           let okAction = UIAlertAction(title: "OK", style: .default) { _ in
             guard let text = weakPrompt?.textFields?.first?.text else { return }
             completionBlock(true, text)
           }
           prompt.addTextField(configurationHandler: nil)
           prompt.addAction(cancelAction)
           prompt.addAction(okAction)
           present(prompt, animated: true, completion: nil)
       }
       
    
    
    
    
}
