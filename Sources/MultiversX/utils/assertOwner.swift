public func assertOwner() {
    require(
        Message.caller == Blockchain.getOwner(),
        "endpoint can only be called by owner"
    )
}
