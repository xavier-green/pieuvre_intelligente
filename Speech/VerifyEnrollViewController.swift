//
//  VerifyEnrollViewController.swift
//  Speech
//
//  Created by Younes Belkouchi on 20/03/2017.
//  Copyright © 2017 Google. All rights reserved.
//

import UIKit

class VerifyEnrollViewController: UIViewController {

    @IBOutlet weak var verified: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func VerifyButton(_ sender: UIButton) {
        DispatchQueue.global(qos: .background).async {
            let verifiedText = Connection().enrollCheck(speakerId: GlobalVariables.username)
            DispatchQueue.main.async {
                self.verified.text = verifiedText
            }
        }
    }

    @IBAction func endEnroll(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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
