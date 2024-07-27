public func getZeroedBuffer(count: Int32) -> MXBuffer {
    var buffer = MXBuffer()
    
    var remaining = count
    
    let zeros = MXBuffer(data: getZeroedBytes32())
    
    while remaining > 0 {
        let usedZeros: Int32
        if remaining > 32 {
            buffer = buffer + zeros
            
            usedZeros = 32
        } else {
            buffer = buffer + zeros.getSubBuffer(startIndex: 0, length: remaining)
            
            usedZeros = remaining
        }
        
        remaining -= usedZeros
    }
    
    return buffer
}
