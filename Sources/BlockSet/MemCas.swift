import Foundation
import Crypto

public struct MemCas: Cas {
    private var blocks: [String: Data] = [:]

    public init() {}

    public func id(_ data: Data) -> String {
        sha256Id(data)
    }

    public mutating func add(_ data: Data) -> String {
        let id = id(data)
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
