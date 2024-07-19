// This function avoids to mark API as public
public func emitEvent(topicsHandle: Int32, dataHandle: Int32) {
    API.managedWriteLog(topicsHandle: topicsHandle, dataHandle: dataHandle)
}
