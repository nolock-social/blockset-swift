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

    @discardableResult
    public func save<T: Codable>(_ e: Editable<T>) throws -> String {
        let revision = Revision(previous: e.previous, value: e.value)
        let data = try JSONEncoder().encode(revision)
        let id = try self.add(data)
        e.previous = [id]
        return id
    }

    public func load<T: Codable>(_ id: String) throws -> Editable<T>? {
        guard let data = try self.get(id) else {
            return nil
        }
        // make sure that the block can be converted into `Revision<T>`.
        guard let revision = try? JSONDecoder().decode(Revision<T>.self, from: data) else {
            return nil
        }
        return Editable(value: revision.value, previous: revision.previous)
    }

    public func loadAll<T: Codable>() throws -> Array<Editable<T>> {
        var old: Set<String> = []
        var map: [String: Editable<T>] = [:]
        for id in try self.list() {
            guard let editable: Editable<T> = try self.load(id) else { continue }
            // remove previous
            for p in editable.previous {
                map[p] = nil
                old.insert(p)
            }
            if !old.contains(id) {
                map[id] = editable
            }
        }
        return Array(map.values)
    }
}
