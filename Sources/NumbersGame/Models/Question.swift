import Foundation

struct Question {
    let id = UUID()
    let operands: [Int] // Three numbers to add
    let targetSum: Int
    let solution: [GridPosition] // Positions in grid that form the solution
    
    init(operands: [Int], solution: [GridPosition]) {
        self.operands = operands
        self.targetSum = operands.reduce(0, +)
        self.solution = solution
    }
    
    var displayText: String {
        return "\(operands[0]) + \(operands[1]) + \(operands[2]) = ?"
    }
}

struct GridPosition: Hashable, Equatable {
    let row: Int
    let col: Int
}