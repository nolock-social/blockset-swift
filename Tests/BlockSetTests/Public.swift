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

@Test func editable() async throws {
    var cas: Cas = MemCas()
    //
    class X: Codable {
        var a: String
        var b: String
        init(a: String, b: String) {
            self.a = a
            self.b = b
        }
    }
    var e = X(a: "Hello", b: "world!").editable()
    let idInit = try cas.save(&e)
    e.model?.a = "Goodbye"
    let idEdit = try cas.save(&e)
    e.model = nil
    let idDelete = try cas.save(&e);
    e.model = X(a: "A", b: "B")
    let idRestore = try cas.save(&e)
    //
    e = try cas.load(idInit)!
    #expect(e.previous == [])
    #expect(e.model?.a == "Hello")
    //
    e = try cas.load(idEdit)!
    #expect(e.previous == [idInit])
    #expect(e.model?.a == "Goodbye")
    //
    e = try cas.load(idDelete)!
    #expect(e.previous == [idEdit])
    #expect(e.model == nil)
    //
    e = try cas.load(idRestore)!
    #expect(e.previous == [idDelete])
    #expect(e.model?.a == "A")
}
