import SpaceKit

@Contract public struct Counter {
    @Storage(key: "counter") var counter: BigUint
}
