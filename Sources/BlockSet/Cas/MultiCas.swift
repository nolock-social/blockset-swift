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
