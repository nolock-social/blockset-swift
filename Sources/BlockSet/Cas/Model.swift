struct ModelStruct<T> {
    var mutable: Mutable
    var value: T
}

public class Model<T>: Hashable {
    // internal:
    var s: ModelStruct<T>
    init(_ s: ModelStruct<T>) {
        self.s = s
    }
    // public:
    public static func initial(_ value: T) -> Model {
        Model(ModelStruct(mutable: Mutable.initial(), value: value))
    }
    public var value: T {
        get { s.value }
        set { s.value = newValue }
    }

    // Hashable:

    public static func == (lhs: Model, rhs: Model) -> Bool {
        return lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
