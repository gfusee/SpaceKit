import SpaceKit

@Controller public struct Counter {
    @Storage(key: "counter") var counter: BigUint
}
