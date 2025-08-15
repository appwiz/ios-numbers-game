import Foundation

class GameModel {
    var gridModel = GridModel()
    var questions: [Question] = []
    var currentQuestionIndex = 0
    var solvedQuestions: Set<Int> = []
    var gameCompleted = false
    
    init() {
        generateQuestionsForCurrentGrid()
    }
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    func generateQuestionsForCurrentGrid() {
        questions.removeAll()
        solvedQuestions.removeAll()
        currentQuestionIndex = 0
        gameCompleted = false
        
        // Generate 5 questions with random solutions in the grid
        for _ in 0..<5 {
            let question = generateRandomQuestion()
            questions.append(question)
        }
    }
    
    private func generateRandomQuestion() -> Question {
        // Generate 3 random numbers
        let num1 = Int.random(in: 0...999)
        let num2 = Int.random(in: 0...999)
        let num3 = Int.random(in: 0...999)
        
        // Place these numbers randomly in the grid in a line (horizontal, vertical, or diagonal)
        let solution = generateRandomSolution()
        
        // Update grid to contain our solution
        if solution.count >= 3 {
            gridModel.numbers[solution[0].row][solution[0].col] = num1
            gridModel.numbers[solution[1].row][solution[1].col] = num2
            gridModel.numbers[solution[2].row][solution[2].col] = num3
        }
        
        return Question(operands: [num1, num2, num3], solution: solution)
    }
    
    private func generateRandomSolution() -> [GridPosition] {
        let directions = [
            (0, 1),   // horizontal right
            (1, 0),   // vertical down
            (1, 1),   // diagonal down-right
            (1, -1),  // diagonal down-left
            (0, -1),  // horizontal left
            (-1, 0),  // vertical up
            (-1, -1), // diagonal up-left
            (-1, 1)   // diagonal up-right
        ]
        
        let direction = directions.randomElement()!
        
        // Find a starting position that allows for 3 positions in the chosen direction
        var validStartPositions: [GridPosition] = []
        
        for row in 0..<GridModel.gridSize {
            for col in 0..<GridModel.gridSize {
                let pos1 = GridPosition(row: row, col: col)
                let pos2 = GridPosition(row: row + direction.0, col: col + direction.1)
                let pos3 = GridPosition(row: row + 2 * direction.0, col: col + 2 * direction.1)
                
                if isValidPosition(pos1) && isValidPosition(pos2) && isValidPosition(pos3) {
                    validStartPositions.append(pos1)
                }
            }
        }
        
        guard let startPos = validStartPositions.randomElement() else {
            // Fallback to simple horizontal solution
            return [
                GridPosition(row: 0, col: 0),
                GridPosition(row: 0, col: 1),
                GridPosition(row: 0, col: 2)
            ]
        }
        
        return [
            startPos,
            GridPosition(row: startPos.row + direction.0, col: startPos.col + direction.1),
            GridPosition(row: startPos.row + 2 * direction.0, col: startPos.col + 2 * direction.1)
        ]
    }
    
    private func isValidPosition(_ position: GridPosition) -> Bool {
        return position.row >= 0 && position.row < GridModel.gridSize &&
               position.col >= 0 && position.col < GridModel.gridSize
    }
    
    func checkSolution() -> Bool {
        guard let question = currentQuestion else { return false }
        
        let selectedNumbers = gridModel.getSelectedNumbers()
        let selectedPositions = Array(gridModel.selectedPositions)
        
        // Check if selected numbers sum to target
        let selectedSum = selectedNumbers.reduce(0, +)
        let targetSum = question.targetSum
        
        // Check if the selection matches any valid path that sums to target
        if selectedSum == targetSum && isValidPath(selectedPositions) {
            solvedQuestions.insert(currentQuestionIndex)
            
            if solvedQuestions.count == questions.count {
                gameCompleted = true
            } else {
                // Move to next unsolved question
                moveToNextUnsolvedQuestion()
            }
            return true
        }
        
        return false
    }
    
    private func isValidPath(_ positions: [GridPosition]) -> Bool {
        guard positions.count >= 2 else { return true }
        
        let sortedPositions = positions.sorted { pos1, pos2 in
            if pos1.row != pos2.row {
                return pos1.row < pos2.row
            }
            return pos1.col < pos2.col
        }
        
        // Check if positions form a valid line (horizontal, vertical, or diagonal)
        for i in 1..<sortedPositions.count {
            let prev = sortedPositions[i-1]
            let curr = sortedPositions[i]
            let deltaRow = curr.row - prev.row
            let deltaCol = curr.col - prev.col
            
            // Check if it's a valid direction and consistent
            if i == 1 {
                // First pair establishes the direction
                continue
            } else {
                let prevDeltaRow = sortedPositions[i-1].row - sortedPositions[i-2].row
                let prevDeltaCol = sortedPositions[i-1].col - sortedPositions[i-2].col
                
                if deltaRow != prevDeltaRow || deltaCol != prevDeltaCol {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func moveToNextUnsolvedQuestion() {
        for i in 0..<questions.count {
            if !solvedQuestions.contains(i) {
                currentQuestionIndex = i
                return
            }
        }
    }
    
    func nextGrid() {
        gridModel.generateGrid()
        generateQuestionsForCurrentGrid()
    }
    
    func submitSelection() -> Bool {
        let success = checkSolution()
        
        if !success {
            // Clear selection if incorrect
            gridModel.clearSelection()
        }
        
        return success
    }
}