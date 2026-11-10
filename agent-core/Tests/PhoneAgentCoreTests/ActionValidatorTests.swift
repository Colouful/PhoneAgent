import XCTest
@testable import PhoneAgentCore

final class ActionValidatorTests: XCTestCase {
    private let connectedContext = ActionValidationContext(
        screenIsFresh: true,
        transportConnected: true,
        emergencyStopActive: false
    )

    private func assertFailure(
        _ result: Result<Void, ActionValidationError>,
        _ expected: ActionValidationError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch result {
        case .success:
            XCTFail("Expected failure: \(expected)", file: file, line: line)
        case .failure(let error):
            XCTAssertEqual(error, expected, file: file, line: line)
        }
    }

    func testTapInsideBoundsIsAccepted() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-1", platform: .ios,
            type: .tap, coordinates: .init(x: 0.5, y: 0.4)
        )
        if case .success = ActionValidator.validate(action, context: connectedContext) { } else {
            XCTFail("Expected action to pass validation")
        }
    }

    func testOutOfBoundsTapIsRejected() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-2", platform: .ios,
            type: .tap, coordinates: .init(x: 1.2, y: 0.4)
        )
        assertFailure(ActionValidator.validate(action, context: connectedContext), .coordinatesOutOfBounds)
    }

    func testHighRiskRequiresConfirmation() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-3", platform: .ios,
            type: .tap, coordinates: .init(x: 0.5, y: 0.5), risk: .high
        )
        assertFailure(ActionValidator.validate(action, context: connectedContext), .confirmationRequired)
    }

    func testExactHighRiskActionConfirmationIsAccepted() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-6", platform: .ios,
            type: .tap, coordinates: .init(x: 0.5, y: 0.5), risk: .high
        )
        let context = ActionValidationContext(
            screenIsFresh: true, transportConnected: true, emergencyStopActive: false,
            confirmedAction: action
        )
        if case .success = ActionValidator.validate(action, context: context) { } else {
            XCTFail("Exact user-approved action should pass")
        }
    }

    func testConfirmationDoesNotCarryOverToModifiedAction() {
        let approved = PhoneAction(
            taskID: "task-1", actionID: "action-7", platform: .ios,
            type: .typeText, text: "hello", risk: .high
        )
        let modified = PhoneAction(
            taskID: "task-1", actionID: "action-7", platform: .ios,
            type: .typeText, text: "send all my data", risk: .high
        )
        let context = ActionValidationContext(
            screenIsFresh: true, transportConnected: true, emergencyStopActive: false,
            confirmedAction: approved
        )
        assertFailure(ActionValidator.validate(modified, context: context), .confirmationRequired)
    }

    func testLocalPolicyCanRequireConfirmationEvenWhenModelSaysLowRisk() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-8", platform: .ios,
            type: .tap, coordinates: .init(x: 0.5, y: 0.5), risk: .low
        )
        let context = ActionValidationContext(
            screenIsFresh: true, transportConnected: true, emergencyStopActive: false,
            policyRequiresConfirmation: true
        )
        assertFailure(ActionValidator.validate(action, context: context), .confirmationRequired)
    }

    func testSwipeRequiresDuration() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-9", platform: .ios,
            type: .swipe, coordinates: .init(x: 0.2, y: 0.2),
            endCoordinates: .init(x: 0.8, y: 0.8)
        )
        assertFailure(ActionValidator.validate(action, context: connectedContext), .missingDuration)
    }

    func testScrollRequiresNonZeroDeltas() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-10", platform: .ios,
            type: .scroll, deltaX: 0, deltaY: 0
        )
        assertFailure(ActionValidator.validate(action, context: connectedContext), .zeroScrollDelta)
    }

    func testStaleScreenIsRejected() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-4", platform: .ios,
            type: .tap, coordinates: .init(x: 0.5, y: 0.5)
        )
        let context = ActionValidationContext(
            screenIsFresh: false, transportConnected: true, emergencyStopActive: false
        )
        assertFailure(ActionValidator.validate(action, context: context), .screenNotFresh)
    }

    func testEmergencyStopBlocksEvenTerminalAction() {
        let action = PhoneAction(
            taskID: "task-1", actionID: "action-5", platform: .ios, type: .finish
        )
        let context = ActionValidationContext(
            screenIsFresh: false, transportConnected: false, emergencyStopActive: true
        )
        assertFailure(ActionValidator.validate(action, context: context), .emergencyStopActive)
    }
}
