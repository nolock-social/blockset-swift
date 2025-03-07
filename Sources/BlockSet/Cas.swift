import Foundation
import Crypto

public protocol Cas {
    mutating func add(_ data: Data) throws -> String
    func get(_ id: String) -> Data?
    func list() -> AnySequence<String>
}
