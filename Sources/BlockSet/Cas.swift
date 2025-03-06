import Foundation
import Crypto

protocol Cas {
    func add(_ block: Data) -> String?
    func get(_ id: String) -> Data?
}
