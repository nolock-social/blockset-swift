import Foundation

public class MultiCas: Cas {
    private var local: Cas
    private var remote: Cas

    public init(local: Cas, remote: Cas) {
        self.local = local
        self.remote = remote
    }

    public func id(_ data: Data) -> String {
        local.id(data)
    }

    public func add(_ data: Data) throws -> String {
        let id = try local.add(data)
        do {
            try remote.add(data)
        } catch {
        }
        return id
    }

    public func get(_ id: String) throws -> Data? {
        if let data = try local.get(id) {
            return data
        }
        do {
            if let data = try remote.get(id) {
                try local.add(data)
                return data
            }
        } catch {
        }
        return nil
    }

    public func list() throws -> [String] {
        try local.list()
    }

    public func syncRemote() throws {
        try local.sync(remote)
    }
}


public actor AsyncMultiCas: AsyncableCas {
    private var local: AsyncableCas
    private var remote: AsyncableCas

    public init(local: AsyncableCas, remote: AsyncableCas) {
        self.local = local
        self.remote = remote
    }

    public func hash(for data: Data) async -> String {
        await local.hash(for: data)
    }

    // public func id(_ data: Data) -> String {
    //     local.id(data)
    // }

    public func store(_ data: Data) async throws -> String {
        let hash = try  await local.store(data)
        do {
            try await remote.store(data)
        } catch {

        }

        return hash
    }

    public func retrieve(_ hash: String) async throws -> Data? {
        guard let data = try await local.retrieve(hash) else {
            if let data = try await remote.retrieve(hash) {
                try await local.store(data)
                return data
            } else {
                return nil
            }
        }

        return data
    }

    public func allIdentifiers() async throws -> [String] {
        try await local.allIdentifiers()
    }

    public func syncRemote() throws {
        // try local.sync(remote)
    }
}