enum ManifestError: Error, CustomStringConvertible {
    case cannotReadJSONManifestAsUTF8(json: String)
    case cannotDecodeManifest(json: String)
    case spaceKitDependencyNotFound
    case spaceKitDependencyShouldHaveExactVersion
    case spaceKitDependencyExactVersionShouldHaveAtLeastOneElement
    case spaceKitDependencyShouldBeAGitRepository
    case spaceKitDependencyShouldHaveAtLeastOneSourceControlInfo
    case spaceKitDependencyUnknownLocationType
    case spaceKitDependencyLocalGitShouldHaveAtLeastOnePath
    case spaceKitDependencyRemoteGitShouldHaveAtLeastOneSettings
    case invalidSpaceKitVersion(versionFound: String)
    case targetNotFound(target: String)
    
    var description: String {
        switch self {
        case .cannotReadJSONManifestAsUTF8(let json):
            """
            Cannot read the Package.swift.
            Check that the file exists and is well-formed.
            
            Package's content:
            
            \(json)
            """
        case .cannotDecodeManifest(let json):
            """
            Cannot decode the Package.swift.
            Check that the file exists and is well-formed.
            
            Package's content:
            
            \(json)
            """
        case .spaceKitDependencyNotFound:
            """
            Package.swift doesn't contain the SpaceKit dependency.
            """
        case .spaceKitDependencyShouldBeAGitRepository:
            """
            The dependency "SpaceKit" in Package.swift should be a Git repository, local or remote.
            """
        case .spaceKitDependencyShouldHaveExactVersion:
            """
            The dependency "SpaceKit" in Package.swift should has be specified by it's exact version.
            """
        case .invalidSpaceKitVersion(let versionFound):
            """
            Invalid version found for the SpaceKit dependency in Package.swift.
            
            Version found: \(versionFound)
            """
        case .targetNotFound(let target):
            """
            Target \(target) not found in Package.swift.
            """
        case .spaceKitDependencyExactVersionShouldHaveAtLeastOneElement:
            """
            The dependency "SpaceKit" in Package.swift should has be specified by it's exact version, but nothing found.
            """
        case .spaceKitDependencyShouldHaveAtLeastOneSourceControlInfo:
            """
            The dependency "SpaceKit" in Package.swift should be a Git repository, local or remote, but nothing found.
            """
        case .spaceKitDependencyUnknownLocationType:
            """
            The dependency "SpaceKit" in Package.swift should be a Git repository, local or remote, but unknown location type found.
            """
        case .spaceKitDependencyLocalGitShouldHaveAtLeastOnePath:
            """
            The dependency "SpaceKit" in Package.swift should contains at least one path when using local git.
            """
        case .spaceKitDependencyRemoteGitShouldHaveAtLeastOneSettings:
            """
            The dependency "SpaceKit" in Package.swift should contains at least one settings when using remote git.
            """
        }
    }
}
