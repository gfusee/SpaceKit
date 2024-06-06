public func smartContractError(message: MXBuffer) -> Never {
    API.managedSignalError(messageHandle: message.handle)
}

public func require(_ condition: Bool, _ errorMessage: @autoclosure () -> MXBuffer) {
    if !condition {
        smartContractError(message: errorMessage())
    }
}
