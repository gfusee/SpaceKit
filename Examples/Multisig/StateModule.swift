import MultiversX

struct StateModule {
    package static func addMultipleBoardMembers(newBoardMembers: MXArray<Address>) -> UInt32 {
        let userMapper = StorageModule.userMapper
        
        newBoardMembers.forEach { newBoardMember in
            require(
                userMapper.getUserId(address: newBoardMember) != 0,
                "duplicate board member"
            )
            
            let newUserId = userMapper.getOrCreateUser(address: newBoardMember)
            
            StorageModule.userIdToRole[newUserId] = .boardMember
        }
        
        let numBoardMembersMapper = StorageModule.$numBoardMembers
        let newNumBoardMembers = numBoardMembersMapper.get() + UInt32(newBoardMembers.count)
        numBoardMembersMapper.set(newNumBoardMembers)
        
        return newNumBoardMembers
    }
    
    package static func getCallerIdAndRole() -> (UInt32, UserRole) {
        let caller = Message.caller
        let callerId = StorageModule.userMapper.getUserId(address: caller)
        let callerRole = StorageModule.userIdToRole[callerId]
        
        return (callerId, callerRole)
    }
}
