import Foundation

public protocol AsyncableCas: Actor {
    /// Return hash for any data
    func hash(for data: Data) async -> String

    /// Add any type of data inside cas
    @discardableResult
    func store(_ data: Data) async throws -> String

    /// Use hash for getting any data from cas
    func retrieve(_ hash: String) async throws -> Data?

    /// Lists all stored identifiers.
    func allIdentifiers() async throws -> [String]
}

extension AsyncableCas {
    //MARK: - Save

    /// Saves an encodable value as JSON into CAS.
    @discardableResult
    public func saveJSON<T: Encodable>(_ mutable: Mutable, _ value: T?) async throws -> String? {
        var data: Data?

        let encoder = JSONEncoder()

        if let value = value {
            encoder.outputFormatting = .sortedKeys
            data = try encoder.encode(value)
        }

        return try await saveData(mutable, data)
    }

    //MARK: - Save JSON Model

    /// Saves a model and its associated value as JSON into CAS.
    @discardableResult
    public func saveJSONModel<T: Encodable>(_ model: Model<T>) async throws -> String? {
        try await saveJSON(model.s.mutable, model.s.value)
    }

    //MARK: - Save Data

    /// Saves raw binary data into CAS.
    private func saveData(_ mutable: Mutable, _ data: Data?) async throws -> String? {
        var blobId: String?

        if let data {
            blobId = try await self.store(data)
        }

        let parent = mutable.parent

        guard blobId != parent?.blobId else {
            return nil
        }

        let commit = Commit(
            parent: parent.map { [$0.commitId] } ?? [],
            blob: blobId
        )

        let encoder = JSONEncoder()

        let commitId = try await self.store(encoder.encode(commit))
        mutable.parent = Parent(commitId: commitId, blobId: blobId)

        return commitId
    }

    //MARK: - Load data

    /// Loads raw data for the given mutable reference.
    public func loadData(_ mutable: Mutable) async throws -> Data? {
        guard let blobId = mutable.parent?.blobId else {
            return nil
        }

        return try await retrieve(blobId)
    }

    // MARK: - Load JSON

    /// Loads and decodes a JSON value for the given mutable reference.
    public func loadJSON<T: Decodable>(_ mutable: Mutable) async throws -> T? {
        guard let data = try await loadData(mutable) else {
            return nil
        }

        let decoder = JSONDecoder()

        return try decoder.decode(T.self, from: data)
    }

    //MARK: - Laod JSON Model

    /// Loads and decodes a JSON-encoded model for the given mutable reference.
    public func loadJSONModel<T: Decodable>(_ mutable: Mutable) async throws -> Model<T>? {
        guard let value: T = try await loadJSON(mutable) else {
            return nil
        }
        return Model(ModelStruct(mutable: mutable, value: value))
    }

    //TODO: - Add deleting for any data just with HASH
    //MARK: - Delete mutable

    /// Creates a record in CAS indicating that the given mutable reference was deleted.
    @discardableResult
    public func deleteMutable(_ mutable: Mutable) async throws -> String? {
        try await saveData(mutable, nil)
    }

    //MARK: - Delete model

    /// Deletes the given model by creating a deletion record in CAS.
    @discardableResult
    public func deleteModel<T>(_ model: Model<T>) async throws -> String? {
        try await saveData(model.s.mutable, nil)
    }

    //MARK: - Load deleted JSONModel

    public func loadDeletedJSONModel<T: Decodable>(_ mutable: Mutable) async throws -> Model<T>? {
        guard let value: T = try await loadDeletedJSON(mutable) else {
            return nil
        }
        return Model(ModelStruct(mutable: mutable, value: value))
    }

    //MARK: - Load deleted JSON

    public func loadDeletedJSON<T: Decodable>(_ mutable: Mutable) async throws -> T? {
        guard let mutableParent = mutable.parent, mutableParent.blobId == nil else {
            return nil
        }

        let commitId = mutableParent.commitId

        let decoder = JSONDecoder()

        if let commit = try await loadCommit(commitId), let parentCommit = commit.parent.first {
            if let commit = try await loadCommit(parentCommit), let blob = commit.blob, let data = try await self.retrieve(blob) {
                return try decoder.decode(T.self, from: data)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    // MARK: - Commits

    /// Loads a commit by its identifier.
    func loadCommit(_ commitId: String) async throws -> Commit? {
        guard let commitData = try await self.retrieve(commitId) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(Commit.self, from: commitData)
    }

    // MARK: - Lists for mutables

    /// Returns a list of all mutable references.
    public func listOfAllMutables() async throws -> [Mutable] {
        let ids = try await self.allIdentifiers()

        var parents: Set<String> = []
        var result: [String: Commit] = [:]

        return try await withThrowingTaskGroup(of: (String, Commit?).self) { group in
            for id in ids {
                group.addTask {
                    (id, try await self.loadCommit(id))
                }
            }

            for try await (id, commit) in group {
                guard let commit else { continue }

                for p in commit.parent {
                    result.removeValue(forKey: p)
                    parents.insert(p)
                }

                if !parents.contains(id) {
                    result[id] = commit
                }
            }

            return result.map { Mutable(Parent(commitId: $0.key, blobId: $0.value.blob)) }
        }
    }

    /// Returns only active mutables.
    public func listOfActiveMutables() async throws -> [Mutable] {
        let ids = try await self.allIdentifiers()

        var parents = Set<String>()
        var result: [String: Commit] = [:]

        return try await withThrowingTaskGroup(of: (String, Commit?).self) { group in
            for id in ids {
                group.addTask {
                    (id, try await self.loadCommit(id))
                }
            }

            for try await (id, commit) in group {
                guard let commit else { continue }

                for p in commit.parent {
                    parents.insert(p)
                    result.removeValue(forKey: p)
                }

                guard commit.blob != nil else {
                    continue
                }

                if !parents.contains(id) {
                    result[id] = commit
                }
            }

            return result.map { Mutable(Parent(commitId: $0.key, blobId: $0.value.blob)) }
        }
    }


    /// Returns only deleted mutables.
  public func listOfDeletedMutables() async throws -> [Mutable] {
    let ids = try await self.allIdentifiers()
    var parents: Set<String> = []
    var commits: [String: Commit] = [:]

    return try await withThrowingTaskGroup(of: (String, Commit?).self) { group in
        for id in ids {
            group.addTask {
                (id, try await self.loadCommit(id))
            }
        }

        for try await (id, commit) in group {
            guard let commit else { continue }
            commits[id] = commit

            for p in commit.parent {
                parents.insert(p)
            }
        }

        let result = commits.filter { id, commit in
            commit.blob == nil && !parents.contains(id)
        }

        return result.map { Mutable(Parent(commitId: $0.key, blobId: $0.value.blob)) }
    }
}
}
