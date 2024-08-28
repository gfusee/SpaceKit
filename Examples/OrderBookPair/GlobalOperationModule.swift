import Space

struct GlobalOperationModule {
    @Storage(key: "global_operation_ongoing") static var isGlobalOperationOngoing: Bool
    
    static func requireGlobalOperationNotOngoing() {
        require(
            !GlobalOperationModule.isGlobalOperationOngoing,
            "Global operation ongoing"
        )
    }
}
