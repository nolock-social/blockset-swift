import Foundation
import Testing
import BlockSet

@Test func publicMemCas() async throws {
    var memCas = MemCas()
    let data = Data([0, 1, 2, 3])
    let id = memCas.add(data)
    #expect(memCas.get(id) == data)
    #expect(memCas.get("nonexistent") == nil)
}

@Test func publicFileCas() async throws {
    let dir = ".test"
    try? FileManager.default.removeItem(atPath: dir)
    try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    var fileCas = FileCas(dir: dir)
    let data = Data([0, 1, 2, 3, 4])
    let id = try fileCas.add(data)
    #expect(fileCas.get(id) == data)
    #expect(fileCas.get("nonexistent") == nil)
    #expect(fileCas.list().contains(id))
}
