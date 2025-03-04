extension UInt8 {
    // https://en.wikipedia.org/wiki/Base32#Crockford's_Base32
    private static let u5ToChar: [Character] = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
        "g", "h", "j", "k", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z",
    ]
    public func base32() -> Character {
        Self.u5ToChar[Int(self)]
    }
}

private struct Remainder {
    private var value: UInt16
    private var length: UInt8
    public static func new() -> Remainder {
        Remainder(value: 0, length: 0)
    }
    public mutating func push(_ value: UInt8) {
        self.value |= UInt16(value) << (8 - self.length)
        self.length += 8
    }
    public mutating func pop() -> Character? {
        if self.length < 5 {
            return nil
        }
        let result = self.base32()
        self.value <<= 5
        self.length -= 5
        return result
    }
    public func last() -> Character? {
        if self.length == 0 {
            return nil
        }
        return self.base32()
    }
    private func base32() -> Character {
        UInt8(self.value >> 11).base32()
    }
}

extension Sequence<UInt8> {
    public func base32() -> String {
        var remainder = Remainder.new()
        var result = ""
        for byte in self {
            remainder.push(byte)
            while let value = remainder.pop() {
                result.append(value)
            }
        }
        if let value = remainder.last() {
            result.append(value)
        }
        return result
    }
}
