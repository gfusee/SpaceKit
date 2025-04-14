import SpaceKit

@Controller public struct StateController {
    public func sign(actionId: UInt32) {
        let storageController = StorageController()
        
        let actionMapper = storageController.getActionMapper()
        
        require(
            !actionMapper.isItemEmptyUnchecked(index: actionId),
            "action does not exist"
        )
        
        let (callerId, callerRole) = self.getCallerIdAndRole()
        require(
            callerRole.canSign(),
            "only board members can sign"
        )
        
        let actionSignerIdsMapper = storageController.getActionSignerIdsMapper(actionId: actionId)
        
        if !actionSignerIdsMapper.contains(value: callerId) {
            let _ = actionSignerIdsMapper.insert(value: callerId)
        }
    }
    
    public func unsign(actionId: UInt32) {
        let storageController = StorageController()
        
        let actionMapper = storageController.getActionMapper()
        
        require(
            !actionMapper.isItemEmptyUnchecked(index: actionId),
            "action does not exist"
        )
        
        let (callerId, callerRole) = self.getCallerIdAndRole()
        require(
            callerRole.canSign(),
            "only board members can un-sign"
        )
        
        let actionSignerIdsMapper = storageController.getActionSignerIdsMapper(actionId: actionId)
        let _ = actionSignerIdsMapper.swapRemove(value: callerId)
    }
    
    public func getActionSigners(actionId: UInt32) -> Vector<Address> {
        let storageController = StorageController()
        
        let signerIdsMapper = storageController.getActionSignerIdsMapper(actionId: actionId)
        let userMapper = storageController.userMapper
        var signers: Vector<Address> = Vector()
        
        for signerId in signerIdsMapper {
            signers = signers.appended(userMapper.getUserAddressUnchecked(id: signerId))
        }
        
        return signers
    }
    
    public func getPendingActionFullInfo() -> MultiValueEncoded<ActionFullInfo> {
        var resultArray: Vector<ActionFullInfo> = Vector()
        
        let storageController = StorageController()
        
        let actionLastIndex = self.getActionLastIndex()
        let actionMapper = storageController.getActionMapper()
        
        for actionId in 1...actionLastIndex {
            let actionData = actionMapper.get(index: actionId)
            if actionData.isPending {
                resultArray = resultArray.appended(
                    ActionFullInfo(
                        actionId: actionId,
                        actionData: actionData,
                        signers: self.getActionSigners(actionId: actionId)
                    )
                )
            }
        }
        
        return MultiValueEncoded(items: resultArray)
    }
    
    public func getActionData(actionId: UInt32) -> Action {
        let storageController = StorageController()
        
        return storageController.getActionMapper().get(index: actionId)
    }
    
    public func getActionLastIndex() -> UInt32 {
        let storageController = StorageController()
        
        return storageController.getActionMapper().count
    }
    
    public func getActionValidSignerCount(
        actionId: UInt32
    ) -> UInt32 {
        let storageController = StorageController()
        
        let signerIds = storageController.getActionSignerIdsMapper(actionId: actionId)
        
        var result: UInt32 = 0
        
        for signerId in signerIds {
            let signerRole = storageController.userIdToRole[signerId]
            
            if signerRole.canSign() {
                result += 1
            }
        }
        
        return result
    }
    
    func addMultipleBoardMembers(newBoardMembers: Vector<Address>) -> UInt32 {
        var storageController = StorageController()
        
        let userMapper = storageController.userMapper
        
        for newBoardMember in newBoardMembers {
            require(
                userMapper.getUserId(address: newBoardMember) == 0,
                "duplicate board member"
            )
            
            let newUserId = userMapper.getOrCreateUser(address: newBoardMember)
            
            storageController.userIdToRole[newUserId] = .boardMember
        }
        
        let numBoardMembersMapper = storageController.$numBoardMembers
        let newNumBoardMembers = numBoardMembersMapper.get() + UInt32(newBoardMembers.count)
        numBoardMembersMapper.set(newNumBoardMembers)
        
        return newNumBoardMembers
    }
    
    func getCallerIdAndRole() -> (UInt32, UserRole) {
        let caller = Message.caller
        
        let storageController = StorageController()
        
        let callerId = storageController.userMapper.getUserId(address: caller)
        let callerRole = storageController.userIdToRole[callerId]
        
        return (callerId, callerRole)
    }
}
