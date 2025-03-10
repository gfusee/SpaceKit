import SpaceKit

@Controller public struct StorageController {
    @Storage(key: "first_token_id") var firstTokenIdentifier: TokenIdentifier
    @Storage(key: "second_token_id") var secondTokenIdentifier: TokenIdentifier
    @Storage(key: "order_id_counter") var orderIdCounter: UInt64
    @Mapping<Address, Vector<UInt64>>(key: "address_order_ids") var orderIdsForAddress
    @Mapping<UInt64, Order>(key: "orders") var orderForId
    
    public func getOrderById(id: UInt64) -> Order {
        self.orderForId[id]
    }
}
