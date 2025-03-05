protocol ScanState {
    associatedtype Input
    associatedtype Output
    mutating func push(_ value: Input)
    mutating func pop() -> Output?
    mutating func last() -> Output?
}

struct ScanIterator<S: ScanState, I: IteratorProtocol>: IteratorProtocol where I.Element == S.Input {
    // private:
    private var state: S
    private var iterator: I
    // public:
    init(_ state: S, _ iterator: I) {
        self.state = state
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

struct ScanSequence<F: Factory, B: Sequence>: Sequence where B.Element == F.Element.Input, F.Element: ScanState {
    // private:
    private let factory: F
    private let base: B
    // public:
    init(_ factory: F, _ base: B) {
        self.factory = factory
        self.base = base
    }
    func makeIterator() -> ScanIterator<F.Element, B.Iterator> {
        ScanIterator(factory(), base.makeIterator())
    }
}
