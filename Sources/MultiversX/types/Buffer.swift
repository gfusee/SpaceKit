public typealias String = Buffer

public struct Buffer {
    let handle: Int32

    public init(_ string: StaticString) {
        let handle = getNextHandle()
        BUFFER_API.bufferSetBytes(handle: handle, bytePtr: string.utf8Start, byteLen: Int32(string.utf8CodeUnitCount))

        self.handle = handle
    }

    public init() {
        self.init("")
    }

    public init(handle: Int32) {
        self.handle = handle
    }

    mutating func append(_ other: Self) {
        BUFFER_API.bufferAppend(accumulatorHandle: self.handle, dataHandle: other.handle)
    }

    public func finish() {
        BUFFER_API.bufferFinish(handle: self.handle)
    }
}

extension Buffer: ExpressibleByStringLiteral {
    public init(stringInterpolation: BufferInterpolationMatcher) {
        self.handle = stringInterpolation.buffer.handle
    }

    public init(stringLiteral value: StaticString) {
        self.init(value)
    }
}

public struct BufferInterpolationMatcher: StringInterpolationProtocol {
    var buffer: Buffer

    public init(literalCapacity: Int, interpolationCount: Int) {
        self.buffer = Buffer()
    }

    public mutating func appendLiteral(_ literal: StaticString) {
        self.buffer.append(Buffer(literal))
    }

    public mutating func appendInterpolation(_ value: Buffer) {
        self.buffer.append(value)
    }

    public mutating func appendInterpolation(_ value: BigUint) {
        self.buffer.append(value.toString())
    }
}

extension Buffer: ExpressibleByStringInterpolation {}
