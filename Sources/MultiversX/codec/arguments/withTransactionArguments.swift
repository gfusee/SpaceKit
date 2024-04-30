public func withTransactionArguments<each T: TopDecode, R>(operation: (repeat each T) -> R) -> R {
    let buffer = MXBuffer()
    return operation(repeat (each T).topDecode(input: buffer))
}
