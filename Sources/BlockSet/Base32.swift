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

extension Sequence where Element == UInt8 {
    func base32() -> String {
        self.bitSplit(U8To5()).reduce(into: "") { $0.append($1.base32()) }
    }
}

extension Sequence where Element == Character {
    func fromBase32() -> [UInt8] {
        self.map { $0.fromBase32() }.bitSplit(U5To8()).reduce(into: []) { $0.append($1) }
    }
}
