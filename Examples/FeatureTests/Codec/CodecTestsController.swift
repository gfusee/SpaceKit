import SpaceKit

@Init public func initialize(
    initialBigUint: BigUint
) {
    let controller = CodecTestsController()
    controller.getBigUintSingleValueMapper().set(initialBigUint)
}

@Controller public struct CodecTestsController {
    public func getBigUintSingleValueMapper() -> SingleValueMapper<BigUint> {
        SingleValueMapper(baseKey: "bigUintSingleValueMapper")
    }
}
