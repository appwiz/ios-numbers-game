import Foundation

class GridModel {
    static let gridSize = 10
    var numbers: [[Int]] = []
    var selectedPositions: Set<GridPosition> = []
    
    init() {
        generateGrid()
    }
    
    func generateGrid() {
        numbers = (0..<GridModel.gridSize).map { _ in
            (0..<GridModel.gridSize).map { _ in
                Int.random(in: 0...999)
            }
        }
    }
    
    func numberAt(_ position: GridPosition) -> Int {
        guard position.row >= 0 && position.row < GridModel.gridSize &&
              position.col >= 0 && position.col < GridModel.gridSize else {
            return 0
        }
        return numbers[position.row][position.col]
    }
    
    func selectPosition(_ position: GridPosition) {
        selectedPositions.insert(position)
    }
    
    func clearSelection() {
        selectedPositions.removeAll()
    }
    
    func getSelectedNumbers() -> [Int] {
        return Array(selectedPositions).sorted { pos1, pos2 in
            if pos1.row != pos2.row {
                return pos1.row < pos2.row
            }
            return pos1.col < pos2.col
        }.map { numberAt($0) }
    }
}