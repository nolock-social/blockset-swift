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
    func list() throws -> AnySequence<String>
}

func sha256Id(_ data: Data) -> String {
    SHA256.hash(data: data).base32()
}

struct CasWithSet {
    let cas: Cas
    let set: Set<String>
    func fetchFrom(_ b: CasWithSet) throws {
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
    func withSet() throws -> CasWithSet {
        CasWithSet(cas: self, set: Set(try list()))
    }
    public func sync(_ cas: Cas) throws {
        let a = try self.withSet()
        let b = try cas.withSet()
        try a.fetchFrom(b)
        try b.fetchFrom(a)
    }
}
