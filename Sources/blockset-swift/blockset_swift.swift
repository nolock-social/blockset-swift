extension UInt8 {
    private static let u5ToChar: [Character] = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
        "g", "h", "j", "k", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z",
    ]
    public func base32() -> Character {
        Self.u5ToChar[Int(self)]
    }
}

private struct Remainder {
    var value: UInt8
    var length: UInt8
}
