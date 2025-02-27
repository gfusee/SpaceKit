struct Manifest: Decodable {
    let dependencies: [PackageDependency]
    let targets: [TargetDescription]
}
