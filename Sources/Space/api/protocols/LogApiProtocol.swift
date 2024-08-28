public protocol LogApiProtocol {
    mutating func managedWriteLog(topicsHandle: Int32, dataHandle: Int32)
}
