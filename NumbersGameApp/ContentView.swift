import SwiftUI

struct ContentView: View {
    var body: some View {
        GameView()
    }
}

// Copy all the model classes
struct GridPosition: Hashable, Equatable {
    let row: Int
    let col: Int
}

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

class GridModel: ObservableObject {
    static let gridSize = 10
    @Published var numbers: [[Int]] = []
    @Published var selectedPositions: Set<GridPosition> = []
    
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

class GameModel: ObservableObject {
    @Published var gridModel = GridModel()
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var solvedQuestions: Set<Int> = []
    @Published var gameCompleted = false
    
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
    
    func submitSelection() {
        let success = checkSolution()
        
        if !success {
            // Clear selection if incorrect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.gridModel.clearSelection()
            }
        } else {
            // Keep selection visible briefly to show success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.gridModel.clearSelection()
            }
        }
    }
}

struct QuestionView: View {
    let question: Question?
    let questionNumber: Int
    let totalQuestions: Int
    let isSolved: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(questionNumber + 1) of \(totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isSolved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            if let question = question {
                Text(question.displayText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSolved ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSolved ? Color.green : Color.blue, lineWidth: 2)
                    )
            } else {
                Text("Loading question...")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct GridView: View {
    @ObservedObject var gridModel: GridModel
    @State private var dragPosition: CGPoint = .zero
    @State private var isDragging = false
    
    let cellSize: CGFloat = 35
    let spacing: CGFloat = 2
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<GridModel.gridSize, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<GridModel.gridSize, id: \.self) { col in
                        let position = GridPosition(row: row, col: col)
                        let number = gridModel.numberAt(position)
                        let isSelected = gridModel.selectedPositions.contains(position)
                        
                        Text("\(number)")
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: cellSize, height: cellSize)
                            .background(isSelected ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
                            .foregroundColor(isSelected ? .white : .black)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .background(
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isDragging {
                                gridModel.clearSelection()
                                isDragging = true
                            }
                            
                            let position = getGridPosition(from: value.location)
                            if let pos = position {
                                gridModel.selectPosition(pos)
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
        )
    }
    
    private func getGridPosition(from location: CGPoint) -> GridPosition? {
        let totalWidth = CGFloat(GridModel.gridSize) * cellSize + CGFloat(GridModel.gridSize - 1) * spacing
        let totalHeight = CGFloat(GridModel.gridSize) * cellSize + CGFloat(GridModel.gridSize - 1) * spacing
        
        // Calculate offset from center
        let startX = -totalWidth / 2
        let startY = -totalHeight / 2
        
        let x = location.x - startX
        let y = location.y - startY
        
        guard x >= 0 && y >= 0 else { return nil }
        
        let col = Int(x / (cellSize + spacing))
        let row = Int(y / (cellSize + spacing))
        
        guard row >= 0 && row < GridModel.gridSize &&
              col >= 0 && col < GridModel.gridSize else { return nil }
        
        return GridPosition(row: row, col: col)
    }
}

struct GameView: View {
    @StateObject private var gameModel = GameModel()
    @State private var showCompletionAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress indicator
                ProgressView(value: Double(gameModel.solvedQuestions.count), total: Double(gameModel.questions.count))
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal)
                
                // Current question
                QuestionView(
                    question: gameModel.currentQuestion,
                    questionNumber: gameModel.currentQuestionIndex,
                    totalQuestions: gameModel.questions.count,
                    isSolved: gameModel.solvedQuestions.contains(gameModel.currentQuestionIndex)
                )
                .padding(.horizontal)
                
                // Number grid
                GridView(gridModel: gameModel.gridModel)
                    .padding()
                
                // Instructions
                Text("Drag across numbers to select a sequence that adds up to the target sum")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Submit button
                Button("Submit Selection") {
                    gameModel.submitSelection()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(gameModel.gridModel.selectedPositions.isEmpty ? Color.gray : Color.blue)
                )
                .disabled(gameModel.gridModel.selectedPositions.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Numbers Game")
            .onChange(of: gameModel.gameCompleted) { completed in
                if completed {
                    showCompletionAlert = true
                }
            }
            .alert("Level Complete!", isPresented: $showCompletionAlert) {
                Button("Next Level") {
                    gameModel.nextGrid()
                }
                Button("Restart") {
                    gameModel.nextGrid()
                }
            } message: {
                Text("Congratulations! You found all 5 solutions!")
            }
        }
    }
}

#Preview {
    ContentView()
}