//
//  FirstViewController.swift
//  FinalProject
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var tableTitles: [String] = []
    var content: [[[Int]]] = []
    
    @IBOutlet weak var RefreshRateSlider: UISlider!
    @IBOutlet weak var refreshToggle: UISwitch!
    
    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var sizeBox: UITextField!
    
    var refreshRate : Double = 10.0
    var timeRefresh : Bool = true
    var gridSize: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchTitles()
        sizeBox.text = "\(Int(sizeStepper.value))"
        
    }
    
    
    func sendNotification(){
        sizeBox.text = "\(Int(sizeStepper.value))"
        gridSize = Int(sizeStepper.value)
        refreshRate = Double(RefreshRateSlider.value)
        timeRefresh = refreshToggle.isOn
        
        //prepare the instrumentation notification
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "instrumentationChange")
        let n = Notification(name: name,
                             object: nil,
                             userInfo:[
                                "gridSize" : gridSize,
                                "refreshRate" : refreshRate,
                                "timeRefresh" : timeRefresh
            ])
        
        nc.post(n)
    }
    
    
    @IBAction func SizeStepperClick(_ sender: Any) {
        sendNotification()
    }
    @IBAction func RefreshRateChange(_ sender: Any) {
        sendNotification()
    }
    @IBAction func RefreshToggle(_ sender: Any) {
        sendNotification()
    }
    
    @IBAction func TableAdd(_ sender: Any) {
        let alert = UIAlertController(title: "New Grid", message: "Please select a title for your new grid", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            let newGridName = textField.text!
            self.tableTitles.append(newGridName)
            self.tableView.reloadData()
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    

    
    
    //MARK: TableView DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "TitleCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = tableTitles[indexPath.section]
        return cell
    }
    
    
    func FetchTitles() {
            let fetcher = Fetcher()
            fetcher.fetchJSON(url: URL(string:finalProjectURL)!) { (json: Any?, message: String?) in
                guard message == nil else {
                    print(message ?? "nil")
                    return
                }
                guard let json = json else {
                    print("no json")
                    return
                }
                //print(json)
                let resultString = (json as AnyObject).description
                let jsonArray = json as! NSArray
                let jsonDictionary = jsonArray[0] as! NSDictionary
                let jsonTitle = jsonDictionary["title"] as! String
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
                //print (jsonTitle, jsonContents)
                OperationQueue.main.addOperation {
                    for i in 0...jsonArray.count-1 {
                        let jsonDictionary = jsonArray[i] as! NSDictionary
                        let jsonTitle = jsonDictionary["title"] as! String
                        let jsonContents = jsonDictionary["contents"] as! [[Int]]
                        self.tableTitles.append(jsonTitle)
                        self.content.append(jsonContents)
                        //print(jsonContents[0].max() as Int!)
                        
                    }
                        self.tableView.reloadData()
                }
            }
        }
    
    func getGridSize(_ contentArray:[[Int]])->Int{
        var maxValue = 0
        for i in 0...contentArray.count-1 {
            if contentArray[i].max()! > maxValue {
                maxValue = contentArray[i].max()!
            }
        }
        return maxValue
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let gridTitle = tableTitles[indexPath.section]
            let maxGridSize:Int
            let livingCellsArray:[[Int]]
            if indexPath.section <= content.count-1 {
                maxGridSize = getGridSize(content[indexPath.section])*2
                livingCellsArray = content[indexPath.section]
            } else {
                maxGridSize = Int(sizeStepper.value)
                livingCellsArray = [[]]
            }
            
            if let vc = segue.destination as? InstrumentationViewController2 {
                vc.gridTitle = gridTitle
                vc.maxGridSize = maxGridSize
                vc.livingCellsArray = livingCellsArray
                vc.saveClosure = { newValue in
                    self.tableTitles[indexPath.section] = newValue
                    self.tableView.reloadData()
                }
            }
        }
    }

}

