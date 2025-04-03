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

func mutable(_ cas: Cas) throws {
    struct X: Codable & Hashable {
        var a: String
        var b: String
        init(a: String, b: String) {
            self.a = a
            self.b = b
        }
    }
    let m = Mutable.initial()
    var e: X? = X(a: "Hello", b: "world!")
    let _ = try cas.saveJson(m, e)
    e!.a = "Goodbye"
    let idEdit = try cas.saveJson(m, e)
    e = nil
    let idDelete = try cas.saveJson(m, e);
    e = X(a: "A", b: "B")
    let _ = try cas.saveJson(m, e)

    // check JSON payload
    let d = try cas.get(idDelete!)!
    let s = String(data: d, encoding: .utf8)!
    #expect(s == "{\"parent\":[\"\(idEdit!)\"]}")

    // Add string based.
    do {
        let m: Mutable = Mutable.initial()
        var e = "Hello world!"
        try cas.saveJson(m, e)
        e = "Goodbye world!"
        try cas.saveJson(m, e)
    }

    // Add string based.
    do {
        let m = Mutable.initial()
        let e = "Hello worldX!"
        try cas.saveJson(m, e)
    }

    // list all items
    do {
        let list: Array<Mutable> = try cas.listMutable()
        #expect(list.count == 3)
        let ls = list.filter {
            let x: String? = try? cas.loadJson($0)
            return x != nil
        }
        #expect(ls.count == 2)
    }
}

@Test func memMutable() throws {
    try mutable(MemCas())
}

@Test func fileMutable() throws {
    let dir = ".test/mutable/"
    try? FileManager.default.removeItem(atPath: dir)
    try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    let cas: Cas = FileCas(URL(filePath: dir))
    try mutable(cas)
}

func model(_ cas: Cas) throws {
    struct X: Codable & Hashable {
        var a: String
        var b: String
        init(a: String, b: String) {
            self.a = a
            self.b = b
        }
    }
    let m = Model.initial(X(a: "Hello", b: "world!"))
    try cas.saveJsonModel(m)
    m.value.a = "Goodbye"
    let idEdit = try cas.saveJsonModel(m)
    let idDelete = try cas.deleteModel(m)
    m.value = X(a: "A", b: "B")
    try cas.saveJsonModel(m)

    // check JSON payload
    let d = try cas.get(idDelete!)!
    let s = String(data: d, encoding: .utf8)!
    #expect(s == "{\"parent\":[\"\(idEdit!)\"]}")

    // Add string based.
    do {
        let m = Model.initial("Hello world!")
        try cas.saveJsonModel(m)
        m.value = "Goodbye world!"
        try cas.saveJsonModel(m)
    }

    // Add string based.
    do {
        let m = Model.initial("Hello world!!!")
        try cas.saveJsonModel(m)
    }

    // list all items
    do {
        let list: Array<Mutable> = try cas.listMutable()
        #expect(list.count == 3)
        let ls = list.filter {
            let x: String? = try? cas.loadJson($0)
            return x != nil
        }
        #expect(ls.count == 2)
    }
}

@Test func memModel() throws {
    try mutable(MemCas())
}

@Test func fileModel() throws {
    let dir = ".test/model/"
    try? FileManager.default.removeItem(atPath: dir)
    try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    let cas: Cas = FileCas(URL(filePath: dir))
    try mutable(cas)
}

@Test func sync1() throws {
    let dir = ".test/sync/"
    try? FileManager.default.removeItem(atPath: dir)
    let dir1 = dir + "/1"
    let dir2 = dir + "/2"
    try! FileManager.default.createDirectory(atPath: dir1, withIntermediateDirectories: true)
    try! FileManager.default.createDirectory(atPath: dir2, withIntermediateDirectories: true)
    let cas1: Cas = FileCas(URL(filePath: dir1))
    let cas2: Cas = FileCas(URL(filePath: dir2))
    let data = Data([0, 1, 2, 3])
    let id = try cas1.add(data)
    let data2 = Data([0, 1, 2, 3, 4])
    let id2 = try cas2.add(data2)
    #expect(try cas1.get(id) == data)
    #expect(try cas2.get(id) == nil)
    #expect(try cas1.get(id2) == nil)
    #expect(try cas2.get(id2) == data2)
    try cas1.sync(cas2)
    #expect(try cas2.get(id) == data)
    #expect(try cas1.get(id2) == data2)
}
