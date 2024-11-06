import Space

struct GlobalOperationModule {
    @Storage(key: "global_operation_ongoing") var isGlobalOperationOngoing: Bool
    
    func requireGlobalOperationNotOngoing() {
        require(
            !self.isGlobalOperationOngoing,
            "Global operation ongoing"
        )
    }
}
