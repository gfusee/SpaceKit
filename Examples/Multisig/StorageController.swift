import SpaceKit

@Controller struct StorageController {
    @UserMapping(key: "user") var userMapper
    @Mapping<UInt32, UserRole>(key: "user_role") var userIdToRole
    @Storage(key: "num_board_members") var numBoardMembers: UInt32
    @Storage(key: "num_proposers") var numProposers: UInt32
    @Storage(key: "quorum") var quorum: UInt32
    
    public func getActionSignerCount(actionId: UInt32) -> UInt32 {
        self.getActionSignerIdsMapper(actionId: actionId).count
    }
    
    public func getQuorum() -> UInt32 {
        self.quorum
    }
    
    public func getNumBoardMembers() -> UInt32 {
        self.numBoardMembers
    }
    
    public func getAllBoardMembers() -> MultiValueEncoded<Address> {
        return self.getAllUsersWithRole(role: .boardMember)
    }
    
    public func getAllProposers() -> MultiValueEncoded<Address> {
        return self.getAllUsersWithRole(role: .proposer)
    }
    
    func getAllUsersWithRole(role: UserRole) -> MultiValueEncoded<Address> {
        var result: MultiValueEncoded<Address> = MultiValueEncoded()
        let numUsers = self.userMapper.getUserCount()
        
        guard numUsers > 0 else {
            return result
        }
        
        let userMapper = self.userMapper
        
        for userId in 1...numUsers {
            if self.userIdToRole[userId] == role {
                if let address = userMapper.getUserAddress(id: userId) {
                    result = result.appended(value: address)
                }
            }
        }
        
        return result
    }
    
    func getActionMapper() -> VecMapper<Action> {
        return VecMapper(baseKey: "action_data")
    }
    
    func getActionSignerIdsMapper(actionId: UInt32) -> UnorderedSetMapper<UInt32> {
        return UnorderedSetMapper(baseKey: "action_signer_ids") {
            actionId
        }
    }
}
