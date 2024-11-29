public func smartContractError(message: Buffer) -> Never {
    API.managedSignalError(messageHandle: message.handle)
}

public func require(_ condition: Bool, _ errorMessage: @autoclosure () -> Buffer) {
    if !condition {
        smartContractError(message: errorMessage())
    }
}
