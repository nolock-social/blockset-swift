import Crypto
import Foundation

public struct FileCas: Cas {

    // private:

    private let dir: URL

    private func path(_ id: String) -> URL {
        dir.appendingPathComponent(id)
    }

    // public:

    public init(_ dir: URL) {
        self.dir = dir
    }

    public mutating func add(_ data: Data) throws -> String {
        let id = SHA256.hash(data: data).base32()
        try data.write(to: path(id))
        return id
    }

    public func get(_ id: String) -> Data? {
        // TODO: check errors. if the file doesn't exist, return nil
        // otherwise, throw the error
        path(id) |> { try? Data(contentsOf: $0) }
    }

    public func list() throws -> AnySequence<String> {
        try FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil
        )
        .map { $0.lastPathComponent }
        |> AnySequence.init
    }
}
