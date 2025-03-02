import Foundation

public struct PackageDependency: Decodable {
    public enum Kind: Decodable {
        case sourceControl([SourceControl])
        case fileSystem([FileSystem])
        case unknown

        private enum CodingKeys: String, CodingKey {
            case sourceControl
            case fileSystem
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let sourceControl = try? container.decode([SourceControl].self, forKey: .sourceControl) {
                self = .sourceControl(sourceControl)
            } else if let fileSystem = try? container.decode([FileSystem].self, forKey: .fileSystem) {
                self = .fileSystem(fileSystem)
            } else {
                self = .unknown
            }
        }
    }

    public struct SourceControl: Decodable {
        public let identity: String
        public let location: Location
        public let productFilter: String?
        public let requirement: Requirement
    }

    public struct FileSystem: Decodable {
        public let identity: String
        public let path: String
    }

    public enum Requirement: Decodable {
        case range([Range])
        case exact([String])
        case unknown

        private enum CodingKeys: String, CodingKey {
            case range
            case exact
        }

        public struct Range: Decodable {
            let lowerBound: String
            let upperBound: String
        }

        public init(from decoder: Decoder) throws {
            let container = try? decoder.container(keyedBy: CodingKeys.self)

            if let container = container {
                if let range = try? container.decode([Range].self, forKey: .range) {
                    self = .range(range)
                    return
                } else if let exact = try? container.decode([String].self, forKey: .exact) {
                    self = .exact(exact)
                    return
                }
            }

            self = .unknown
        }
    }

    public enum Location: Decodable {
        case remote([Remote])
        case local([String])
        case unknown

        private enum CodingKeys: String, CodingKey {
            case remote
            case local
        }

        public struct Remote: Decodable {
            public let urlString: String
        }

        public init(from decoder: Decoder) throws {
            let container = try? decoder.container(keyedBy: CodingKeys.self)

            if let container = container {
                if let remote = try? container.decode([Remote].self, forKey: .remote) {
                    self = .remote(remote)
                    return
                } else if let local = try? container.decode([String].self, forKey: .local) {
                    self = .local(local)
                    return
                }
            }

            self = .unknown
        }
    }

    public let kind: Kind

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.kind = (try? container.decode(Kind.self)) ?? .unknown
    }
}
