public protocol ArrayItem {
    static var payloadSize: Int32 { get }
    
    static func decodeArrayPayload(payload: MXBuffer) -> Self
    
    func intoArrayPayload() -> MXBuffer
}
