public class Model<T> {
    // internal:
    var mutable: Mutable
    init(value: T, mutable: Mutable) {
        self.value = value
        self.mutable = mutable
    }
    // public:
    public var value: T
    public static func initial(_ value: T) -> Model {
        Model(value: value, mutable: Mutable.initial())
    }
}

extension Cas {
    @discardableResult
    public func saveJsonModel<T: Encodable>(_ model: Model<T>) throws -> String? {
        try saveJson(model.mutable, model.value)
    }
    public func loadJsonModel<T: Decodable>(_ mutable: Mutable) throws -> Model<T>? {
        guard let value: T = try loadJson(mutable) else {
            return nil
        }
        return Model(value: value, mutable: mutable)
    }
    @discardableResult
    public func deleteModel<T>(_ model: Model<T>) throws -> String? {
        try delete(model.mutable)
    }
}
