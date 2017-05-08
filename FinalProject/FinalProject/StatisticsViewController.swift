//
//  FirstViewController.swift
//  FinalProject
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    
    @IBOutlet weak var LivingNumText: UITextField!
    @IBOutlet weak var BornNumText: UITextField!
    @IBOutlet weak var EmptyNumText: UITextField!
    @IBOutlet weak var DiedNumText: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                if let data = n.userInfo as? [AnyHashable: Any?] {
                    let numLiving = data["numLiving"] as! Int
                    let numBorn = data["numBorn"] as! Int
                    let numEmpty = data["numEmpty"] as! Int
                    let numDied = data["numDied"] as! Int
                    self.LivingNumText.text = "\(numLiving)"
                    self.BornNumText.text = "\(numBorn)"
                    self.EmptyNumText.text = "\(numEmpty)"
                    self.DiedNumText.text = "\(numDied)"
                }
               
        }
    }
    
    @IBAction func Reset(_ sender: Any) {
        LivingNumText.text = ""
        BornNumText.text = ""
        EmptyNumText.text = ""
        DiedNumText.text = ""
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

