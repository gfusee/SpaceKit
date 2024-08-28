public protocol ArrayItem {
    static var payloadSize: Int32 { get }
    
    static func decodeArrayPayload(payload: Buffer) -> Self
    
    func intoArrayPayload() -> Buffer
}
