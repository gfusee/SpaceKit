import Space

struct StorageModule {
    @Storage(key: "first_token_id") static var firstTokenIdentifier: Buffer
    @Storage(key: "second_token_id") static var secondTokenIdentifier: Buffer
    @Storage(key: "order_id_counter") static var orderIdCounter: UInt64
    @Mapping<Address, Vector<UInt64>>(key: "address_order_ids") static var orderIdsForAddress
    @Mapping<UInt64, Order>(key: "orders") static var orderForId
}
