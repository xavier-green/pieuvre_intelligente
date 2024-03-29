//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import UIKit

class ViewController : UIViewController {
  @IBOutlet weak var textView: UITextView!
  var audioData: NSMutableData!

    @IBAction func gotoenroll(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Enrolement", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "EnrolementViewController") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func gotoPieuvre(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Pieuvre", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "pieuvreNavigationController") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
    }
    
  override func viewDidLoad() {
    super.viewDidLoad()
  }
    
}
