//
//  InstrumentationViewController2.swift
//  FinalProject
//
//  Created by Rotem Haber on 5/5/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController2: UIViewController, GridViewDataSource, EngineDelegate {
    
    @IBOutlet weak var gridNameTextField: UITextField!
    var gridTitle: String?
    var maxGridSize = 10
    var livingCellsArray:[[Int]] = []
    var livingCellsPositions:[GridPosition] = []
    func livingCellsArrayToPositions(_ cellsArray:[[Int]]){
        for i in 0...cellsArray.count-1{
            var pos : GridPosition = GridPosition(row:0,col:0)
            pos.row = cellsArray[i][0]
            pos.col = cellsArray[i][1]
            print(pos)
            self.livingCellsPositions.append(pos)
        }
    }
    var saveClosure: ((String) -> Void)?
    
    func gridInitializer(_ pos: GridPosition) -> CellState {
        if livingCellsPositions.contains(pos) {
            return .alive
        }
        else {
            return .empty
        }
    
//        switch (pos.row, pos.col) {
//        case (livingCellsArray[0][0],livingCellsArray[0][0]): return .alive
//        default: return .empty
//        }
    }
    
    @IBOutlet weak var InstrumentationGridView: XView!
    
    var engine: EngineProtocol!
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livingCellsArrayToPositions(livingCellsArray)
        print(livingCellsPositions)
        if let gridTitle = gridTitle {
            gridNameTextField.text = gridTitle
        }
        engine = Engine.engine
        engine.grid = Grid(GridSize(rows: Int(maxGridSize), cols: Int(maxGridSize)),cellInitializer: gridInitializer)
        InstrumentationGridView.gridSize = maxGridSize
        engine.delegate = self
        engine.updateClosure = { (grid) in
            self.InstrumentationGridView.setNeedsDisplay()
        }
        InstrumentationGridView.gridDataSource = self
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.InstrumentationGridView.setNeedsDisplay()
        }
        
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        self.InstrumentationGridView.setNeedsDisplay()
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
        InstrumentationGridView.setNeedsDisplay()
    }
    
    @IBAction func stop(_ sender: Any) {
        engine.timerInterval = 0.0
    }
    
    @IBAction func start(_ sender: Any) {
        engine.timerInterval = 1.0
    }
    
//    //MARK: Stepper Event Handling
//    @IBAction func step(_ sender: UIStepper) {
//        engine.grid = Grid(GridSize(rows: Int(sender.value), cols: Int(sender.value) + 5))
//        InstrumentationGridView.gridSize = Int(sender.value)
//        InstrumentationGridView.setNeedsDisplay()
//    }
    
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
    @IBAction func save(_ sender: Any) {
        if let newValue = gridNameTextField.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

