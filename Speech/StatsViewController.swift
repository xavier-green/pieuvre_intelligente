//
//  StatsViewController.swift
//  Capgemini
//
//  Created by xavier green on 13/03/2017.
//  Copyright © 2017 xavier green. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    
    private var independentUsers = [String]()
    private var usersCount = [Double]()
    private var totalCount: Double = 0
    
    @IBOutlet var statsView: UITextView!

    @IBOutlet var wordsView: UITextView!
    
    @IBAction func backToMain(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func processCounts() {
        print("wordcount: ",GlobalVariables.wordCount.count,",users: ",GlobalVariables.namesInOrder.count)
        if GlobalVariables.wordCount.count>0 {
            for i in 0...GlobalVariables.wordCount.count-1 {
                print("boucle ",i)
                let user = GlobalVariables.namesInOrder[i]
                let counts = Double(GlobalVariables.wordCount[i])
                print("user: ",user)
                if independentUsers.contains(user) {
                    let index = independentUsers.index(of: user)
                    usersCount[index!] += counts
                    print("done incrementing")
                } else {
                    print("adding use to independent user")
                    independentUsers.append(user)
                    usersCount.append(counts)
                }
                totalCount += counts
            }
            print(independentUsers)
            print(usersCount)
            self.statsView.text = ""
            print("total: ",totalCount)
            for i in 0...independentUsers.count-1 {
                let percentage = usersCount[i]/totalCount*100
                print("percentage: ",percentage)
                let str = independentUsers[i]+" : "+String(round(Double(percentage)))+"%\n"
                self.statsView.text = self.statsView.text! + str
            }
        }
    }
    
    func processWords() {
        let sortedWords = Array(GlobalVariables.words).sorted(by: { $0.1 > $1.1 })
        var n = Int()
        if (sortedWords.count<3) {
            n = sortedWords.count
        } else {
            n = 3
        }
        let mostUsedWords = sortedWords[0..<n]
        self.wordsView.text = ""
        if mostUsedWords.count>0 {
            for i in 0...mostUsedWords.count-1 {
                let str = mostUsedWords[i].key+" :  "+String(mostUsedWords[i].value)+"\n"
                self.wordsView.text = self.wordsView.text! + str
            }
        } else {
            self.wordsView.text = "Aucun mot enregistré"
        }
        print(sortedWords)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        processCounts()
        processWords()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
