import SpaceKit

struct StateModule {
    package static func addMultipleBoardMembers(newBoardMembers: Vector<Address>) -> UInt32 {
        var storageModule = StorageModule()
        
        let userMapper = storageModule.userMapper
        
        newBoardMembers.forEach { newBoardMember in
            require(
                userMapper.getUserId(address: newBoardMember) == 0,
                "duplicate board member"
            )
            
            let newUserId = userMapper.getOrCreateUser(address: newBoardMember)
            
            storageModule.userIdToRole[newUserId] = .boardMember
        }
        
        let numBoardMembersMapper = storageModule.$numBoardMembers
        let newNumBoardMembers = numBoardMembersMapper.get() + UInt32(newBoardMembers.count)
        numBoardMembersMapper.set(newNumBoardMembers)
        
        return newNumBoardMembers
    }
    
    package static func getCallerIdAndRole() -> (UInt32, UserRole) {
        let caller = Message.caller
        
        let storageModule = StorageModule()
        
        let callerId = storageModule.userMapper.getUserId(address: caller)
        let callerRole = storageModule.userIdToRole[callerId]
        
        return (callerId, callerRole)
    }
    
    package static func getActionValidSignerCount(
        actionId: UInt32
    ) -> UInt32 {
        let storageModule = StorageModule()
        
        let signerIds = storageModule.getActionSignerIdsMapper(actionId: actionId)
        
        var result: UInt32 = 0
        
        signerIds.forEach { signerId in
            let signerRole = storageModule.userIdToRole[signerId]
            
            if signerRole.canSign() {
                result += 1
            }
        }
        
        return result
    }
    
    package static func getActionSigners(actionId: UInt32) -> Vector<Address> {
        let storageModule = StorageModule()
        
        let signerIdsMapper = storageModule.getActionSignerIdsMapper(actionId: actionId)
        let userMapper = storageModule.userMapper
        var signers: Vector<Address> = Vector()
        
        signerIdsMapper.forEach { signerId in
            signers = signers.appended(userMapper.getUserAddressUnchecked(id: signerId))
        }
        
        return signers
    }
    
    package static func getActionLastIndex() -> UInt32 {
        let storageModule = StorageModule()
        
        return storageModule.getActionMapper().count
    }
    
    package static func getActionData(actionId: UInt32) -> Action {
        let storageModule = StorageModule()
        
        return storageModule.getActionMapper().get(index: actionId)
    }

}
