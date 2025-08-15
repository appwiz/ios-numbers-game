import XCTest
@testable import NumbersGameTests

fileprivate extension NumbersGameTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__NumbersGameTests = [
        ("testGameModelIncorrectSolution", testGameModelIncorrectSolution),
        ("testGameModelInitialization", testGameModelInitialization),
        ("testGameModelSolutionChecking", testGameModelSolutionChecking),
        ("testGridModel", testGridModel),
        ("testGridModelNumberAt", testGridModelNumberAt),
        ("testNextGrid", testNextGrid),
        ("testQuestionCreation", testQuestionCreation)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __NumbersGameTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NumbersGameTests.__allTests__NumbersGameTests)
    ]
}