enum ManifestError: Error, CustomStringConvertible {
    case cannotReadManifest(path: String)
    case spaceKitDependencyNotFound(manifestPath: String)
    case cannotReadDependencyRequirement(manifestPath: String, dependency: String)
    case spaceKitDependencyShouldHaveExactVersion(manifestPath: String)
    case spaceKitDependencyShouldBeAGitRepository(manifestPath: String)
    case invalidSpaceKitVersion(manifestPath: String, versionFound: String)
    case targetNotFound(manifestPath: String, target: String)
    
    var description: String {
        switch self {
        case .cannotReadManifest(let path):
            """
            Cannot read the Package.swift at \(path).
            Check that the file exists and is well-formed.
            """
        case .spaceKitDependencyNotFound(let manifestPath):
            """
            The manifest \(manifestPath) doesn't contain the SpaceKit dependency.
            """
        case .cannotReadDependencyRequirement(let manifestPath, let dependency):
            """
            Cannot read the requirements for the following dependency: \(dependency) in \(manifestPath).
            Please make sure it has requirements, such as the version number.
            """
        case .spaceKitDependencyShouldBeAGitRepository(let manifestPath):
            """
            The dependency "SpaceKit" in \(manifestPath) should be a Git repository, local or remote.
            """
        case .spaceKitDependencyShouldHaveExactVersion(let manifestPath):
            """
            The dependency "SpaceKit" in \(manifestPath) should has be specified by it's exact version.
            """
        case .invalidSpaceKitVersion(let manifestPath, let versionFound):
            """
            Invalid version found for the SpaceKit dependency in \(manifestPath).
            
            Version found: \(versionFound)
            """
        case .targetNotFound(let manifestPath, let target):
            """
            Target \(target) not found in \(manifestPath).
            """
        }
    }
}
