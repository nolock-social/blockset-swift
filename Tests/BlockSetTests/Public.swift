import Foundation
import Testing
import BlockSet

@Test func publicMemCas() async throws {
    var memCas: Cas = MemCas()
    let data = Data([0, 1, 2, 3])
    let id = try memCas.add(data)
    #expect(try memCas.get(id) == data)
    #expect(try memCas.get("nonexistent") == nil)
}

@Test func publicFileCas() async throws {
    let dir = ".test"
    try? FileManager.default.removeItem(atPath: dir)
    try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    var fileCas: Cas = FileCas(URL(filePath: dir))
    let data = Data([0, 1, 2, 3, 4])
    let id = try fileCas.add(data)
    #expect(try fileCas.get(id) == data)
    #expect(try fileCas.get("nonexistent") == nil)
    #expect(try fileCas.list().contains(id))
}
