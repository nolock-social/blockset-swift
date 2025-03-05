struct SplitFactory: Factory {
    typealias Element = SplitState
    let inputBits: UInt8
    let outputBits: UInt8
    init(_ inputBits: UInt8, _ outputBits: UInt8) {
        self.inputBits = inputBits
        self.outputBits = outputBits
    }
    func create() -> SplitState {
        SplitState(self)
    }
}

struct SplitState: ScanState {
    // private:
    private let inputBits: UInt8
    private let outputBits: UInt8
    private var value: UInt16 = 0
    private var length: UInt8 = 0
    private func output() -> UInt8 {
        UInt8(self.value >> (16 - outputBits))
    }
    // public:
    init(_ f: SplitFactory) {
        self.inputBits = f.inputBits
        self.outputBits = f.outputBits
    }
    mutating func push(_ input: UInt8) {
        value |= UInt16(input) << (16 - inputBits - length)
        length += inputBits
    }
    mutating func pop() -> UInt8? {
        guard length >= outputBits else {
            return nil
        }
        let result = self.output()
        value <<= outputBits
        length -= outputBits
        return result
    }
    mutating func last() -> UInt8? {
        guard length != 0 else {
            return nil
        }
        length = 0
        return output()
    }
}

extension Sequence where Element == UInt8 {
    func bitSplit(_ f: SplitFactory) -> ScanSequence<SplitFactory, Self> {
        ScanSequence(f, self)
    }
}
