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
    private let f: SplitFactory
    private var value: UInt16 = 0
    private var length: UInt8 = 0
    private func output() -> UInt8 {
        UInt8(self.value >> (16 - f.outputBits))
    }
    // public:
    init(_ f: SplitFactory) {
        self.f = f
    }
    mutating func push(_ input: UInt8) {
        value |= UInt16(input) << (16 - f.inputBits - length)
        length += f.inputBits
    }
    mutating func pop() -> UInt8? {
        guard length >= f.outputBits else {
            return nil
        }
        let result = self.output()
        value <<= f.outputBits
        length -= f.outputBits
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
