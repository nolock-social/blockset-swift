import Crypto
import Foundation

public class FileCas: Cas {

    // private:

    private let dir: URL

    private func path(_ id: String) -> URL {
        dir.appendingPathComponent(id)
    }

    // public:

    public init(_ dir: URL) {
        self.dir = dir
    }

    public func id(_ data: Data) -> String {
        data.sha256Id()
    }

    public func add(_ data: Data) throws -> String {
        let id = id(data)
        try data.write(to: path(id))
        return id
    }

    public func get(_ id: String) -> Data? {
        // TODO: check errors. if the file doesn't exist, return nil
        // otherwise, throw the error
        try? Data(contentsOf: path(id))
    }

    public func list() throws -> AnySequence<String> {
        let result = try FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil
        )
        .map { $0.lastPathComponent }
        return AnySequence(result)
    }
}
