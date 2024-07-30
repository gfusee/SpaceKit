public func assertOwner() {
    // TODO: add tests
    require(
        Message.caller == Blockchain.getOwner(),
        "endpoint can only be called by owner"
    )
}
