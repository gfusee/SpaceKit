#if !WASM
public func getAllABIExportableEvents() -> [ABIEvent] {
    var events: [ABIEvent] = []

    let allABITypeExtractorsClasses = Runtime.classes(conformTo: ABIEventExtractor.Type.self)
    for classIndice in allABITypeExtractorsClasses.indices {
        let classType: AnyClass = allABITypeExtractorsClasses[classIndice]
        let eventType = classType as! (any ABIEventExtractor.Type)
        
        let fullClassName = NSStringFromClass(classType)
        guard !fullClassName.starts(with: "SpaceKit") else {
            continue
        }
        
        events.append(eventType._extractABIEvent)
    }
    
    return events
}
#endif
