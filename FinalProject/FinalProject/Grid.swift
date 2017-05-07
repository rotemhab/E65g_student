//
//  Grid.swift
//
import Foundation

fileprivate func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

fileprivate let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { GridPosition(row: $0.0,col: $0.1) }
}

fileprivate let offsets: [GridPosition] = [
    GridPosition(row: -1, col:  -1), GridPosition(row: -1, col:  0), GridPosition(row: -1, col:  1),
    GridPosition(row:  0, col:  -1),                                 GridPosition(row:  0, col:  1),
    GridPosition(row:  1, col:  -1), GridPosition(row:  1, col:  0), GridPosition(row:  1, col:  1)
]

public extension GridProtocol {
}

public struct Grid: GridProtocol, GridViewDataSource {
    private var _cells: [[CellState]]
    public let size: GridSize

    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ size: GridSize, cellInitializer: (GridPosition) -> CellState = { _ in .empty }) {
        _cells = [[CellState]](
            repeatElement(
                [CellState]( repeatElement(.empty, count: size.cols)),
                count: size.rows
            )
        )
        self.size = size
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: GridPosition) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: GridPosition) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Grid {
        var nextGrid = Grid(size) { _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        return nextGrid
    }
}

extension Grid: Sequence {
    fileprivate var living: [GridPosition] {
        return lazyPositions(self.size).filter { return  self[$0.row, $0.col].isAlive }
    }
    
    public struct GridIterator: IteratorProtocol {
        private class GridHistory: Equatable {
            let positions: [GridPosition]
            let previous:  GridHistory?
            
            static func == (lhs: GridHistory, rhs: GridHistory) -> Bool {
                return lhs.positions.elementsEqual(rhs.positions, by: ==)
            }
            
            init(_ positions: [GridPosition], _ previous: GridHistory? = nil) {
                self.positions = positions
                self.previous = previous
            }
            
            var hasCycle: Bool {
                var prev = previous
                while prev != nil {
                    if self == prev { return true }
                    prev = prev!.previous
                }
                return false
            }
        }
        
        private var grid: Grid
        private var history: GridHistory!
        
        init(grid: Grid) {
            self.grid = grid
            self.history = GridHistory(grid.living)
        }
        
        public mutating func next() -> Grid? {
            guard !history.hasCycle else { return nil }
            let newGrid = grid.next()
            history = GridHistory(newGrid.living, history)
            grid = newGrid
            return grid
        }
    }
    
    public func makeIterator() -> GridIterator { return GridIterator(grid: self) }
}

public extension Grid {
    public static func gliderInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 2),
             GridPosition(row: 2, col: 0), GridPosition(row: 2, col: 1),
             GridPosition(row: 2, col: 2): return .alive
        default: return .empty
        }
    }
}


protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    var timerInterval: Double { get set }
    var grid: Grid { get set }
    var delegate: EngineDelegate? { get set }
    var updateClosure: ((Grid) -> Void)? { get set }
    func step() -> GridProtocol
}

class Engine: EngineProtocol {
    static var engine: Engine = Engine(rows: 10, cols: 10)

    var grid: Grid
    var delegate: EngineDelegate?
    
    var updateClosure: ((Grid) -> Void)?
    var timer: Timer?
    var timerInterval: TimeInterval = 0.0 {
        didSet {
            if timerInterval > 0.0 {
                timer = Timer.scheduledTimer(
                    withTimeInterval: timerInterval,
                    repeats: true
                ) { (t: Timer) in
                    _ = self.step()
                }
            }
            else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    init(rows: Int, cols: Int) {
        self.grid = Grid(GridSize(rows: rows, cols: cols))
    }
    
    func step() -> GridProtocol {
        let newGrid = grid.next()
        grid = newGrid
//         updateClosure?(self.grid)
        //        delegate?.engineDidUpdate(withGrid: grid)
          let nc = NotificationCenter.default
          let name = Notification.Name(rawValue: "EngineUpdate")
          let n = Notification(name: name,
                               object: nil,
                               userInfo: ["engine" : self])
            nc.post(n)
        return grid
    }
}
