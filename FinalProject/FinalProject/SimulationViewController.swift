//
//  SecondViewController.swift
//  FinalProject
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    
    @IBOutlet weak var gridView: XView!
    @IBOutlet weak var sizeStepper: UIStepper!
    
    
    var engine: EngineProtocol!
    var timer: Timer?
    
//    func getData(_ notification: NSNotification) {
//        
//        if let data = notification.userInfo?["maxGridSize"] {
//            print(data)
//            print("success!")
//        }
//    }
    
    func cellsArrayToPositions(_ cellsArray:[[Int]])->[GridPosition]{
        var positionArray:[GridPosition] = []
        if cellsArray.count > 0 {
            for i in 0...cellsArray.count-1{
                var pos : GridPosition = GridPosition(row:0,col:0)
                pos.row = cellsArray[i][0]
                pos.col = cellsArray[i][1]
                positionArray.append(pos)
                var positionArray:[GridPosition] = []
            }
            
        }
        return positionArray
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        var recoveredBornPositions :[[Int]] = []
        var recoveredAlivePositions :[[Int]] = []
        var recoveredDiedPositions :[[Int]] = []
        var recoveredMaxGridSize :Int = 10

        recoveredBornPositions = defaults.object(forKey: "bornPositions") as! [[Int]]
        recoveredAlivePositions = defaults.object(forKey: "alivePositions") as! [[Int]]
        recoveredDiedPositions = defaults.object(forKey: "diedPositions") as! [[Int]]
        recoveredMaxGridSize = defaults.object(forKey: "maxGridSize") as! Int
        
        func gridInitializer(_ pos: GridPosition) -> CellState {
            if cellsArrayToPositions(recoveredAlivePositions as! [[Int]]).contains(pos) {
                return .alive
            }
            else if (cellsArrayToPositions(recoveredDiedPositions as! [[Int]]).contains(pos)){
                return .died
            } else if (cellsArrayToPositions(recoveredBornPositions as! [[Int]]).contains(pos)){
                return .born
            }
            else {
                return .empty
            }
        }
        
        engine = Engine.engine
        engine.grid = Grid(GridSize(rows: Int(recoveredMaxGridSize as! Int), cols: Int(recoveredMaxGridSize as! Int)),cellInitializer: gridInitializer)
        gridView.gridSize = recoveredMaxGridSize as! Int
        gridView.livingColor = UIColor(red: 0.0, green: 0.9, blue: 0.0, alpha: 1.0)
        gridView.bornColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.6)
        gridView.emptyColor = UIColor(white: 0.3, alpha: 1.0)
        gridView.diedColor = UIColor(white: 0.3, alpha: 0.6)
        gridView.gridColor = UIColor.black
        gridView.gridWidth = 2.0
        engine.delegate = self
        engine.updateClosure = { (grid) in
            self.gridView.setNeedsDisplay()
        }
        gridView.gridDataSource = self
        sizeStepper.value = Double(engine.grid.size.rows)
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let name2 = Notification.Name(rawValue: "gridSave")
        let name3 = Notification.Name(rawValue: "instrumentationChange")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
        
        nc.addObserver(
            forName: name2,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
                if let data = n.userInfo as? [AnyHashable: Any?] {
                    self.gridView.gridSize = data["gridSize"] as! Int
                }
                
        }
        
        nc.addObserver(
            forName: name3,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
                if let data = n.userInfo as? [AnyHashable: Any?] {
                    let newGridSize = data["gridSize"] as! Int
                    self.gridView.gridSize = newGridSize
                    self.engine.grid = Grid(GridSize(rows: newGridSize, cols: newGridSize))
                    self.engine.timerInterval = data["refreshRate"] as! Double
                }
                
        }
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func otherStop(_ sender: Any) {
    }
    
    @IBAction func next(_ sender: Any) {
        engine.step()
        gridView.setNeedsDisplay()
    }
    
    @IBAction func stop(_ sender: Any) {
        engine.timerInterval = 0.0
    }
    
    @IBAction func start(_ sender: Any) {
        engine.timerInterval = 0.1
    }
    
    //MARK: Stepper Event Handling
    @IBAction func step(_ sender: UIStepper) {
        engine.grid = Grid(GridSize(rows: Int(sender.value), cols: Int(sender.value) + 5))
        gridView.gridSize = Int(sender.value)
        gridView.setNeedsDisplay()
    }
    
    //MARK: AlertController Handling
    func showErrorAlert(withMessage msg:String, action: (() -> Void)? ) {
        let alert = UIAlertController(
            title: "Alert",
            message: msg,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true) { }
            OperationQueue.main.addOperation { action?() }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
