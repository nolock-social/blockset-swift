protocol ScanState {
    associatedtype Input
    associatedtype Output
    init()
    mutating func push(_ value: Input)
    mutating func pop() -> Output?
    mutating func last() -> Output?
}

struct ScanIterator<S: ScanState, I: IteratorProtocol>: IteratorProtocol where I.Element == S.Input {
    // private:
    private var state: S = S()
    private var iterator: I
    // public:
    init(_ iterator: I) {
        self.iterator = iterator
    }
    mutating func next() -> S.Output? {
        if let value = self.state.pop() {
            return value
        }
        while let value = self.iterator.next() {
            self.state.push(value)
            if let value = self.state.pop() {
                return value
            }
        }
        return self.state.last()
    }
}

struct ScanSequence<S: ScanState, Base: Sequence>: Sequence where Base.Element == S.Input {
    // private:
    private let base: Base
    // public:
    init(_ base: Base) {
        self.base = base
    }
    func makeIterator() -> ScanIterator<S, Base.Iterator> {
        ScanIterator(base.makeIterator())
    }
}
