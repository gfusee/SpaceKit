//===--- FixedArray.swift -------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
//  A helper struct to provide fixed-sized array like functionality
//
//===----------------------------------------------------------------------===//

public struct FixedArray8<T> {
  // ABI TODO: This makes assumptions about tuple layout in the ABI, namely that
  // they are laid out contiguously and individually addressable (i.e. strided).
  //
  internal var storage: (
    // A 16-wide tuple of type T
    T, T, T, T, T, T, T, T
  )

  internal var _count: Int8
}

extension FixedArray8 {
  internal static var capacity: Int {
    @inline(__always) get { return 8 }
  }

  internal var capacity: Int {
    @inline(__always) get { return 8 }
  }

  public var count: Int {
    @inline(__always) get { return Int(truncatingIfNeeded: _count) }
    @inline(__always) set { _count = Int8(newValue) }
  }
}

extension FixedArray8: RandomAccessCollection, MutableCollection {
  public typealias Index = Int

  public var startIndex: Index {
    return 0
  }

  public var endIndex: Index {
    return count
  }

  public subscript(i: Index) -> T {
    @inline(__always)
    get {
      let count = self.count // for exclusive access
      //_internalInvariant(i >= 0 && i < count)
      let res: T = withUnsafeBytes(of: storage) {
        (rawPtr: UnsafeRawBufferPointer) -> T in
        let stride = MemoryLayout<T>.stride
        //_internalInvariant(rawPtr.count == 8*stride, "layout mismatch?")
        let bufPtr = UnsafeBufferPointer(
          start: rawPtr.baseAddress!.assumingMemoryBound(to: T.self),
          count: count)
        return bufPtr[i]
      }
      return res
    }
    @inline(__always)
    set {
      //_internalInvariant(i >= 0 && i < count)
      self.withUnsafeMutableBufferPointer { buffer in
        buffer[i] = newValue
      }
    }
  }

  @inline(__always)
  public func index(after i: Index) -> Index {
    return i+1
  }

  @inline(__always)
  public func index(before i: Index) -> Index {
    return i-1
  }
}

extension FixedArray8 {
  internal mutating func append(_ newElement: T) {
    //_internalInvariant(count < capacity)
    _count += 1
    self[count-1] = newElement
  }
}

extension FixedArray8 where T: ExpressibleByIntegerLiteral {
  @inline(__always)
  public init(count: Int) {
    //_internalInvariant(count >= 0 && count <= _FixedArray16.capacity)
    self.storage = (0, 0, 0, 0, 0, 0, 0, 0)
    self._count = Int8(truncatingIfNeeded: count)
  }

  @inline(__always)
  internal init() {
    self.init(count: 0)
  }

  @inline(__always)
  public init(allZeros: ()) {
    self.init(count: 8)
  }
}

extension FixedArray8 {
  public mutating func withUnsafeMutableBufferPointer<R>(
    _ body: (UnsafeMutableBufferPointer<Element>) throws -> R
  ) rethrows -> R {
    let count = self.count // for exclusive access
    return try withUnsafeMutableBytes(of: &storage) { rawBuffer in
      //_internalInvariant(rawBuffer.count == 8*MemoryLayout<T>.stride,"layout mismatch?")
      let buffer = UnsafeMutableBufferPointer<Element>(
        start: rawBuffer.baseAddress.unsafelyUnwrapped
          .assumingMemoryBound(to: Element.self),
        count: count)
      return try body(buffer)
    }
  }

  internal mutating func withUnsafeBufferPointer<R>(
    _ body: (UnsafeBufferPointer<Element>) throws -> R
  ) rethrows -> R {
    let count = self.count // for exclusive access
    return try withUnsafeBytes(of: &storage) { rawBuffer in
      //_internalInvariant(rawBuffer.count == 16*MemoryLayout<T>.stride, "layout mismatch?")
      let buffer = UnsafeBufferPointer<Element>(
        start: rawBuffer.baseAddress.unsafelyUnwrapped
        .assumingMemoryBound(to: Element.self),
        count: count)
      return try body(buffer)
    }
  }
}

extension FixedArray8 where T == UInt8 {
    public func toBigEndianUInt64() -> UInt64 {
        var result: UInt64 = 0
        
        let numOfLeadingZerosToAppend = 8 - self.count
        for i in 0..<8 {
            let valueToShift: UInt8
            if i < numOfLeadingZerosToAppend {
                valueToShift = 0
            } else {
                valueToShift = self[i - numOfLeadingZerosToAppend]
            }
            
            result |= UInt64(valueToShift) << (8 * (7 - i))
        }
        
        return result
    }
}
