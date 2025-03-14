public class Model<T> {
    // internal:
    var mutable: Mutable
    init(value: T, mutable: Mutable) {
        self.value = value
        self.mutable = mutable
    }
    // public:
    public var value: T
    public static func initial(value: T) -> Model {
        Model(value: value, mutable: Mutable.initial())
    }
}

extension Cas {
    func saveJsonModel<T: Encodable>(model: Model<T>) throws -> String? {
        try saveJson(model.mutable, model.value)
    }
    func loadJsonModel<T: Decodable>(mutable: Mutable) throws -> Model<T>? {
        guard let value: T = try loadJson(mutable) else {
            return nil
        }
        return Model(value: value, mutable: mutable)
    }
}
