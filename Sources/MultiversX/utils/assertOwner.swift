public func assertOwner() {
    // TODO: add tests
    require(
        Message.caller == Blockchain.getOwner(),
        "Endpoint can only be called by owner"
    )
}
