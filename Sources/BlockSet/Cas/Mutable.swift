import Foundation

struct Commit: Codable {
    var parent: [String]
    var blob: String?
}

struct Parent {
    var commitId: String
    var blobId: String?
}

//MARK: - SyncMutable

public class Mutable: Hashable, @unchecked Sendable {
    var parent: Parent?
    // internal:
    init(_ parent: Parent?) {
        self.parent = parent
    }
    // public:
    public static func initial() -> Mutable {
        Mutable(nil)
    }
    // Hashable:
    public static func == (lhs: Mutable, rhs: Mutable) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}


//MARK: - AsyncMutable
public actor AsyncMutable: Hashable {
    var parent: Parent?
    // internal:
    init(_ parent: Parent?) {
        self.parent = parent
    }
    // public:
    public static func initial() -> AsyncMutable {
        AsyncMutable(nil)
    }
    // Hashable:
    public static func == (lhs: AsyncMutable, rhs: AsyncMutable) -> Bool {
        return lhs === rhs
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}