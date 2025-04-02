struct ModelStruct<T> {
    var mutable: Mutable
    var value: T
}

public class Model<T: Codable>: Hashable, Codable {
    var s: ModelStruct<T>

    init(_ s: ModelStruct<T>) {
        self.s = s
    }

    public static func initial(_ value: T) -> Model {
        Model(ModelStruct(mutable: Mutable.initial(), value: value))
    }

    public var value: T {
        get { s.value }
        set { s.value = newValue }
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedValue = try container.decode(T.self, forKey: .value)
        self.s = ModelStruct(mutable: Mutable.initial(), value: decodedValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(s.value, forKey: .value)
    }

    // MARK: - Hashable
    public static func == (lhs: Model, rhs: Model) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Cas {
    @discardableResult
    public func saveJsonModel<T: Codable>(_ model: Model<T>) throws -> String? {
        try saveJson(model.s.mutable, model.s.value)
    }
    public func loadJsonModel<T: Codable>(_ mutable: Mutable) throws -> Model<T>? {
        guard let value: T = try loadJson(mutable) else {
            return nil
        }
        return Model(ModelStruct(mutable: mutable, value: value))
    }
    @discardableResult
    public func deleteModel<T>(_ model: Model<T>) throws -> String? {
        try delete(model.s.mutable)
    }
}
