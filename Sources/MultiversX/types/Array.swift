public typealias MXArrayType = TopDecode & TopEncode & NestedDecode & NestedEncode & ArrayItem

public struct MXArray<T: MXArrayType> {
    public let buffer: MXBuffer
    
    public init() {
        self.buffer = MXBuffer()
    }
    
    init(handle: Int32) {
        self.buffer = MXBuffer(handle: handle)
    }
    
    public init(buffer: MXBuffer) {
        self.buffer = buffer.clone()
    }
    
    public init(singleItem: T) {
        var array = MXArray()
        array = array.appended(singleItem)
        
        self = array
    }
    
    public var count: Int32 {
        return self.buffer.count / T.payloadSize
    }
    
    public var isEmpty: Bool {
        return self.count == 0
    }
    
    public func appended(_ item: T) -> MXArray<T>{
        let payload = item.intoArrayPayload()
        let newBuffer = self.buffer + payload
        
        return MXArray(buffer: newBuffer)
    }
    
    public func clone() -> MXArray<T> {
        MXArray(buffer: self.buffer.clone())
    }
    
    public func appended(contentsOf newElements: MXArray<T>) -> MXArray<T> {
        var newArray = MXArray(buffer: self.buffer.clone())
        
        newElements.forEach { newArray = newArray.appended($0) }
        
        return newArray
    }
    
    public func get(_ index: Int32) -> T {
        guard index < self.count else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let payloadSize = T.payloadSize
        
        let startIndex = index * payloadSize
        
        let data = self.buffer.getSubBuffer(startIndex: startIndex, length: payloadSize)
        
        return T.decodeArrayPayload(payload: data)
    }
    
    public func replaced(at index: Int32, value: T) -> MXArray<T> {
        guard index < self.count else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let startingPosition = T.payloadSize * index
        let newBuffer = self.buffer.withReplaced(
            startingPosition: startingPosition,
            with: value.intoArrayPayload()
        )
        
        return MXArray(buffer: newBuffer)
    }
    
    public func popFirst() -> (MXArray<T>, T) {
        // TODO: use self.slice?
        // TODO: add tests
        let count = self.count
        let bufferCount = T.payloadSize * count
        
        guard count > 0 else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let startIndex: Int32
        
        if count == 1 {
            startIndex = 0
        } else {
            startIndex = T.payloadSize
        }
        
        let newBufferLength = bufferCount - T.payloadSize
        let newBuffer = self.buffer.getSubBuffer(startIndex: startIndex, length: newBufferLength)
        
        return (MXArray(buffer: newBuffer), self.get(0))
    }
    
    public func popLast() -> (MXArray<T>, T) {
        // TODO: use self.slice?
        // TODO: add tests
        let count = self.count
        let bufferCount = count * T.payloadSize
        
        guard count > 0 else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let newBufferLength = bufferCount - T.payloadSize
        let newBuffer = self.buffer.getSubBuffer(startIndex: 0, length: newBufferLength)
        
        return (MXArray(buffer: newBuffer), self.get(count - 1))
    }
    
    public func removed(_ index: Int32) -> MXArray<T> {
        // TODO: add tests
        let count = self.count
        
        guard index < count else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let partBefore: MXArray<T>
        if index > 0 {
            partBefore = self.slice(startIndex: 0, endIndex: index - 1)
        } else {
            partBefore = MXArray()
        }
        
        let partAfter: MXArray<T>
        if index < count {
            partAfter = self.slice(startIndex: index + 1, endIndex: count - 1)
        } else {
            partAfter = MXArray()
        }
        
        return partBefore.appended(contentsOf: partAfter)
    }
    
    /// Returns a new `MXArray`, containing the [start_index, end_index] range of elements.
    public func slice(startIndex: Int32, endIndex: Int32) -> MXArray<T> {
        // TODO: add tests
        // TODO: ensure indexes are correct? Or is using the getSubBuffer's checks enough
        let startPosition = startIndex * T.payloadSize
        let endPosition = (endIndex + 1) * T.payloadSize
        
        let sliceBuffer = self.buffer.getSubBuffer(startIndex: startPosition, length: endPosition - startPosition)
        
        return MXArray(buffer: sliceBuffer)
    }
    
    public subscript(_ index: Int32) -> T {
        get {
            self.get(index)
        }
    }
    
    #if !WASM
    public func toArray() -> [T] {
        var result: [T] = []
        
        self.forEach { result.append($0) }
        
        return result
    }
    #endif
}

extension MXArray {
    public static func + (lhs: MXArray<T>, rhs: MXArray<T>) -> MXArray<T> {
        return lhs.appended(contentsOf: rhs)
    }
}

extension MXArray: MXSequence {
    public func forEach(_ operations: (T) throws -> Void) rethrows {
        let count = self.count
        var index: Int32 = 0
        
        while index < count {
            let element = self.get(index)
            try operations(element)
            
            index += 1
        }
    }
}

extension MXArray: Equatable where T: Equatable {
    public static func == (lhs: MXArray, rhs: MXArray) -> Bool {
        let lhsCount = lhs.count
        let rhsCount = rhs.count
        
        guard lhsCount == rhsCount else {
            return false
        }
        
        
        for itemIndex in 0..<lhsCount {
            let lhsItem = lhs.get(itemIndex)
            let rhsItem = rhs.get(itemIndex)
            
            guard lhsItem == rhsItem else {
                return false
            }
        }
        
        return true
    }
}

#if !WASM
extension MXArray: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = T
    
    public init(arrayLiteral elements: T...) {
        var tempArray = MXArray()
        
        for element in elements {
            tempArray = tempArray.appended(element)
        }
        
        self.buffer = tempArray.buffer
    }
}
#endif

extension MXArray: TopEncode {
    public func topEncode<O>(output: inout O) where O : TopEncodeOutput {
        var encodedItems = MXBuffer()
        
        self.forEach { $0.depEncode(dest: &encodedItems) }
        
        output.setBuffer(buffer: encodedItems)
    }
}

extension MXArray: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        self.forEach { output.pushSingleValue(arg: $0) }
    }
}

extension MXArray: TopEncodeMultiOutput where T == MXBuffer {
    public mutating func pushSingleValue<TE>(arg: TE) where TE : TopEncode {
        var buffer = MXBuffer()
        arg.topEncode(output: &buffer)
        
        self = self.appended(buffer)
    }
}

extension MXArray: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        var countEncoded = MXBuffer()
        Int(self.count).depEncode(dest: &countEncoded)
        
        var selfTopEncoded = MXBuffer()
        self.topEncode(output: &selfTopEncoded)
        
        dest.write(buffer: countEncoded + selfTopEncoded)
    }
}

extension MXArray: TopDecode {
    public init(topDecode input: MXBuffer) {
        var nestedDecodeInput = BufferNestedDecodeInput(buffer: input)
        
        var buffer = MXBuffer()
        while nestedDecodeInput.canDecodeMore() {
            let item = T(depDecode: &nestedDecodeInput)
            buffer = buffer + item.intoArrayPayload()
        }
        
        self = Self(buffer: buffer)
    }
}

extension MXArray: TopDecodeMulti {}

extension MXArray: TopDecodeMultiInput where T == MXBuffer {
    public func hasNext() -> Bool {
        return self.count > 0
    }
    
    public mutating func nextValueInput() -> MXBuffer {
        let (newSelf, firstElement) = self.popFirst()
        
        self = newSelf
        return firstElement
    }
}

extension MXArray: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let count = Int(depDecode: &input)
        
        var buffer = MXBuffer()
        for _ in 0..<count {
            let item = T(depDecode: &input)
            buffer = buffer + item.intoArrayPayload()
        }
        
        self = Self(buffer: buffer)
    }
}

extension MXArray: ArrayItem {
    
    // TODO: add tests
    public static var payloadSize: Int32 {
        MXBuffer.payloadSize
    }
    
    public static func decodeArrayPayload(payload: MXBuffer) -> MXArray<T> {
        return MXArray(buffer: MXBuffer.decodeArrayPayload(payload: payload))
    }
    
    public func intoArrayPayload() -> MXBuffer {
        return self.buffer.intoArrayPayload()
    }
    
}

#if !WASM
extension MXArray: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
    public var debugDescription: String {
        var itemDebugDescriptions: [String] = []
        
        self.forEach { itemDebugDescriptions.append($0.debugDescription) }
        
        return "[\(itemDebugDescriptions.joined(separator: ", "))]"
    }
}
#endif
