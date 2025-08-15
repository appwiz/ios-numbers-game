import XCTest
@testable import NumbersGame

final class NumbersGameTests: XCTestCase {
    func testQuestionCreation() {
        let positions = [
            GridPosition(row: 0, col: 0),
            GridPosition(row: 0, col: 1),
            GridPosition(row: 0, col: 2)
        ]
        let question = Question(operands: [100, 200, 300], solution: positions)
        
        XCTAssertEqual(question.targetSum, 600)
        XCTAssertEqual(question.displayText, "100 + 200 + 300 = ?")
        XCTAssertEqual(question.solution.count, 3)
    }
    
    func testGridModel() {
        let gridModel = GridModel()
        
        XCTAssertEqual(gridModel.numbers.count, GridModel.gridSize)
        XCTAssertEqual(gridModel.numbers[0].count, GridModel.gridSize)
        
        let position = GridPosition(row: 0, col: 0)
        gridModel.selectPosition(position)
        
        XCTAssertTrue(gridModel.selectedPositions.contains(position))
        
        gridModel.clearSelection()
        XCTAssertTrue(gridModel.selectedPositions.isEmpty)
    }
    
    func testGridModelNumberAt() {
        let gridModel = GridModel()
        
        // Test valid position
        let validPosition = GridPosition(row: 0, col: 0)
        let number = gridModel.numberAt(validPosition)
        XCTAssertTrue(number >= 0 && number <= 999)
        
        // Test invalid position
        let invalidPosition = GridPosition(row: -1, col: -1)
        XCTAssertEqual(gridModel.numberAt(invalidPosition), 0)
        
        let outOfBoundsPosition = GridPosition(row: GridModel.gridSize, col: GridModel.gridSize)
        XCTAssertEqual(gridModel.numberAt(outOfBoundsPosition), 0)
    }
    
    func testGameModelInitialization() {
        let gameModel = GameModel()
        
        XCTAssertEqual(gameModel.questions.count, 5)
        XCTAssertEqual(gameModel.currentQuestionIndex, 0)
        XCTAssertTrue(gameModel.solvedQuestions.isEmpty)
        XCTAssertFalse(gameModel.gameCompleted)
        XCTAssertNotNil(gameModel.currentQuestion)
    }
    
    func testGameModelSolutionChecking() {
        let gameModel = GameModel()
        
        // Manually set up a simple test case
        let question = Question(operands: [1, 2, 3], solution: [
            GridPosition(row: 0, col: 0),
            GridPosition(row: 0, col: 1),
            GridPosition(row: 0, col: 2)
        ])
        
        gameModel.questions = [question]
        gameModel.currentQuestionIndex = 0
        gameModel.gridModel.numbers[0][0] = 1
        gameModel.gridModel.numbers[0][1] = 2
        gameModel.gridModel.numbers[0][2] = 3
        
        // Select the correct positions
        gameModel.gridModel.selectPosition(GridPosition(row: 0, col: 0))
        gameModel.gridModel.selectPosition(GridPosition(row: 0, col: 1))
        gameModel.gridModel.selectPosition(GridPosition(row: 0, col: 2))
        
        let result = gameModel.submitSelection()
        XCTAssertTrue(result)
        XCTAssertTrue(gameModel.solvedQuestions.contains(0))
    }
    
    func testGameModelIncorrectSolution() {
        let gameModel = GameModel()
        
        // Set up a question
        let question = Question(operands: [1, 2, 3], solution: [
            GridPosition(row: 0, col: 0),
            GridPosition(row: 0, col: 1),
            GridPosition(row: 0, col: 2)
        ])
        
        gameModel.questions = [question]
        gameModel.currentQuestionIndex = 0
        gameModel.gridModel.numbers[0][0] = 1
        gameModel.gridModel.numbers[0][1] = 2
        gameModel.gridModel.numbers[0][2] = 4 // Wrong number
        
        // Select positions that don't sum correctly
        gameModel.gridModel.selectPosition(GridPosition(row: 0, col: 0))
        gameModel.gridModel.selectPosition(GridPosition(row: 0, col: 1))
        gameModel.gridModel.selectPosition(GridPosition(row: 0, col: 2))
        
        let result = gameModel.submitSelection()
        XCTAssertFalse(result)
        XCTAssertFalse(gameModel.solvedQuestions.contains(0))
        XCTAssertTrue(gameModel.gridModel.selectedPositions.isEmpty) // Should be cleared
    }
    
    func testNextGrid() {
        let gameModel = GameModel()
        let originalGrid = gameModel.gridModel.numbers
        
        gameModel.nextGrid()
        
        // Grid should be regenerated
        XCTAssertNotEqual(originalGrid, gameModel.gridModel.numbers)
        XCTAssertEqual(gameModel.questions.count, 5)
        XCTAssertEqual(gameModel.currentQuestionIndex, 0)
        XCTAssertTrue(gameModel.solvedQuestions.isEmpty)
        XCTAssertFalse(gameModel.gameCompleted)
    }
}