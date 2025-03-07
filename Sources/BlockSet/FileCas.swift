import Foundation
import Crypto

public struct FileCas: Cas {

    // private:

    private let dir: URL

    private func path(_ id: String) -> URL {
        dir.appendingPathComponent(id)
    }

    // public:

    public init(dir: String) {
        self.dir = URL(fileURLWithPath: dir)
    }

    public mutating func add(_ data: Data) -> String? {
        let id = SHA256.hash(data: data).base32()
        let path = self.path(id)
        try! data.write(to: path)
        return id
    }

    public func get(_ id: String) -> Data? {
        let path = self.path(id)
        return try? Data(contentsOf: path)
    }

    public func list() -> AnySequence<String> {
        let x = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            .map { $0.lastPathComponent }
        return AnySequence(x ?? [])
    }
}
