import Foundation

public struct ActionValidationContext: Sendable {
    public let screenIsFresh: Bool
    public let transportConnected: Bool
    public let emergencyStopActive: Bool
    /// Local policy decision; never trust a model-provided risk label as the sole source.
    public let policyRequiresConfirmation: Bool
    /// The exact immutable action the user approved. Equality binds approval to its payload.
    public let confirmedAction: PhoneAction?

    public init(
        screenIsFresh: Bool,
        transportConnected: Bool,
        emergencyStopActive: Bool,
        policyRequiresConfirmation: Bool = false,
        confirmedAction: PhoneAction? = nil
    ) {
        self.screenIsFresh = screenIsFresh
        self.transportConnected = transportConnected
        self.emergencyStopActive = emergencyStopActive
        self.policyRequiresConfirmation = policyRequiresConfirmation
        self.confirmedAction = confirmedAction
    }
}

public enum ActionValidationError: Error, Equatable, CustomStringConvertible {
    case unsupportedVersion
    case emptyIdentifiers
    case missingCoordinates
    case coordinatesOutOfBounds
    case missingEndCoordinates
    case missingScrollDelta
    case zeroScrollDelta
    case invalidScrollDelta
    case missingDuration
    case missingText
    case textTooLong
    case invalidDuration
    case invalidTimeout
    case screenNotFresh
    case transportDisconnected
    case emergencyStopActive
    case confirmationRequired

    public var description: String {
        switch self {
        case .unsupportedVersion: return "Unsupported action schema version"
        case .emptyIdentifiers: return "task_id and action_id must be non-empty"
        case .missingCoordinates: return "Action requires normalized coordinates"
        case .coordinatesOutOfBounds: return "Coordinates must be within 0...1"
        case .missingEndCoordinates: return "Swipe requires end_coordinates"
        case .missingScrollDelta: return "Scroll requires delta_x and delta_y"
        case .zeroScrollDelta: return "Scroll delta cannot be zero on both axes"
        case .invalidScrollDelta: return "Scroll delta must be within -20...20 on each axis"
        case .missingDuration: return "This gesture requires duration_ms"
        case .missingText: return "type_text requires text"
        case .textTooLong: return "Text exceeds 500 characters"
        case .invalidDuration: return "duration_ms must be 50...10000"
        case .invalidTimeout: return "timeout_ms must be 100...30000"
        case .screenNotFresh: return "Screen frame is stale or unavailable"
        case .transportDisconnected: return "ESP32 transport is disconnected"
        case .emergencyStopActive: return "Emergency stop is active"
        case .confirmationRequired: return "User confirmation is required"
        }
    }
}

public enum ActionValidator {
    /// Validate immediately before HID dispatch, not only when parsing model output.
    public static func validate(
        _ action: PhoneAction,
        context: ActionValidationContext
    ) -> Result<Void, ActionValidationError> {
        guard action.version == 1 else { return .failure(.unsupportedVersion) }
        guard !action.taskID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !action.actionID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.emptyIdentifiers)
        }
        guard !context.emergencyStopActive else { return .failure(.emergencyStopActive) }

        let isTerminal = action.type == .finish || action.type == .requestUserConfirmation
        if !isTerminal {
            guard context.transportConnected else { return .failure(.transportDisconnected) }
            guard context.screenIsFresh else { return .failure(.screenNotFresh) }
        }

        switch action.type {
        case .tap:
            guard let point = action.coordinates else { return .failure(.missingCoordinates) }
            guard point.isInBounds else { return .failure(.coordinatesOutOfBounds) }
        case .longPress:
            guard let point = action.coordinates else { return .failure(.missingCoordinates) }
            guard point.isInBounds else { return .failure(.coordinatesOutOfBounds) }
            guard action.durationMS != nil else { return .failure(.missingDuration) }
        case .swipe:
            guard let start = action.coordinates else { return .failure(.missingCoordinates) }
            guard let end = action.endCoordinates else { return .failure(.missingEndCoordinates) }
            guard start.isInBounds && end.isInBounds else { return .failure(.coordinatesOutOfBounds) }
            guard action.durationMS != nil else { return .failure(.missingDuration) }
        case .scroll:
            guard let dx = action.deltaX, let dy = action.deltaY else { return .failure(.missingScrollDelta) }
            guard dx != 0 || dy != 0 else { return .failure(.zeroScrollDelta) }
            guard (-20...20).contains(dx), (-20...20).contains(dy) else { return .failure(.invalidScrollDelta) }
        case .typeText:
            guard let text = action.text, !text.isEmpty else { return .failure(.missingText) }
            guard text.count <= 500 else { return .failure(.textTooLong) }
        case .pressBack, .pressHome, .wait, .finish, .requestUserConfirmation:
            break
        }

        if let duration = action.durationMS, !(50...10_000).contains(duration) {
            return .failure(.invalidDuration)
        }
        if let timeout = action.timeoutMS, !(100...30_000).contains(timeout) {
            return .failure(.invalidTimeout)
        }

        let requiresConfirmation = context.policyRequiresConfirmation
            || action.requiresConfirmation == true
            || action.risk == .high
        if requiresConfirmation && context.confirmedAction != action {
            return .failure(.confirmationRequired)
        }
        return .success(())
    }
}
