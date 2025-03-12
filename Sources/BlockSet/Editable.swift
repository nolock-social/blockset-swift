import Foundation

struct Revision<T: Codable>: Codable {
    var previous: [String]
    var value: T?
}

public class Editable<T: Codable> {
    // private:
    // internal:
    init(value: T?, previous: [String]) {
        self.value = value
        self.previous = previous
    }
    // public:
    public internal(set) var previous: [String]
    public var value: T?
}

extension Encodable where Self: Codable {
    public func editable() -> Editable<Self> {
        Editable(value: self, previous: [])
    }
}

extension Cas {
    public mutating func save<T: Codable>(_ e: inout Editable<T>) throws -> String {
        let revision = Revision(previous: e.previous, value: e.value)
        let data = try JSONEncoder().encode(revision)
        let id = try self.add(data)
        e.previous = [id]
        return id
    }
    public func load<T: Codable>(_ id: String) throws -> Editable<T>? {
        let data = try self.get(id)
        guard let data else {
            return nil
        }
        let revision = try JSONDecoder().decode(Revision<T>.self, from: data)
        return Editable(value: revision.value, previous: revision.previous)
    }
}
