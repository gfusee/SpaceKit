public protocol ErrorApiProtocol {
    mutating func managedSignalError(messageHandle: Int32) -> Never
}
