import SpaceKit

@Controller public struct CounterController {
    @Storage(key: "counter") var counter: BigUint
}
