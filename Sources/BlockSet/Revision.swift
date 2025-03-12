import Foundation

struct Revision<T: Codable>: Codable {
    var previous: [String]
    var current: T?
}

public class Editable<T: Codable> {
    // private:
    // internal:
    init(model: T?, previous: [String]) {
        self.model = model
        self.previous = previous
    }
    // public:
    public internal(set) var previous: [String]
    public var model: T?
}

extension Encodable where Self: Codable {
    public func editable() -> Editable<Self> {
        Editable(model: self, previous: [])
    }
}

extension Cas {
    public mutating func save<T: Codable>(_ e: inout Editable<T>) throws -> String {
        let revision = Revision(previous: e.previous, current: e.model)
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
        return Editable(model: revision.current, previous: revision.previous)
    }
}
