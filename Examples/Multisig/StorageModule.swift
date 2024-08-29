import Space

struct StorageModule {
    @UserMapping(key: "user") static var userMapper
    @Mapping<UInt32, UserRole>(key: "user_role") static var userIdToRole
    @Storage(key: "num_board_members") static var numBoardMembers: UInt32
    @Storage(key: "num_proposers") static var numProposers: UInt32
    @Storage(key: "quorum") static var quorum: UInt32
    
    static func getActionMapper() -> VecMapper<Action> {
        return VecMapper(baseKey: "action_data")
    }
    
    static func getActionSignerIdsMapper(actionId: UInt32) -> UnorderedSetMapper<UInt32> {
        return UnorderedSetMapper(baseKey: "action_signer_ids") {
            actionId
        }
    }
}
