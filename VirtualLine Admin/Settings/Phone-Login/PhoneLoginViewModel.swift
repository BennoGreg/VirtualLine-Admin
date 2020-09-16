//
//  PhoneLoginViewModel.swift
//  VirtualLine User
//
//  Created by Niklas Wagner on 10.09.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//
import FirebaseAuth

protocol PhoneLoginDelegate : AnyObject {
    
    func phoneNumberValid()
    func phoneNumberInvalid()
    func verificationCodeValid()
    func verificationCodeInvalid()
    func showMessagePrompt(_ message: String)
    func showTextInputPrompt(withMessage message: String, completionBlock: @escaping ((Bool, String?) -> Void))
    
}

class PhoneLoginViewModel {
    
    private let keyForVerificationID = "AuthVerificatonID"
       var verificationID = ""
       var isMFAEnabled = true
    var delegate: PhoneLoginDelegate?
    
    func verifyPhoneNumber(phoneNumber: String) {
           
           Auth.auth().languageCode = "de"
          
           PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) {  [weak self] (verificationID, error) in
               if let error = error {
                   print("Unable to get Verification: \(error)")
                self?.delegate?.phoneNumberInvalid()
               }else {
                   guard let verificationID = verificationID else { return }
                self?.verificationID = verificationID
                UserDefaultsConfig.verificationID = verificationID
                self?.delegate?.phoneNumberValid()
               }
           }
       }
    
     public func checkVerificationCode(verificationCode: String) {
            
            let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)

            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.text = "Some default text"
            }
            
            if verificationID == "" {
                verificationID = UserDefaults.standard.string(forKey: keyForVerificationID) ?? ""
            }
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
            
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
              if let error = error {
                let authError = error as NSError
                guard let strongSelf = self else {return}
                if (strongSelf.isMFAEnabled && authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
                  // The user is a multi-factor user. Second factor challenge is required.
                  let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                  var displayNameString = ""
                  for tmpFactorInfo in (resolver.hints) {
                    displayNameString += tmpFactorInfo.displayName ?? ""
                    displayNameString += " "
                  }
                    self?.delegate?.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)", completionBlock: { userPressedOK, displayName in
                    var selectedHint: PhoneMultiFactorInfo?
                    for tmpFactorInfo in resolver.hints {
                      if (displayName == tmpFactorInfo.displayName) {
                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                      }
                    }
                    PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                      if error != nil {
                        print("Multi factor start sign in failed. Error: \(error.debugDescription)")
                      } else {
                        self?.delegate?.showTextInputPrompt(withMessage: "Verification code for \(selectedHint?.displayName ?? "")", completionBlock: { userPressedOK, verificationCode in
                          let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode!)
                          let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                          resolver.resolveSignIn(with: assertion!) { authResult, error in
                            if error != nil {
                              print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
                            } else {
                             // self.navigationController?.popViewController(animated: true)
                            }
                          }
                        })
                      }
                    }
                  })
                } else {
                    print(error.localizedDescription)
                    self?.delegate?.verificationCodeInvalid()
    //              self.showMessagePrompt(error.localizedDescription)
                  return
                }
                // ...
                return
              }
              // User is signed in
              // ...
                self?.delegate?.verificationCodeValid()
                print("success")
            }
        }
       
    public func logOutPhoneNumber() {
        
        
    }
   
}
