public func assertNoEgldPayment() {
    require(
        Message.egldValue == 0,
        "No EGLD payment allowed" // TODO: use the same message as the Rust SDK
    )
}
