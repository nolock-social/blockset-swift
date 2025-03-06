import Foundation
import Crypto

struct FileCas: Cas {
    private var blocks: [String: Data] = [:]

    func add(_ block: Data) -> String? {
        let id = block.sha256().base32()
        blocks[id] = block
        return id
    }

    func get(_ id: String) -> Data? {
        blocks[id]
    }
}
