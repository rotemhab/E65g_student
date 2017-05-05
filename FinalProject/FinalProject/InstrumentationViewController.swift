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
    var content: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchTitles()
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
                print(type(of: jsonArray))
                let jsonDictionary = jsonArray[0] as! NSDictionary
                let jsonTitle = jsonDictionary["title"] as! String
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
                //print (jsonTitle, jsonContents)
                OperationQueue.main.addOperation {
                    for i in 0...jsonArray.count-1 {
                        let jsonDictionary = jsonArray[i] as! NSDictionary
                        let jsonTitle = jsonDictionary["title"] as! String
                        self.tableTitles.append(jsonTitle)
                    }
                        self.tableView.reloadData()
                }
            }
        }


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let indexPath = tableView.indexPathForSelectedRow
//        if let indexPath = indexPath {
//            let fruitValue = data[indexPath.section][indexPath.row]
//            if let vc = segue.destination as? GridEditorViewController {
//                vc.fruitValue = fruitValue
//                vc.saveClosure = { newValue in
//                    data[indexPath.section][indexPath.row] = newValue
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }

}

