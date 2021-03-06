//
//  ForgotPasswordViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 25/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
class ForgotPasswordViewController: UIViewController,UITextFieldDelegate {
    //Outlet's
    @IBOutlet var fourthOtpTextField: UITextField!
    @IBOutlet var thirdOtpTextField: UITextField!
    @IBOutlet var secondOtpTextField: UITextField!
    @IBOutlet var firstOtpTextField: UITextField!
    @IBOutlet var resetPasswordButtonOultlet: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var passwordLabel: UITextField!
    @IBOutlet var emailLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        delegateTextField()
    
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    /*
    // MARK: - Reset Button Action
    */
    @IBAction func resetPasswordButton(_ sender: UIButton) {
        if resetPasswordButtonOultlet.currentTitle == "Reset Password"{
            verifyEmailApi()
        }else if resetPasswordButtonOultlet.currentTitle == "Change Password"{
            changePasswordApi()
        }
        
    }
    /*
    // MARK: - Textfield delegate set
    */
    func delegateTextField(){
        firstOtpTextField.delegate = self
        secondOtpTextField.delegate = self
        thirdOtpTextField.delegate = self
        fourthOtpTextField.delegate = self
    }
    /*
    // MARK: - Update UI
    */
    func updateUI(){
        let gray : UIColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.0)
        firstOtpTextField.isHidden = true
        secondOtpTextField.isHidden = true
        thirdOtpTextField.isHidden = true
        fourthOtpTextField.isHidden = true
        
        passwordLabel.isHidden = true
        
        
        emailLabel.layer.cornerRadius = 15.0
        emailLabel.layer.borderWidth = 1.0
        emailLabel.layer.borderColor = gray.cgColor
        
        passwordLabel.layer.cornerRadius = 15.0
        passwordLabel.layer.borderWidth = 1.0
        passwordLabel.layer.borderColor = gray.cgColor
        
        resetPasswordButtonOultlet.layer.cornerRadius = 15.0
        resetPasswordButtonOultlet.layer.borderWidth = 1.0
        resetPasswordButtonOultlet.layer.borderColor = gray.cgColor
    }
    /*
    // MARK: - For Dismiss Keyboard
    */
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailLabel.resignFirstResponder()
        
        passwordLabel.resignFirstResponder()
        
    }
    /*
    // MARK: - API (Verifiy Email)
    */
    func verifyEmailApi(){
        let email = emailLabel.text
        let url = URL(string: "\(urlAPILocation)users/forgotpassword")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":email!]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Server", message: "Could't connect to server please try again after some times", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                                exit(0)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let json = try! JSON(data: data)
            
            if json["message"] == "Verified !! OTP sent in Mail"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Forgot Password", message: "Otp is sent to this email address \(email ?? "0").", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                        self.emailLabel.isHidden = true
                        self.firstOtpTextField.isHidden = false
                        self.secondOtpTextField.isHidden = false
                        self.thirdOtpTextField.isHidden = false
                        self.fourthOtpTextField.isHidden = false
                        self.firstOtpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
                        self.secondOtpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
                        self.thirdOtpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
                        self.fourthOtpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
            }else if json["message"] == "Email does not exits"{
                DispatchQueue.main.async(){
                    self.createAlert(message: "This email \(email ?? "0") is not in our database please check agian or register.", buttonTitle: "Ok")
                }
                
            }
            
        }

        task.resume()
    }
    func createAlert(message:String,buttonTitle:String){
        let alert = UIAlertController(title: "Forgot Password", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    /*
    // MARK: - API (Change Password)
    */
    func changePasswordApi(){
        let email = emailLabel.text
        let password = passwordLabel.text
        let url = URL(string: "\(urlAPILocation)users/resetpassword")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":email!,"password":password!]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let json = try! JSON(data: data)
            print(json)
            if json["message"] == "Password Changed"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Forgot Password", message: "Password Successfully changed!", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
                        //
                        self.performSegue(withIdentifier: "goToVerifiedLogin", sender: self)
                        }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }else if json["message"] == "Email does not exits"{
                DispatchQueue.main.async(){
                    
                    self.createAlert(message: "This email \(String(describing: email)) is not in our database please verify or register.", buttonTitle: "Ok")
                }
                
            }else if json["message"] == "Please Select Diff. Password"{
                DispatchQueue.main.async(){
                    
                    self.createAlert(message: "Old password and new password can't be same please choose different password!", buttonTitle: "Ok")
                }
            }else {
                DispatchQueue.main.async(){
                    self.createAlert(message: "Something Went wrong try again!!", buttonTitle: "Ok")
                }

            }
            
        }

        task.resume()
    }
    /*
    // MARK: - TextField Delegate Method
    */
    @objc func textFieldDidChange(textField: UITextField){

        let text = textField.text

        if (text?.utf16.count)! >= 1{
            switch textField{
            case firstOtpTextField:
                secondOtpTextField.becomeFirstResponder()
            case secondOtpTextField:
                thirdOtpTextField.becomeFirstResponder()
            case thirdOtpTextField:
                fourthOtpTextField.becomeFirstResponder()
            case fourthOtpTextField:
                fourthOtpTextField.resignFirstResponder()
                verifyOTP()
            default:
                break
            }
        }else{

        }
    }
    /*
    // MARK: - API (Verify Otp)
    */
    func verifyOTP(){
        let otp = "\(firstOtpTextField.text ?? "")"+"\(secondOtpTextField.text ?? "")"+"\(thirdOtpTextField.text ?? "")"+"\(fourthOtpTextField.text ?? "")"
        let email = emailLabel.text
        let url = URL(string: "\(urlAPILocation)users/verifyotp")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":email!,"otp":otp]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let json = try! JSON(data: data)
            if json["message"] == "OTP Verified"{
                DispatchQueue.main.async(){
                    self.emailLabel.isHidden = true
                    self.firstOtpTextField.isHidden = true
                    self.secondOtpTextField.isHidden = true
                    self.thirdOtpTextField.isHidden = true
                    self.fourthOtpTextField.isHidden = true
                    self.passwordLabel.isHidden = false
                    self.resetPasswordButtonOultlet.isHidden = false
                    self.resetPasswordButtonOultlet.setTitle("Change Password", for: .normal)
                }
            }else if json["message"] == "Wrong OTP"{
                DispatchQueue.main.async(){
                    self.createAlert(message: "OTP is wrong", buttonTitle: "Ok")
                }
                
            }
            
        }

        task.resume()
    }
}

