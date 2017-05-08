//
//  InstrumentationViewController2.swift
//  FinalProject
//
//  Created by Rotem Haber on 5/5/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController2: UIViewController, GridViewDataSource {
    
    @IBOutlet weak var gridNameTextField: UITextField!
    
    var gridTitle: String?
    var maxGridSize = 10
    var livingCellsArray:[[Int]] = []
    var livingCellsPositions:[GridPosition] = []
    
    //create a function for converting an array of array of Integers to an array of positions
    func livingCellsArrayToPositions(_ cellsArray:[[Int]]){
        if (cellsArray.count>1) {
        for i in 0...cellsArray.count-1{
            var pos : GridPosition = GridPosition(row:0,col:0)
            pos.row = cellsArray[i][0]
            pos.col = cellsArray[i][1]
            self.livingCellsPositions.append(pos)
        }
        }
    }
    var saveClosure: ((String) -> Void)?
    
    //create a function for initializing the grid with the living cells from the JSON file
    func gridInitializer(_ pos: GridPosition) -> CellState {
        if livingCellsPositions.contains(pos) {
            return .alive
        }
        else {
            return .empty
        }
    }
    
    @IBOutlet weak var InstrumentationGridView: XView!
    
    var engine: EngineProtocol!
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livingCellsArrayToPositions(livingCellsArray)
        if let gridTitle = gridTitle {
            gridNameTextField.text = gridTitle
        }
        engine = Engine.engine
        engine.grid = Grid(GridSize(rows: Int(maxGridSize), cols: Int(maxGridSize)),cellInitializer: gridInitializer)
        InstrumentationGridView.gridSize = maxGridSize
        engine.timerInterval = 0.0
        engine.updateClosure = { (grid) in
            self.InstrumentationGridView.setNeedsDisplay()
        }
        InstrumentationGridView.gridDataSource = self
        
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
    @IBAction func save(_ sender: Any) {
        
        //send the grid name back to the first screen
        if let newValue = gridNameTextField.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            self.navigationController?.popViewController(animated: true)
        }
        
        //get the grid state
        var bornPositions:[[Int]] = []
        var alivePositions: [[Int]] = []
        var diedPositions:[[Int]] = []
        
        for row in 0...maxGridSize-1{
            for col in 0...maxGridSize-1{
                if (engine.grid[row,col] == .born){
                    bornPositions.append([row,col])
                } else if (engine.grid[row,col] == .alive){
                    alivePositions.append([row,col])
                } else if (engine.grid[row,col] == .died){
                    diedPositions.append([row,col])
                }
            }
        }
        //save the grid state to file
        let defaults = UserDefaults.standard
        defaults.set(bornPositions, forKey: "bornPositions")
        defaults.set(alivePositions, forKey: "alivePositions")
        defaults.set(diedPositions, forKey: "diedPositions")
        defaults.set(maxGridSize, forKey: "maxGridSize")
        
        //create a new notification to send the grid state to the simulation tab
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "gridSave")
        let n = Notification(name: name,
                             object: nil,
                             userInfo:[
                                "engine" : engine,
                                "gridSize" : maxGridSize
                            ])
        nc.post(n)
        
    }
}

