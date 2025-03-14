import Foundation

struct Revision<T: Codable & Hashable>: Codable & Hashable & Equatable {
    var previous: [String]
    var value: T?
}

public class Editable<T: Codable & Hashable>: Hashable {
    public func hash(into hasher: inout Hasher) {
        revision.hash(into: &hasher)
    }
    public static func == (lhs: Editable, rhs: Editable) -> Bool {
        lhs.revision == rhs.revision
    }

    // private:
    var revision: Revision<T>

    // internal:
    init(value: T?, previous: [String]) {
        self.revision = Revision(previous: previous, value: value)
    }

    // public:
    public var value: T? {
        get { revision.value }
        set { revision.value = newValue }
    }
    public var previous: [String] { revision.previous }

}

extension Encodable where Self: Codable & Hashable {
    public func revision0() -> Editable<Self> {
        Editable(value: self, previous: [])
    }
}

extension Cas {

    @discardableResult
    public func save<T: Codable>(_ e: Editable<T>) throws -> String {
        let data = try JSONEncoder().encode(e.revision)
        let id = try self.add(data)
        e.revision.previous = [id]
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

    public func loadAll<T: Codable>() throws -> [Editable<T>] {
        var outdated: Set<String> = []
        var result: [String: Editable<T>] = [:]
        for id in try self.list() {
            guard let editable: Editable<T> = try self.load(id) else { continue }
            // remove and tag previous revisions
            for p in editable.revision.previous {
                result[p] = nil
                outdated.insert(p)
            }
            if !outdated.contains(id) {
                result[id] = editable
            }
        }
        return Array(result.values)
    }
}
