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

private struct State<S: BitSplitState> {
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

struct StateIterator<S: BitSplitState, I: IteratorProtocol>: IteratorProtocol where I.Element == UInt8 {
    // private:
    private var state: State<S> = State()
    private var iterator: I
    // public:
    init(_ iterator: I) {
        self.iterator = iterator
    }
    mutating func next() -> UInt8? {
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

struct StateSequence<S: BitSplitState, Base: Sequence>: Sequence where Base.Element == UInt8 {
    private let base: Base
    // public:
    init(_ base: Base) {
        self.base = base
    }
    func makeIterator() -> StateIterator<S, Base.Iterator> {
        StateIterator(base.makeIterator())
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
    func u8ToU5() -> StateSequence<U8ToChar, Self> {
        StateSequence(self)
    }
    func base32() -> String {
        self.u8ToU5().reduce(into: "") { $0.append($1.base32()) }
    }
}

extension Sequence where Element == UInt8 {
    func u5ToU8() -> StateSequence<CharToU8, Self> {
        StateSequence(self)
    }
}

extension Sequence where Element == Character {
    func fromBase32() -> [UInt8] {
        self.map { $0.fromBase32() }.u5ToU8().reduce(into: []) { $0.append($1) }
    }
}
