enum ReportError: Error, CustomStringConvertible {
    case cannotParseWasm(path: String)
    case hasMemoryAllocations(path: String)
    
    var description: String {
        switch self {
        case .cannotParseWasm(let path):
            """
            Failed to parse the WebAssembly file located at: \(path)
            """
            
        case .hasMemoryAllocations(let path):
            """
            The contract at: \(path) contains memory allocations, which are not supported by SpaceVM.
            Deploying this contract will result in an "invalid contract code" error.

            Common causes of memory allocations include:

            - Usage of `Array<T>` or `[T]`; replace with `SpaceKit.Vector<T>`.
            - Usage of `String`; replace with `StaticString` or `SpaceKit.Buffer`.
            - Usage of classes; prefer `struct` instead.
            - Usage of any functions or types from `Foundation` or external libraries.
            
            Learn more: https://gfusee.github.io/SpaceKit/tutorials/spacekit/familiarizewithtypes
            """
        }
    }
}
