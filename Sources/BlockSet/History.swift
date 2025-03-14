import Foundation

struct Revision<T: Codable & Hashable>: Codable & Hashable & Equatable {
    var previous: [String]
    var value: T?
}

public class History<T: Codable & Hashable>: Hashable {
    public func hash(into hasher: inout Hasher) {
        revision.hash(into: &hasher)
    }
    public static func == (lhs: History, rhs: History) -> Bool {
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
    public func newHistory() -> History<Self> {
        History(value: self, previous: [])
    }
}

extension Cas {

    @discardableResult
    public func save<T: Codable>(_ e: History<T>) throws -> String {
        let data = try JSONEncoder().encode(e.revision)
        let id = try self.add(data)
        e.revision.previous = [id]
        return id
    }

    public func load<T: Codable>(_ id: String) throws -> History<T>? {
        guard let data = try self.get(id) else {
            return nil
        }
        // make sure that the block can be converted into `Revision<T>`.
        guard let revision = try? JSONDecoder().decode(Revision<T>.self, from: data) else {
            return nil
        }
        return History(value: revision.value, previous: revision.previous)
    }

    public func loadAll<T: Codable>() throws -> [History<T>] {
        var outdated: Set<String> = []
        var result: [String: History<T>] = [:]
        for id in try self.list() {
            guard let editable: History<T> = try self.load(id) else { continue }
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
