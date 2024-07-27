fileprivate let ADDRESS_TO_ID_SUFFIX: StaticString = "_address_to_id"
fileprivate let ID_TO_ADDRESS_SUFFIX: StaticString = "_id_to_address"
fileprivate let COUNT_SUFFIX: StaticString = "_count"

public struct UserMapper {
    let baseKey: MXBuffer
    
    public init(baseKey: MXBuffer) {
        self.baseKey = baseKey
    }
    
    private func getUserIdMapper(address: Address) -> SingleValueMapper<UInt32> {
        return SingleValueMapper(key: self.baseKey + MXBuffer(stringLiteral: ADDRESS_TO_ID_SUFFIX) + address.buffer)
    }
    
    private func getUserAddressMapper(id: UInt32) -> SingleValueMapper<Address> {
        var idBuffer = MXBuffer()
        id.depEncode(dest: &idBuffer)
        
        return SingleValueMapper(key: self.baseKey + MXBuffer(stringLiteral: ID_TO_ADDRESS_SUFFIX) + idBuffer)
    }
    
    private func getUserCountMapper() -> SingleValueMapper<UInt32> {
        return SingleValueMapper(key: self.baseKey + MXBuffer(stringLiteral: COUNT_SUFFIX))
    }
    
    public func getUserId(address: Address) -> UInt32 {
        return self.getUserIdMapper(address: address).get()
    }
    
    public func getUserAddress(id: UInt32) -> Address? {
        let mapper = self.getUserAddressMapper(id: id)
        
        if mapper.isEmpty() {
            return nil
        } else {
            return mapper.get()
        }
    }
    
    public func getUserCount() -> UInt32 {
        let mapper = self.getUserCountMapper()
        
        return mapper.get()
    }
    
    public func getAllAddresses() -> MXArray<Address> {
        let userCount = self.getUserCount()
        
        var result = MXArray<Address>()
        
        for i in 1...userCount {
            result = result.appended(self.getUserAddress(id: i) ?? Address())
        }
        
        return result
    }
    
    private func setUserId(address: Address, id: UInt32) {
        self.getUserIdMapper(address: address).set(id)
    }
    
    private func setUserAddress(id: UInt32, address: Address) {
        self.getUserAddressMapper(id: id).set(address)
    }
    
    private func setUserCount(userCount: UInt32) {
        self.getUserCountMapper().set(userCount)
    }
    
    public func getOrCreateUser(address: Address) -> UInt32 {
        let userIdMapper = self.getUserIdMapper(address: address)
        var userId = userIdMapper.get()
        
        if userId == 0 {
            let userCountMapper = self.getUserCountMapper()
            let userCount = userCountMapper.get()
            
            let nextUserCount = userCount + 1
            userCountMapper.set(nextUserCount)
            
            userId = nextUserCount
            userIdMapper.set(userId)
            
            let userAddressMapper = self.getUserAddressMapper(id: userId)
            userAddressMapper.set(address)
        }
        
        return userId
    }
}

extension UserMapper: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        self.getAllAddresses().multiEncode(output: &output)
    }
}
