import SpaceKit

@Init func initialize() {
    let controller = PauseProxyController()
    
    let _ = controller.allOwners.insert(value: Message.caller)
}
