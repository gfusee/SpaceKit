import Space

struct StorageModule {
    @UserMapping(key: "user") static var userMapper
    @Mapping<UInt32, UserRole>(key: "user_role") static var userIdToRole
    @Storage(key: "num_board_members") static var numBoardMembers: UInt32
    @Storage(key: "num_proposers") static var numProposers: UInt32
    @Storage(key: "quorum") static var quorum: UInt32
    
    // TODO: this is not developer friendly
    static func getActionMapper() -> VecMapper<Action> {
        return VecMapper(baseKey: "action_data")
    }
    
    // TODO: this is not developer friendly
    static func getActionSignerIdsMapper(actionId: UInt32) -> UnorderedSetMapper<UInt32> {
        var actionIdNestedEncoded = MXBuffer()
        actionId.depEncode(dest: &actionIdNestedEncoded)
        
        return UnorderedSetMapper(baseKey: "action_signer_ids" + actionIdNestedEncoded)
    }
}
