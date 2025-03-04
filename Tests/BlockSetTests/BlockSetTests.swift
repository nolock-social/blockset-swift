import Testing
@testable import BlockSet

@Test func example() async throws {
    #expect(UInt8(0).base32() == "0")
    #expect(UInt8(1).base32() == "1")
    #expect(UInt8(10).base32() == "a")
    #expect(UInt8(15).base32() == "f")
    #expect(UInt8(31).base32() == "z")
}
