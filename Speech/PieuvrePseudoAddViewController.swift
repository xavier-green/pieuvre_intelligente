//
//  PieuvrePseudoAddViewController.swift
//  Capgemini
//
//  Created by xavier green on 13/03/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import UIKit

class PieuvrePseudoAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var testUsernames: [String] = []
//    var capUsernames = [String]()
    
    @IBOutlet var usernamesView: UITableView!
    @IBOutlet var validation: UILabel!

    @IBOutlet var usernameAdd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernamesView.delegate=self
        usernamesView.dataSource=self
        usernameAdd.delegate=self
        self.hideKeyboardWhenTappedAround()
//        DispatchQueue.global(qos: .background).async {
//            var capUsers = CotoBackMethods().getUsersNames()[0] as! [String]
//            capUsers = capUsers.sorted{$0.localizedCompare($1) == .orderedAscending}
//            DispatchQueue.main.async {
//                self.capUsernames = capUsers
//            }
//        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteUser), name: NSNotification.Name(rawValue: "DELETE_PIEUVRE_USER"), object: nil)
    }
    
    func deleteUser(notification: NSNotification) {
        let usernameToDelete = notification.object as! String
        self.testUsernames.remove(at: self.testUsernames.index(of: usernameToDelete)!)
        self.usernamesView.reloadData()
    }
    
    @IBAction func gotoPieuvreMain(_ sender: Any) {
        GlobalVariables.pieuvreUsernames = self.testUsernames
        performSegue(withIdentifier: "gotoPieuvreView", sender: self)
    }
    @IBAction func addNickname(_ sender: Any) {
        usernameAdd.resignFirstResponder()
    }
    
    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testUsernames.count
    }
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let Name = self.testUsernames[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "pseudoCell",
                                                 for: indexPath) as! PieuvrePseudoCell
        cell.username?.text = Name
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let nickname = textField.text!
//        if !isValidName(testStr: nickname) {
//            validation.isHidden=false
//            validation.text = "Lettres et chiffres uniquement"
//        } else {
//            if !isValidUsername(username: nickname, allUsernames: self.capUsernames) {
//                validation.isHidden=false
//                validation.text = "Le pseudo n'existe pas"
//            } else {
                self.testUsernames.append(nickname)
                self.usernamesView.reloadData()
                textField.text = ""
                validation.isHidden=true
//            }
//        }
    }

    @IBAction func backToSelection(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

class PieuvrePseudoCell: UITableViewCell {
    @IBOutlet var username: UILabel!
    @IBOutlet var deleteUser: UIButton!
    
    override func layoutSubviews() {
        deleteUser.layer.borderWidth = 1
        deleteUser.layer.borderColor = UIColor.lightGray.cgColor
        deleteUser.addTarget(self, action: #selector(self.deleteUsername), for: .touchUpInside)
    }
    
    func deleteUsername() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DELETE_PIEUVRE_USER"), object: self.username.text)
    }
    
}










