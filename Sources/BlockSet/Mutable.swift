import Foundation

struct Commit: Codable {
    var parent: [String]
    var blob: String?
}

struct Parent: Hashable {
    var commitId: String
    var blobId: String?
}

public class Mutable: Hashable {
    var parent: Parent?
    // internal:
    init(_ parent: Parent?) {
        self.parent = parent
    }
    // public:
    public static func initial() -> Mutable {
        Mutable(nil)
    }
    public func hash(into hasher: inout Hasher) {
        self.parent.hash(into: &hasher)
    }
    public static func == (lhs: Mutable, rhs: Mutable) -> Bool {
        lhs.parent == rhs.parent
    }
}

extension Cas {

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
            data = try JSONEncoder().encode(value)
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
}
