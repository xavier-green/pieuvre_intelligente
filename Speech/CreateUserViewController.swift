//
//  CreateUserViewController.swift
//  Speech
//
//  Created by Younes Belkouchi on 17/03/2017.
//  Copyright © 2017 Google. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController, UITextFieldDelegate {
    private var speaker = String()
    @IBOutlet weak var textfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        textfield.delegate = self
        // Do any additional setup after loading the view.
    }

    @IBAction func backToHole(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        GlobalVariables.username = textField.text!
    }
    @IBAction func create(_ sender: UIButton) {
        textfield.resignFirstResponder()
        DispatchQueue.global(qos: .background).async {
            _ = Connection().createUser(speakerId: GlobalVariables.username)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "enroll", sender: nil)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
