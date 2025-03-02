public struct Manifest: Decodable {
    public let dependencies: [PackageDependency]
    public let targets: [TargetDescription]
}
