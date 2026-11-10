import Foundation

public enum PhoneAgentBLEProtocol {
    public static let service = UUID(uuidString: "6e400001-a9e8-4b1b-9c39-6d6f8a3c0000")!
    public static let command = UUID(uuidString: "6e400001-a9e8-4b1b-9c39-6d6f8a3c0001")!
    public static let reply = UUID(uuidString: "6e400001-a9e8-4b1b-9c39-6d6f8a3c0002")!
    public static let status = UUID(uuidString: "6e400001-a9e8-4b1b-9c39-6d6f8a3c0003")!
    public static let video = UUID(uuidString: "6e400001-a9e8-4b1b-9c39-6d6f8a3c0004")!
    public static let network = UUID(uuidString: "6e400001-a9e8-4b1b-9c39-6d6f8a3c0005")!

    public static func commandLine(id: UInt32, command: String) -> Data {
        Data("\(id) \(command)".utf8)
    }
}
