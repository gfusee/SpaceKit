#if !WASM
import SpaceKitABI
#endif

fileprivate let ADDRESS_TO_ID_SUFFIX: StaticString = "_address_to_id"
fileprivate let ID_TO_ADDRESS_SUFFIX: StaticString = "_id_to_address"
fileprivate let COUNT_SUFFIX: StaticString = "_count"

public struct UserMapper: StorageMapper {
    let baseKey: Buffer
    
    public init(baseKey: Buffer) {
        self.baseKey = baseKey
    }
    
    private func getUserIdMapper(address: Address) -> SingleValueMapper<UInt32> {
        return SingleValueMapper(baseKey: self.baseKey + Buffer(stringLiteral: ADDRESS_TO_ID_SUFFIX) + address.buffer)
    }
    
    private func getUserAddressMapper(id: UInt32) -> SingleValueMapper<Address> {
        var idBuffer = Buffer()
        id.depEncode(dest: &idBuffer)
        
        return SingleValueMapper(baseKey: self.baseKey + Buffer(stringLiteral: ID_TO_ADDRESS_SUFFIX) + idBuffer)
    }
    
    private func getUserCountMapper() -> SingleValueMapper<UInt32> {
        return SingleValueMapper(baseKey: self.baseKey + Buffer(stringLiteral: COUNT_SUFFIX))
    }
    
    public func getUserId(address: Address) -> UInt32 {
        return self.getUserIdMapper(address: address).get()
    }
    
    public func getUserAddressUnchecked(id: UInt32) -> Address {
        return self.getUserAddressMapper(id: id).get()
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
    
    public func getAllAddresses() -> Vector<Address> {
        let userCount = self.getUserCount()
        
        var result = Vector<Address>()
        
        for i in 1..<(1 + userCount) {
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
        MultiValueEncoded(items: self.getAllAddresses()).multiEncode(output: &output)
    }
}

#if !WASM
extension UserMapper: TopDecodeMulti {
    public typealias SwiftVMDecoded = MultiValueEncoded<Address>
    
    static public func fromTopDecodeMultiInput(_ input: inout some TopDecodeMultiInput) -> MultiValueEncoded<Address> {
        MultiValueEncoded(topDecodeMulti: &input)
    }
    
    public init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        smartContractError(message: "UserMapper should not be decoded using TopDecodeMulti in the SwiftVM. If you encounter this error please open an issue on GitHub.")
    }
}
#endif

#if !WASM
extension UserMapper: ABITypeExtractor {
    public static var _abiTypeName: String {
        MultiValueEncoded<Address>._abiTypeName
    }
    
    public static var _isMulti: Bool {
        MultiValueEncoded<Address>._isMulti
    }
}
#endif
