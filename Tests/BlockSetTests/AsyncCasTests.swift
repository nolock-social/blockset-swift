//
//  AsyncFileCasTests.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 7/2/25.
//

import Testing
import Foundation
import BlockSet

struct AsyncFileCasTests {
    let dataForTest = Data([1, 2, 3, 4, 5])
    let wrongDataForTest = Data([1, 2, 3, 4, 5, 6])

    let rightText = "Hello, world!".data(using: .utf8)!
    let wrongText = "Hello, world, this is wrong text!"

    //MARK: - Model

    struct ModelForTest: Codable, Equatable {
        var name: String
        var age: Int
        var isStudent: Bool
        var hash: String?
    }

    let model: Model = Model.initial(ModelForTest(name: "Steve", age: 42, isStudent: false))
    let wrongModel: Model = Model.initial(ModelForTest(name: "Steve", age: 42, isStudent: true))

    //MARK: - Currency test

    @Test
    func parallelStores() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)

        async let h1 = cas.store(Data("A".utf8))
        async let h2 = cas.store(Data("B".utf8))
        async let h3 = cas.store(Data("C".utf8))

        let hashes = try await [h1, h2, h3]
        #expect(Set(hashes).count == 3)
    }


    //MARK: Idempotent stores

    @Test
    func idempotentStores() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let asyncableCas: AsyncableCasProtocol = FileCas(dir)
        let cas: Cas = FileCas(dir)

        /// Asyncable cas
        let asyncableHashForRighText = try await asyncableCas.store(rightText)
        let asyncableHashForRighText1 = try await asyncableCas.store(rightText)
        #expect(asyncableHashForRighText == asyncableHashForRighText1)

        /// Non asyncable cas
        let hashForRighText = try cas.add(rightText)
        let hashForRighText1 = try cas.add(rightText)
        #expect(hashForRighText == hashForRighText1)

        #expect(asyncableHashForRighText == hashForRighText)
    }

    //MARK: - Compare paths

    @Test
    func comparePaths() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas = FileCas(dir)

        let hashForText = try await cas.store(rightText)
        let returnedHashForText = try await cas.store(rightText)

        #expect(hashForText == returnedHashForText)
        #expect(returnedHashForText != wrongText)

        let hashForData = try await cas.store(dataForTest)

        let returnedHashForData = cas.id(dataForTest)
        let returnedHashForWrongData = cas.id(wrongDataForTest)

        #expect(hashForData == returnedHashForData)
        #expect(hashForData != returnedHashForWrongData)
    }

    //MARK: - CompareDatas

    @Test
    func compareData() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)

        let data = Data([1, 2, 3, 4, 5])
        let hash = try await cas.store(data)

        let dataFromCas = try await cas.retrieve(hash)

        #expect(dataFromCas == data)
        #expect(dataFromCas != wrongDataForTest)
    }

    //MARK: - Check all mutables

    @Test
    func checkAllMutables() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)

        let mutable = Mutable.initial()
        var modelForTest: ModelForTest? = ModelForTest(name: "Steve", age: 42, isStudent: false)

        let _ = try await cas.saveJSON(mutable, modelForTest)

        modelForTest!.name = "Jobs"
        let nameEdited = try await cas.saveJSON(mutable, modelForTest)

        modelForTest = nil
        let modelDeleted = try await cas.saveJSON(mutable, modelForTest);

        modelForTest = ModelForTest(name: "Tim", age: 70, isStudent: false)

        let _ = try await cas.saveJSON(mutable, modelForTest)

        // check JSON payload
        let d = try await cas.retrieve(modelDeleted!)!
        let s = String(data: d, encoding: .utf8)!
        #expect(s == "{\"parent\":[\"\(nameEdited!)\"]}")

        // Add string based.
        let mutable1: Mutable = Mutable.initial()
        var hello = "Hello CAS!"
        try await cas.saveJSON(mutable1, hello)
        hello = "Goodbye CAS!"
        try await cas.saveJSON(mutable1, hello)

        // Add string based.
        let mutable2 = Mutable.initial()
        let string = "Welcome to the future!"
        try await cas.saveJSON(mutable2, string)

        // list all items
        let list: [Mutable] = try await cas.listOfAllMutables()
        #expect(list.count == 3)

        var filtered = [String]()

        for i in list {
            if let x: String = try? await cas.loadJSON(i) {
                filtered.append(x)
            }
        }

        #expect(filtered.count == 2)
    }

    //MARK: - Active Mutables

    @Test
    func checkActiveMutables() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)

        try await cas.saveJSONModel(model)
        var list: [Mutable] = try await cas.listOfActiveMutables()
        #expect(list.count == 1)

        try await cas.saveJSONModel(wrongModel)
        list = try await cas.listOfActiveMutables()
        #expect(list.count == 2)

        try await cas.deleteModel(model)
        list = try await cas.listOfActiveMutables()
        #expect(list.count == 1)
    }

    //MARK: - Check all idetiniers

    @Test
    func checkAllIdentifiers() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)

        try await cas.saveJSONModel(model)
        var list = try await cas.allIdentifiers()

        #expect(list.count == 2)

        model.value.name = "Tim"

        try await cas.saveJSONModel(model)
        list = try await cas.allIdentifiers()
        #expect(list.count == 4)

        let mutable = Mutable.initial()
        let string = "Hello CAS!"

        try await cas.saveJSON(mutable, string)
        list = try await cas.allIdentifiers()
        #expect(list.count == 6)
    }

    //MARK: - Deleting

    @Test
    func mutableDeleting() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)
        let mutable = Mutable.initial()

        try await cas.saveJSON(mutable, "Hello CAS!")

        var mutables = try await cas.listOfAllMutables()

        #expect(mutables.count == 1)

        try await cas.deleteMutable(mutable)

        mutables = try await cas.listOfAllMutables()

        #expect(mutables.count == 1)
    }

    @Test
    func loadDeletedMutable() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)
        let mutable = Mutable.initial()

        try await cas.saveJSON(mutable, "Hello CAS!")

        var mutables = try await cas.listOfAllMutables()

        #expect(mutables.count == 1)

        try await cas.deleteMutable(mutable)

        mutables = try await cas.listOfDeletedMutables()

        #expect(mutables.count == 1)
    }

    @Test func modelDeleting() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)

        try await cas.saveJSONModel(model)
        var list = try await cas.allIdentifiers()

        #expect(list.count == 2)

        try await cas.deleteModel(model)

        list = try await cas.allIdentifiers()

        #expect(list.count == 3)

        var mutable = try await cas.listOfAllMutables()

        #expect(mutable.count == 1)

        try await cas.saveJSONModel(wrongModel)
        list = try await cas.allIdentifiers()

        #expect(list.count == 5)

        try await cas.deleteModel(wrongModel)
        list = try await cas.allIdentifiers()

        #expect(list.count == 6)

        mutable = try await cas.listOfAllMutables()

        #expect(mutable.count == 2)
    }

    //MARK: - Models after deleting

    @Test
    func deletedModel() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)

        try await cas.saveJSONModel(model)
        try await cas.saveJSONModel(wrongModel)

        var list = try await cas.allIdentifiers()
        #expect(list.count == 4)

        var listOfMutables = try await cas.listOfAllMutables()
        #expect(listOfMutables.count == 2)

        try await cas.deleteModel(model)
        list = try await cas.allIdentifiers()
        #expect(list.count == 5)

        listOfMutables = try await cas.listOfAllMutables()
        #expect(listOfMutables.count == 2)

        let listOfDeletedMutables = try await cas.listOfDeletedMutables()
        #expect(listOfDeletedMutables.count == 1)

        var listOfDeletedModels = [ModelForTest]()

        for i in listOfDeletedMutables {
            if let model: Model<ModelForTest> = try await cas.loadDeletedJSONModel(i) {
                listOfDeletedModels.append(model.value)
            }
        }

        #expect(listOfDeletedModels.count == 1)
        #expect(listOfDeletedModels.first! == model.value)
    }

    //MARK: - Check data after store

    @Test
    func checkDataAfterStore() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)
        let descriptionForModel = "Jobs he has been like a student just for one year"
        var hashForDescription: String?

        try await cas.saveJSONModel(model)

        var list = try await cas.allIdentifiers()

        #expect(list.count == 2)

        hashForDescription = try await cas.store(descriptionForModel.data(using: .utf8)!)
        list = try await cas.allIdentifiers()

        #expect(list.count == 3)

        model.value.hash = hashForDescription

        try await cas.saveJSONModel(model)
        list = try await cas.allIdentifiers()

        #expect(list.count == 5)

        let dataFromCas = try await cas.retrieve(hashForDescription!)

        #expect(dataFromCas == descriptionForModel.data(using: .utf8)!)

        let mutables = try await cas.listOfAllMutables()

        var modelFromCas: Model<ModelForTest>?

        for i in mutables {
            if let model: Model<ModelForTest> = try? await cas.loadJSONModel(i) {
                modelFromCas = model
            }
        }

        #expect(model.value == modelFromCas!.value)
    }

    //MARK: - Check data after delete

    @Test func checkDataAfterDeleted() async throws {
        guard let dir = createDirectory() else {
            return
        }

        let cas: AsyncableCasProtocol = FileCas(dir)

        try await cas.saveJSONModel(model)
        var list = try await cas.allIdentifiers()

        #expect(list.count == 2)

        try await cas.deleteModel(model)
        list = try await cas.allIdentifiers()

        #expect(list.count == 3)

        var mutables = try await cas.listOfAllMutables()

        #expect(mutables.count == 1)

        let mutable = Mutable.initial()
        let stringData = "Hello mutable list".data(using: .utf8)!

        try await cas.saveJSON(mutable, stringData)
        mutables = try await cas.listOfAllMutables()

        #expect(mutables.count == 2)

        let deletedMutables = try await cas.listOfDeletedMutables()

        #expect(deletedMutables.count == 1)

        var deletedModel: ModelForTest?

        for deleteMutable in deletedMutables {
            if let model: ModelForTest = try? await cas.loadDeletedJSON(deleteMutable) {
                deletedModel = model
            }
        }

        #expect(model.value == deletedModel)
    }
}

//MARK: - Helpers

//MARK:  Create Directory

func createDirectory() -> URL? {
    guard let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
        return nil
    }

    let directoryID = UUID().uuidString

    let path = dir.appending(path: "Storage/\(directoryID)", directoryHint: .isDirectory)

    do {

        if FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.removeItem(at: path)
        }

        try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        return path
    } catch {
        return nil
    }
}
