public func assertNoEsdtPayment() {
    require(
        Message.allEsdtTransfers.isEmpty,
        "No ESDT payment allowed" // TODO: use the same message as the Rust SDK
    )
}
