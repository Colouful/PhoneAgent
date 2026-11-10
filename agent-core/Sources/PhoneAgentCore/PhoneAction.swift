import Foundation

public enum PhonePlatform: String, Codable, Sendable {
    case ios
    case android
}

public enum PhoneActionType: String, Codable, Sendable {
    case tap
    case longPress = "long_press"
    case swipe
    case scroll
    case typeText = "type_text"
    case pressBack = "press_back"
    case pressHome = "press_home"
    case wait
    case finish
    case requestUserConfirmation = "request_user_confirmation"
}

public struct NormalizedPoint: Codable, Equatable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public var isInBounds: Bool {
        (0.0...1.0).contains(x) && (0.0...1.0).contains(y)
    }
}

public enum ActionRisk: String, Codable, Sendable {
    case low
    case medium
    case high
}

public struct PhoneAction: Codable, Equatable, Sendable {
    public let version: Int
    public let taskID: String
    public let actionID: String
    public let platform: PhonePlatform
    public let type: PhoneActionType
    public let coordinates: NormalizedPoint?
    public let endCoordinates: NormalizedPoint?
    public let deltaX: Int?
    public let deltaY: Int?
    public let text: String?
    public let durationMS: Int?
    public let timeoutMS: Int?
    public let reason: String?
    public let expectedResult: String?
    public let risk: ActionRisk?
    public let requiresConfirmation: Bool?

    enum CodingKeys: String, CodingKey {
        case version, platform, type, coordinates, text, reason, risk
        case taskID = "task_id"
        case actionID = "action_id"
        case endCoordinates = "end_coordinates"
        case deltaX = "delta_x"
        case deltaY = "delta_y"
        case durationMS = "duration_ms"
        case timeoutMS = "timeout_ms"
        case expectedResult = "expected_result"
        case requiresConfirmation = "requires_confirmation"
    }

    public init(
        version: Int = 1,
        taskID: String,
        actionID: String,
        platform: PhonePlatform,
        type: PhoneActionType,
        coordinates: NormalizedPoint? = nil,
        endCoordinates: NormalizedPoint? = nil,
        deltaX: Int? = nil,
        deltaY: Int? = nil,
        text: String? = nil,
        durationMS: Int? = nil,
        timeoutMS: Int? = nil,
        reason: String? = nil,
        expectedResult: String? = nil,
        risk: ActionRisk? = nil,
        requiresConfirmation: Bool? = nil
    ) {
        self.version = version
        self.taskID = taskID
        self.actionID = actionID
        self.platform = platform
        self.type = type
        self.coordinates = coordinates
        self.endCoordinates = endCoordinates
        self.deltaX = deltaX
        self.deltaY = deltaY
        self.text = text
        self.durationMS = durationMS
        self.timeoutMS = timeoutMS
        self.reason = reason
        self.expectedResult = expectedResult
        self.risk = risk
        self.requiresConfirmation = requiresConfirmation
    }
}
