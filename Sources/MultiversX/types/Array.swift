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
        
        for item in newElements {
            newArray = newArray.appended(item)
        }
        
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
        
        for item in self {
            result.append(item)
        }
        
        return result
    }
    #endif
}

public struct MXArrayIterator<T: MXArrayType>: IteratorProtocol {
    let array: MXArray<T>
    let count: Int32
    
    var index: Int32 = 0
    
    init(array: MXArray<T>) {
        self.count = array.count
        self.array = array
    }
    
    public mutating func next() -> T? {
        guard self.index < self.count else {
            return nil
        }
        
        let result = self.array.get(self.index)
        
        self.index += 1
        
        return result
    }
}

extension MXArray {
    public static func + (lhs: MXArray<T>, rhs: MXArray<T>) -> MXArray<T> {
        return lhs.appended(contentsOf: rhs)
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

extension MXArray: Sequence {
    public func makeIterator() -> MXArrayIterator<T> {
        MXArrayIterator(array: self)
    }
}

extension MXArray: TopEncode {
    public func topEncode<O>(output: inout O) where O : TopEncodeOutput {
        var encodedItems = MXBuffer()
        for item in self {
            item.depEncode(dest: &encodedItems)
        }
        
        output.setBuffer(buffer: encodedItems)
    }
}

extension MXArray: TopEncodeMulti {}

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

#if !WASM
extension MXArray: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
    public var debugDescription: String {
        var itemDebugDescriptions: [String] = []
        
        for item in self {
            itemDebugDescriptions.append(item.debugDescription)
        }
        
        return "[\(itemDebugDescriptions.joined(separator: ", "))]"
    }
}
#endif
