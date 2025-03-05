extension UInt8 {
    // https://en.wikipedia.org/wiki/Base32#Crockford's_Base32
    private static let u5ToChar: [Character] = Array("0123456789abcdefghjkmnpqrstvwxyz")
    func base32() -> Character {
        Self.u5ToChar[Int(self)]
    }
}

extension Character {
    private static let charToU5: [Character: UInt8] = {
        var mapping = [Character: UInt8]()
        for i in UInt8(0)..<32 {
            mapping[i.base32()] = i
        }
        return mapping
    }()
    func fromBase32() -> UInt8 {
        Self.charToU5[self]!
    }
}

protocol BitSplitState {
    static var inputBits: UInt8 { get }
    static var outputBits: UInt8 { get }
}

protocol ScanState {
    associatedtype Input
    associatedtype Output
    init()
    mutating func push(_ value: Input)
    mutating func pop() -> Output?
    mutating func last() -> Output?
}

struct SplitState<S: BitSplitState>: ScanState {
    // private:
    private var value: UInt16 = 0
    private var length: UInt8 = 0
    private func output() -> UInt8 {
        UInt8(self.value >> (16 - S.outputBits))
    }
    // public:
    mutating func push(_ value: UInt8) {
        self.value |= UInt16(value) << (16 - S.inputBits - self.length)
        self.length += S.inputBits
    }
    mutating func pop() -> UInt8? {
        guard self.length >= S.outputBits else {
            return nil
        }
        let result = self.output()
        self.value <<= S.outputBits
        self.length -= S.outputBits
        return result
    }
    mutating func last() -> UInt8? {
        guard self.length != 0 else {
            return nil
        }
        self.length = 0
        return self.output()
    }
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

struct U8ToChar: BitSplitState {
    static let inputBits: UInt8 = 8
    static let outputBits: UInt8 = 5
}

struct CharToU8: BitSplitState {
    static let inputBits: UInt8 = 5
    static let outputBits: UInt8 = 8
}

extension Sequence where Element == UInt8 {
    func u8ToU5() -> ScanSequence<SplitState<U8ToChar>, Self> {
        ScanSequence(self)
    }
    func base32() -> String {
        self.u8ToU5().reduce(into: "") { $0.append($1.base32()) }
    }
}

extension Sequence where Element == UInt8 {
    func u5ToU8() -> ScanSequence<SplitState<CharToU8>, Self> {
        ScanSequence(self)
    }
}

extension Sequence where Element == Character {
    func fromBase32() -> [UInt8] {
        self.map { $0.fromBase32() }.u5ToU8().reduce(into: []) { $0.append($1) }
    }
}
