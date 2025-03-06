import Foundation
import Crypto

struct FileCas: Cas {
    private let dir: String

    private func path(_ id: String) -> URL {
        URL(string: dir)!.appendingPathComponent(id)
    }

    init(dir: String) {
        self.dir = dir
    }

    mutating func add(_ data: Data) -> String? {
        let id = SHA256.hash(data: data).base32()
        let path = self.path(id)
        return id
    }

    func get(_ id: String) -> Data? {
        path(id)
        fatalError("not implemented")
    }
}
