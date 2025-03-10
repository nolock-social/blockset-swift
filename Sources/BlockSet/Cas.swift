import Foundation
import Crypto

public protocol Cas {
    func id(_ data: Data) -> String
    mutating func add(_ data: Data) throws -> String
    func get(_ id: String) throws -> Data?
    func list() throws -> AnySequence<String>
}

func sha256Id(_ data: Data) -> String {
    SHA256.hash(data: data).base32()
}