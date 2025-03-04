extension UInt8 {
    // https://en.wikipedia.org/wiki/Base32#Crockford's_Base32
    private static let u5ToChar: [Character] = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
        "g", "h", "j", "k", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z",
    ]
    func base32() -> Character {
        Self.u5ToChar[Int(self)]
    }
}

extension Character {
    private static let charToU5: [Character: UInt8] = [
        "0": 0x00, "1": 0x01, "2": 0x02, "3": 0x03, "4": 0x04, "5": 0x05, "6": 0x06, "7": 0x07,
        "8": 0x08, "9": 0x09, "a": 0x0A, "b": 0x0B, "c": 0x0C, "d": 0x0D, "e": 0x0E, "f": 0x0F,
        "g": 0x10, "h": 0x11, "j": 0x12, "k": 0x13, "m": 0x14, "n": 0x15, "p": 0x16, "q": 0x17,
        "r": 0x18, "s": 0x19, "t": 0x1A, "v": 0x1B, "w": 0x1C, "x": 0x1D, "y": 0x1E, "z": 0x1F,
    ]
    func fromBase32() -> UInt8 {
        Self.charToU5[self]!
    }
}

protocol BitSplitState {
    static var inputBits: UInt8 { get }
    static var outputBits: UInt8 { get }
    associatedtype Input
    associatedtype Output
    static func fromInput(_ input: Input) -> UInt8
    static func toOutput(_ output: UInt8) -> Output
}

private struct State<S: BitSplitState> {
    // private:
    private var value: UInt16 = 0
    private var length: UInt8 = 0
    private func output() -> S.Output {
        S.toOutput(UInt8(self.value >> (16 - S.outputBits)))
    }
    // public:
    mutating func push(_ value: S.Input) {
        self.value |= UInt16(S.fromInput(value)) << (16 - S.inputBits - self.length)
        self.length += S.inputBits
    }
    mutating func pop() -> S.Output? {
        guard self.length >= S.outputBits else {
            return nil
        }
        let result = self.output()
        self.value <<= S.outputBits
        self.length -= S.outputBits
        return result
    }
    mutating func last() -> S.Output? {
        guard self.length != 0 else {
            return nil
        }
        self.length = 0
        return self.output()
    }
}

struct StateIterator<S: BitSplitState, I: IteratorProtocol>: IteratorProtocol where I.Element == S.Input {
    // private:
    private var state: State<S> = State()
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

struct StateSequence<S: BitSplitState, Base: Sequence>: Sequence where Base.Element == S.Input {
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
    typealias Input = UInt8
    typealias Output = Character
    static func fromInput(_ input: Input) -> UInt8 { input }
    static func toOutput(_ output: UInt8) -> Output { output.base32() }
}

struct CharToU8: BitSplitState {
    static let inputBits: UInt8 = 5
    static let outputBits: UInt8 = 8
    typealias Input = Character
    typealias Output = UInt8
    static func fromInput(_ input: Input) -> UInt8 { input.fromBase32() }
    static func toOutput(_ output: UInt8) -> Output { output }
}

extension Sequence where Element == UInt8 {
    func asBase32Sequence() -> StateSequence<U8ToChar, Self> {
        StateSequence(self)
    }
    func base32() -> String {
        self.asBase32Sequence().reduce(into: "") { $0.append($1) }
    }
}
