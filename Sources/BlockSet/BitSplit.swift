protocol BitSplitState {
    static var inputBits: UInt8 { get }
    static var outputBits: UInt8 { get }
}

struct SplitState<S: BitSplitState>: ScanState {
    // private:
    private let inputBits = S.inputBits
    private let outputBits = S.outputBits
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

struct U8To5: BitSplitState {
    static let inputBits: UInt8 = 8
    static let outputBits: UInt8 = 5
}

struct U5To8: BitSplitState {
    static let inputBits: UInt8 = 5
    static let outputBits: UInt8 = 8
}

extension Sequence where Element == UInt8 {
    func bitSplit<S: BitSplitState>(_ _: S) -> ScanSequence<SplitState<S>, Self> {
        ScanSequence(self)
    }
}
