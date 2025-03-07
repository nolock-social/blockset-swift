import Foundation
import Testing
import BlockSet

@Test func publicMemCas() async throws {
    var memCas = MemCas()
    let data = Data([0, 1, 2, 3])
    let id = memCas.add(data)!
    #expect(memCas.get(id) == data)
    #expect(memCas.get("nonexistent") == nil)
}
