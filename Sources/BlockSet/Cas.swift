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
