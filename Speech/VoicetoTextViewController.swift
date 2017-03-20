//
//  VoicetoTextViewController.swift
//  Capgemini
//
//  Created by Younes Belkouchi on 13/03/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import UIKit

class VoicetoTextViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var speakingUsername = ""
    
    private var namesInOrder = [String]()
    private var phrasesInOrder = [String]()
    private var wordCount = [Int]()
    
    @IBOutlet weak var usernames: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.processResult), name: NSNotification.Name(rawValue: "PIEUVRE_TEXT"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.processName), name: NSNotification.Name(rawValue: "PIEUVRE_NAME"), object: nil)
        // Do any additional setup after loading the view.
        usernames.delegate=self
        usernames.dataSource=self
        print(GlobalVariables.pieuvreUsernames)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalVariables.pieuvreUsernames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as? nameCell
        let currentUsername = GlobalVariables.pieuvreUsernames[indexPath.row]
        cell?.nameLabel.text = currentUsername
        if (currentUsername == self.speakingUsername) {
            cell?.layer.borderWidth = 1
            cell?.layer.borderColor = UIColor.blue.cgColor
        } else {
            cell?.layer.borderWidth = 0
        }
        return cell!
    }
    func processName(notification: NSNotification) {
        
        print("got name")
        let result = notification.object as! String
        namesInOrder.append(result)
        self.speakingUsername = result
        usernames.beginUpdates()
        let indexPosition = GlobalVariables.pieuvreUsernames.index(of: result)
        usernames.moveRow(at: NSIndexPath(row: indexPosition!, section: 0) as IndexPath, to: NSIndexPath(row: 0, section: 0) as IndexPath)
        GlobalVariables.pieuvreUsernames.insert(GlobalVariables.pieuvreUsernames.remove(at: indexPosition!), at: 0)
        usernames.endUpdates()
        usernames.reloadData()
    }
    
    func processResult(notification: NSNotification) {
        
        print("got phrase")
        
        let result = notification.object as! [String]
//        let score = result[0]
        let phrase = result[1]
        phrasesInOrder.append(phrase)
        wordCount(s: phrase)
        
    }
    
    func wordCount(s: String) {
        let words = s.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty}
        wordCount.append(words.count)
        print("finished adding word count: ",words.count)
        for word in words {
            if let count = GlobalVariables.words[word] {
                GlobalVariables.words[word] = count + 1
            } else {
                GlobalVariables.words[word] = 1
            }
        }
    }
    
    func setGlobalVariables() {
//        GlobalVariables.namesInOrder = self.namesInOrder
        GlobalVariables.phrasesInOrder = self.phrasesInOrder
        print("setting global variables:")
        print(self.wordCount)
//        GlobalVariables.wordCount = self.wordCount
    }
    
    @IBAction func getStats(_ sender: Any) {
        self.setGlobalVariables()
        performSegue(withIdentifier: "gotoStats", sender: self)
    }
    
    @IBAction func showResultingText(_ sender: UIButton) {
        self.setGlobalVariables()
        print(namesInOrder)
        print("*******")
        print(phrasesInOrder)
        performSegue(withIdentifier: "showTexteSegue", sender: self)
    }
    
}

class nameCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}
