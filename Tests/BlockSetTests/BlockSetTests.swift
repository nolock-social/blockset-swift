import Foundation
import Testing
@testable import BlockSet

@Test func base32() async throws {
    #expect(UInt8(0).base32() == "0")
    #expect(UInt8(1).base32() == "1")
    #expect(UInt8(10).base32() == "a")
    #expect(UInt8(15).base32() == "f")
    #expect(UInt8(31).base32() == "z")
    //
    let x: [UInt8] = [0b1011_0111, 0b010_10010, 0b1011_1001]
    #expect(x.base32() == "px9bj")
    #expect(Array("px9bj").fromBase32() == x + [0])
}

@Test func memCas() async throws {
    var memCas: Cas = MemCas()
    let data = Data([0, 1, 2, 3])
    let id = try memCas.add(data)
    #expect(try memCas.get(id) == data)
    #expect(try memCas.get("nonexistent") == nil)
    #expect(try memCas.list().contains(id))
}
