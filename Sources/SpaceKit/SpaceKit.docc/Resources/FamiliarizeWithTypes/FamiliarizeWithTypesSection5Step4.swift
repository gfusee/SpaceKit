import SpaceKit

@Codable public enum MyEnum {
    case firstCase(BigUint)
}

@Codable public struct MyStruct {
    let myBiguint: BigUint
    let myInteger: UInt64
    let myBuffer: Buffer
    let myEnum: MyEnum
}
