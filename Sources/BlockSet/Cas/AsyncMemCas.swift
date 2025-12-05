import Foundation

//MARK: - Async MemCas

public actor AsyncMemCas: AsyncableCas {

    private var blocks: [String: Data] = [:]

    public func hash(for data: Data) async -> String {
        await data.sha256Id()
    }

    public func store(_ data: Data) async throws -> String {
        let id = await hash(for: data)

        blocks[id] = data

        return id
    }

    public func retrieve(_ hash: String) async throws -> Data? {
        blocks[hash]
    }

    public func allIdentifiers() async throws -> [String] {
        self.blocks.keys.map { $0 }
    }
}