import SpaceKit

@Controller struct StorageController {
    @Storage(key: "first_token_id") var firstTokenIdentifier: Buffer
    @Storage(key: "second_token_id") var secondTokenIdentifier: Buffer
    @Storage(key: "order_id_counter") var orderIdCounter: UInt64
    @Mapping<Address, Vector<UInt64>>(key: "address_order_ids") var orderIdsForAddress
    @Mapping<UInt64, Order>(key: "orders") var orderForId
    
    public func getOrderById(id: UInt64) -> Order {
        self.orderForId[id]
    }
}
