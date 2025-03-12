import Foundation
import Testing
import BlockSet

@Test func publicMemCas() async throws {
    let memCas: Cas = MemCas()
    let data = Data([0, 1, 2, 3])
    let id = try memCas.add(data)
    #expect(try memCas.get(id) == data)
    #expect(try memCas.get("nonexistent") == nil)
}

@Test func publicFileCas() async throws {
    let dir = ".test/pfc"
    try? FileManager.default.removeItem(atPath: dir)
    try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    let fileCas: Cas = FileCas(URL(filePath: dir))
    let data = Data([0, 1, 2, 3, 4])
    let id = try fileCas.add(data)
    #expect(try fileCas.get(id) == data)
    #expect(try fileCas.get("nonexistent") == nil)
    #expect(try fileCas.list().contains(id))
}

func editable(_ cas: Cas) throws {
    class X: Codable {
        var a: String
        var b: String
        init(a: String, b: String) {
            self.a = a
            self.b = b
        }
    }
    var e = X(a: "Hello", b: "world!").editable()
    let idInit = try cas.save(e)
    e.value?.a = "Goodbye"
    let idEdit = try cas.save(e)
    e.value = nil
    let idDelete = try cas.save(e);
    e.value = X(a: "A", b: "B")
    let idRestore = try cas.save(e)
    //
    e = try cas.load(idInit)!
    #expect(e.previous == [])
    #expect(e.value?.a == "Hello")
    //
    e = try cas.load(idEdit)!
    #expect(e.previous == [idInit])
    #expect(e.value?.a == "Goodbye")
    //
    e = try cas.load(idDelete)!
    #expect(e.previous == [idEdit])
    #expect(e.value == nil)
    //
    e = try cas.load(idRestore)!
    #expect(e.previous == [idDelete])
    #expect(e.value?.a == "A")
    // check JSON payload
    let d = try cas.get(idDelete)!
    let s = String(data: d, encoding: .utf8)!
    #expect(s == "{\"previous\":[\"\(idEdit)\"]}")

    // Add string based.
    do {
        let e = "Hello world!".editable()
        try cas.save(e)
        e.value = "Goodbye world!"
        try cas.save(e)
    }

    // Add string based.
    do {
        let e = "Hello worldX!".editable()
        try cas.save(e)
    }

    // load X items
    do {
        let list: Array<Editable<X>> = try cas.loadAll()
        #expect(list.count == 1)
    }

    // load String items
    do {
        let list: Array<Editable<String>> = try cas.loadAll().filter { $0.value != nil }
        #expect(list.count == 2)
    }
}

@Test func memEditable() throws {
    try editable(MemCas())
}

@Test func fileEditable() throws {
    let dir = ".test/fe/"
    try? FileManager.default.removeItem(atPath: dir)
    try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    let cas: Cas = FileCas(URL(filePath: dir))
    try editable(cas)
}
