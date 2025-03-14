struct ModelStruct<T: Hashable>: Hashable {
    var mutable: Mutable
    var value: T
}

public class Model<T: Hashable>: Hashable {
    // internal:
    var s: ModelStruct<T>
    init(_ s: ModelStruct<T>) {
        self.s = s
    }
    // public:
    public static func initial(_ value: T) -> Model {
        Model(ModelStruct(mutable: Mutable.initial(), value: value))
    }
    public func hash(into hasher: inout Hasher) {
        self.s.hash(into: &hasher)
    }
    public static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.s == rhs.s
    }
    public var value: T {
        get { s.value }
        set { s.value = newValue }
    }
}

extension Cas {
    @discardableResult
    public func saveJsonModel<T: Encodable>(_ model: Model<T>) throws -> String? {
        try saveJson(model.s.mutable, model.s.value)
    }
    public func loadJsonModel<T: Decodable>(_ mutable: Mutable) throws -> Model<T>? {
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
