import Space

@Codable enum MyEnum {
    case firstCase(BigUint)
}

@Codable struct MyStruct {
    let myBiguint: BigUint
    let myInteger: UInt64
    let myBuffer: Buffer
    let myEnum: MyEnum
}
