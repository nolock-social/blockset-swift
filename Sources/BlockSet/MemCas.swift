import Foundation
import Crypto

public struct MemCas: Cas {
    private var blocks: [String: Data] = [:]

    public init() {}

    public mutating func add(_ data: Data) -> String? {
        let id = SHA256.hash(data: data).base32()
        blocks[id] = data
        return id
    }

    public func get(_ id: String) -> Data? {
        blocks[id]
    }

    public func list() -> AnySequence<String> {
        AnySequence(self.blocks.keys)
    }
}
