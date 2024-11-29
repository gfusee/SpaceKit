import SpaceKit

struct StorageModule {
    @UserMapping(key: "user") var userMapper
    @Mapping<UInt32, UserRole>(key: "user_role") var userIdToRole
    @Storage(key: "num_board_members") var numBoardMembers: UInt32
    @Storage(key: "num_proposers") var numProposers: UInt32
    @Storage(key: "quorum") var quorum: UInt32
    
    func getActionMapper() -> VecMapper<Action> {
        return VecMapper(baseKey: "action_data")
    }
    
    func getActionSignerIdsMapper(actionId: UInt32) -> UnorderedSetMapper<UInt32> {
        return UnorderedSetMapper(baseKey: "action_signer_ids") {
            actionId
        }
    }
}
