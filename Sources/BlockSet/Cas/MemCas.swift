import Foundation
import Crypto

//MARK: - Sync MemCas
public class MemCas: Cas {
    private var blocks: [String: Data] = [:]

    public init() {}

    public func id(_ data: Data) -> String {
        data.sha256Id()
    }

    public func add(_ data: Data) -> String {
        let id = id(data)
        blocks[id] = data
        return id
    }

    public func get(_ id: String) -> Data? {
        blocks[id]
    }

    public func list() -> [String] {
        self.blocks.keys.map { $0 }
    }
}