import Crypto
import Foundation

import Foundation

public actor FileCas: AsyncableCasProtocol, Cas {
    // private:
    private let dir: URL

    // public:
    public init(_ dir: URL) {
        self.dir = dir
    }

    //MARK: - Non Asyncable Cas
    nonisolated public func id(_ data: Data) -> String {
        data.sha256Id()
    }

    nonisolated public func add(_ data: Data) throws -> String {
        let id = id(data)
        let path = path(id)

        try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: path)

        return id
    }

    nonisolated public func get(_ id: String) -> Data? {
        // TODO: check errors. if the file doesn't exist, return nil
        // otherwise, throw the error
        try? Data(contentsOf: path(id))
    }

    nonisolated public func list() throws -> [String] {
        try dir.list()
    }

    nonisolated public func path(_ hash: String) -> URL {
        let (a, bc) = hash[...].split2()
        let (b, c) = bc.split2()
        return dir.appending(a, true).appending(b, true).appending(c, false)
    }

    //MARK: - Asyncable CAS

    public func hash(for data: Data) async -> String {
        await data.sha256Id()
    }

    public func store(_ data: Data) async throws -> String {
        let id = await hash(for: data)
        let path = try await fileURL(forHash: id)

        try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: path)

        return id
    }

    public func retrieve(_ hash: String) async throws -> Data? {
        try? Data(contentsOf: try await fileURL(forHash: hash))
    }

    public func allIdentifiers() async throws -> [String] {
        try await dir.asyncList()
    }

    public func fileURL(forHash hash: String) async throws -> URL {
        let (a, bc) = hash[...].split2()
        let (b, c) = bc.split2()
        return dir.appending(a, true).appending(b, true).appending(c, false)
    }
}

