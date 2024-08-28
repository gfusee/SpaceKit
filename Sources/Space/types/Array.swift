public typealias VectorType = TopDecode & TopEncode & NestedDecode & NestedEncode & ArrayItem

public struct Vector<T: VectorType> {
    public let buffer: Buffer
    
    public init() {
        self.buffer = Buffer()
    }
    
    init(handle: Int32) {
        self.buffer = Buffer(handle: handle)
    }
    
    public init(buffer: Buffer) {
        self.buffer = buffer.clone()
    }
    
    public init(singleItem: T) {
        var array = Vector()
        array = array.appended(singleItem)
        
        self = array
    }
    
    public var count: Int32 {
        return self.buffer.count / T.payloadSize
    }
    
    public var isEmpty: Bool {
        return self.count == 0
    }
    
    public func appended(_ item: T) -> Vector<T>{
        let payload = item.intoArrayPayload()
        let newBuffer = self.buffer + payload
        
        return Vector(buffer: newBuffer)
    }
    
    public func clone() -> Vector<T> {
        Vector(buffer: self.buffer.clone())
    }
    
    public func appended(contentsOf newElements: Vector<T>) -> Vector<T> {
        var newArray = Vector(buffer: self.buffer.clone())
        
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
    
    public func replaced(at index: Int32, value: T) -> Vector<T> {
        guard index < self.count else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let startingPosition = T.payloadSize * index
        let newBuffer = self.buffer.withReplaced(
            startingPosition: startingPosition,
            with: value.intoArrayPayload()
        )
        
        return Vector(buffer: newBuffer)
    }
    
    public func popFirst() -> (Vector<T>, T) {
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
        
        return (Vector(buffer: newBuffer), self.get(0))
    }
    
    public func popLast() -> (Vector<T>, T) {
        // TODO: use self.slice?
        // TODO: add tests
        let count = self.count
        let bufferCount = count * T.payloadSize
        
        guard count > 0 else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let newBufferLength = bufferCount - T.payloadSize
        let newBuffer = self.buffer.getSubBuffer(startIndex: 0, length: newBufferLength)
        
        return (Vector(buffer: newBuffer), self.get(count - 1))
    }
    
    public func removed(_ index: Int32) -> Vector<T> {
        // TODO: add tests
        let count = self.count
        
        guard index < count else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let partBefore: Vector<T>
        if index > 0 {
            partBefore = self.slice(startIndex: 0, endIndex: index - 1)
        } else {
            partBefore = Vector()
        }
        
        let partAfter: Vector<T>
        if index < count {
            partAfter = self.slice(startIndex: index + 1, endIndex: count - 1)
        } else {
            partAfter = Vector()
        }
        
        return partBefore.appended(contentsOf: partAfter)
    }
    
    /// Returns a new `Vector`, containing the [start_index, end_index] range of elements.
    public func slice(startIndex: Int32, endIndex: Int32) -> Vector<T> {
        // TODO: add tests
        // TODO: ensure indexes are correct? Or is using the getSubBuffer's checks enough
        let startPosition = startIndex * T.payloadSize
        let endPosition = (endIndex + 1) * T.payloadSize
        
        let sliceBuffer = self.buffer.getSubBuffer(startIndex: startPosition, length: endPosition - startPosition)
        
        return Vector(buffer: sliceBuffer)
    }
    
    public func contains(_ element: T) -> Bool where T: Equatable {
        let count = self.count
        for index in 0..<count {
            let value = self.get(index)
            
            if value == element {
                return true
            }
        }
        
        return false
    }
    
    public func index(of element: T) -> Int32? where T: Equatable {
        let count = self.count
        for index in 0..<count {
            let value = self.get(index)
            
            if value == element {
                return index
            }
        }
        
        return nil
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

extension Vector where T == Buffer {
    public func toArgBuffer() -> ArgBuffer {
        return ArgBuffer(rawArgs: self)
    }
}

extension Vector {
    public static func + (lhs: Vector<T>, rhs: Vector<T>) -> Vector<T> {
        return lhs.appended(contentsOf: rhs)
    }
}

extension Vector: MXSequence {
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

extension Vector: Equatable where T: Equatable {
    public static func == (lhs: Vector, rhs: Vector) -> Bool {
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
extension Vector: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = T
    
    public init(arrayLiteral elements: T...) {
        var tempArray = Vector()
        
        for element in elements {
            tempArray = tempArray.appended(element)
        }
        
        self.buffer = tempArray.buffer
    }
}
#endif

extension Vector: TopEncode {
    public func topEncode<O>(output: inout O) where O : TopEncodeOutput {
        var encodedItems = Buffer()
        
        self.forEach { $0.depEncode(dest: &encodedItems) }
        
        output.setBuffer(buffer: encodedItems)
    }
}

extension Vector: TopEncodeMulti {}

extension Vector: TopEncodeMultiOutput where T == Buffer {
    public mutating func pushSingleValue<TE>(arg: TE) where TE : TopEncode {
        var buffer = Buffer()
        arg.topEncode(output: &buffer)
        
        self = self.appended(buffer)
    }
}

extension Vector: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        var countEncoded = Buffer()
        Int(self.count).depEncode(dest: &countEncoded)
        
        var selfTopEncoded = Buffer()
        self.topEncode(output: &selfTopEncoded)
        
        dest.write(buffer: countEncoded + selfTopEncoded)
    }
}

extension Vector: TopDecode {
    public init(topDecode input: Buffer) {
        var nestedDecodeInput = BufferNestedDecodeInput(buffer: input)
        
        var buffer = Buffer()
        while nestedDecodeInput.canDecodeMore() {
            let item = T(depDecode: &nestedDecodeInput)
            buffer = buffer + item.intoArrayPayload()
        }
        
        self = Self(buffer: buffer)
    }
}

extension Vector: TopDecodeMulti {}

extension Vector: TopDecodeMultiInput where T == Buffer {
    public func hasNext() -> Bool {
        return self.count > 0
    }
    
    public mutating func nextValueInput() -> Buffer {
        let (newSelf, firstElement) = self.popFirst()
        
        self = newSelf
        return firstElement
    }
}

extension Vector: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let count = Int(depDecode: &input)
        
        var buffer = Buffer()
        for _ in 0..<count {
            let item = T(depDecode: &input)
            buffer = buffer + item.intoArrayPayload()
        }
        
        self = Self(buffer: buffer)
    }
}

extension Vector: ArrayItem {
    
    // TODO: add tests
    public static var payloadSize: Int32 {
        Buffer.payloadSize
    }
    
    public static func decodeArrayPayload(payload: Buffer) -> Vector<T> {
        return Vector(buffer: Buffer.decodeArrayPayload(payload: payload))
    }
    
    public func intoArrayPayload() -> Buffer {
        return self.buffer.intoArrayPayload()
    }
    
}

#if !WASM
extension Vector: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
    public var debugDescription: String {
        var itemDebugDescriptions: [String] = []
        
        self.forEach { itemDebugDescriptions.append($0.debugDescription) }
        
        return "[\(itemDebugDescriptions.joined(separator: ", "))]"
    }
}
#endif
