public protocol ArrayItem {
    static var shouldSkipReserialization: Bool { get }
    static var payloadSize: UInt32 { get }
    
    static func decodeArrayPayload(payload: MXBuffer) -> Self
    
    func intoArrayPayload() -> MXBuffer
}
