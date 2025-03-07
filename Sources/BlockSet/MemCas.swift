import Foundation

#if canImport(Crypto)
import Crypto
#endif

public struct MemCas: Cas {
    private var blocks: [String: Data] = [:]

    mutating func add(_ data: Data) -> String? {
        let id = SHA256.hash(data: data).base32()
        blocks[id] = data
        return id
    }

    func get(_ id: String) -> Data? {
        blocks[id]
    }

    func list() -> AnySequence<String> {
        AnySequence(self.blocks.keys)
    }
}
