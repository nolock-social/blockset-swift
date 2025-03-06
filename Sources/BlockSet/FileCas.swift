import Foundation
import Crypto

struct FileCas: Cas {
    private var blocks: [String: Data] = [:]

    mutating func add(_ block: Data) -> String? {
        let id = SHA256.hash(data: block).base32()
        blocks[id] = block
        return id
    }

    func get(_ id: String) -> Data? {
        blocks[id]
    }
}
