import Foundation
import Crypto

public protocol Cas: AnyObject {
    /// Returns identifier (hash) for the given data block.
    func id(_ data: Data) -> String

    /// Add the given data block to the CAS and returns the data identifier.
    @discardableResult
    func add(_ data: Data) throws -> String

    func get(_ id: String) throws -> Data?

    /// Returns a list of all identifiers.
    func list() throws -> [String]
}

extension Data {
    func sha256Id() -> String {
        SHA256.hash(data: self).base32()
    }

    func sha256Id() async -> String {
        SHA256.hash(data: self).base32()
    }
}

private struct CasWithSet {
    let cas: Cas
    let set: Set<String>
    nonisolated func fetchFrom(_ b: CasWithSet) throws {
        let diff = b.set.subtracting(set)
        for id in diff {
            guard let data = try b.cas.get(id) else {
                continue
            }
            try self.cas.add(data)
        }
    }
}

extension Cas {
    private func withSet() throws -> CasWithSet {
        CasWithSet(cas: self, set: Set(try list()))
    }
    /// Synchronizes two CASes.
    public func sync(_ cas: Cas) throws {
        let a = try self.withSet()
        let b = try cas.withSet()
        try a.fetchFrom(b)
        try b.fetchFrom(a)
    }

    @discardableResult
    public func saveData(_ mutable: Mutable, _ data: Data?) throws -> String? {
        var blobId: String?
        if let data {
            blobId = try self.add(data)
        }
        let parent = mutable.parent
        // nothing new
        guard blobId != parent?.blobId else {
            return nil
        }
        let commit = Commit(
            parent: parent.map { [$0.commitId] } ?? [],
            blob: blobId)
        let commitId = try self.add(
            JSONEncoder().encode(commit))
        mutable.parent = Parent(commitId: commitId, blobId: blobId)
        return commitId
    }

    public func loadData(_ mutable: Mutable) throws -> Data? {
        guard let blobId = mutable.parent?.blobId else {
            return nil
        }
        return try get(blobId)
    }

    @discardableResult
    public func delete(_ mutable: Mutable) throws -> String? {
        try saveData(mutable, nil)
    }

    @discardableResult
    public func saveJson<T: Encodable>(_ mutable: Mutable, _ value: T?) throws -> String? {
        var data: Data?
        if let value = value {
        let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            data = try encoder.encode(value)
        }
        return try saveData(mutable, data)
    }

    public func loadJson<T: Decodable>(_ mutable: Mutable) throws -> T? {
        guard let data = try loadData(mutable) else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func loadCommit(_ commitId: String) throws -> Commit? {
        guard
            let commitData = try self.get(commitId)
        else {
            return nil
        }
        return try? JSONDecoder().decode(Commit.self, from: commitData)
    }

    public func listMutable() throws -> [Mutable] {
        var parents: Set<String> = []
        var result: [String: Commit] = [:]
        for id in try self.list() {
            guard let commit: Commit = try self.loadCommit(id) else { continue }
            // remove and tag parent commits
            for p in commit.parent {
                result[p] = nil
                parents.insert(p)
            }
            if !parents.contains(id) {
                result[id] = commit
            }
        }
        return result.map { Mutable(Parent(commitId: $0.key, blobId: $0.value.blob)) }
    }

    @discardableResult
    public func saveJsonModel<T: Encodable>(_ model: Model<T>) throws -> String? {
        try saveJson(model.s.mutable, model.s.value)
    }

    public func loadJsonModel<T: Decodable>(_ mutable: Mutable) throws -> Model<T>? {
        guard let value: T = try loadJson(mutable) else {
            return nil
        }
        return Model(ModelStruct(mutable: mutable, value: value))
    }
    
    @discardableResult
    public func deleteModel<T>(_ model: Model<T>) throws -> String? {
        try delete(model.s.mutable)
    }
}
