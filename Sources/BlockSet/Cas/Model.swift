struct ModelStruct<T> {
    var mutable: Mutable
    var value: T
}

//MARK: - Sync model

public class Model<T>: Hashable, @unchecked Sendable {
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

//MARK: - Async, Sendable model

struct AsyncModelStruct<T: Sendable>: Sendable {
    var mutable: AsyncMutable
    var value: T
}

public actor AsyncModel<T: Sendable>: Hashable, Sendable {
    // internal:
    var s: AsyncModelStruct<T>

    init(_ s: AsyncModelStruct<T>) {
        self.s = s
    }
    // public:
    public static func initial(_ value: T) -> AsyncModel {
        AsyncModel(AsyncModelStruct(mutable: AsyncMutable.initial(), value: value))
    }
    public var value: T {
        get { s.value }
        set { s.value = newValue }
    }

    // Hashable:

    public static func == (lhs: AsyncModel, rhs: AsyncModel) -> Bool {
        return lhs === rhs
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}