public protocol EndpointApiProtocol {
    mutating func getNumArguments() -> Int32
    
    mutating func managedGetCallbackClosure(callbackClosureHandle: Int32)
}
