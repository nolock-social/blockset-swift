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

private protocol BitSplitState {
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
    func last() -> UInt8? {
        guard self.length != 0 else {
            return nil
        }
        return self.output()
    }
}

struct Bit8To5: BitSplitState {
    static let inputBits: UInt8 = 8
    static let outputBits: UInt8 = 5
}

private struct U8ToCharState {
    // private:
    private var value: UInt16 = 0
    private var length: UInt8 = 0
    private func base32() -> Character {
        UInt8(self.value >> 11).base32()
    }
    // public:
    mutating func push(_ value: UInt8) {
        self.value |= UInt16(value) << (8 - self.length)
        self.length += 8
    }
    mutating func pop() -> Character? {
        guard self.length >= 5 else {
            return nil
        }
        let result = self.base32()
        self.value <<= 5
        self.length -= 5
        return result
    }
    func last() -> Character? {
        guard self.length != 0 else {
            return nil
        }
        return self.base32()
    }
}

extension Sequence<UInt8> {
    public func base32() -> String {
        var state = U8ToCharState()
        var result = ""
        for byte in self {
            state.push(byte)
            while let value = state.pop() {
                result.append(value)
            }
        }
        if let value = state.last() {
            result.append(value)
        }
        return result
    }
}
