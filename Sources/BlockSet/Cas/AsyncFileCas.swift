import Foundation

//MARK: - Asyncable  FileCas

public actor AsyncFileCas: AsyncableCas {

    // private:
    private let dir: URL

    // public:
    public init(_ dir: URL) {
        self.dir = dir
    }

    public func hash(for data: Data) async -> String {
        await data.sha256Id()
    }

    public func store(_ data: Data) async throws -> String {
        let id = await hash(for: data)
        let path = try await fileURL(forHash: id)

        try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: path)

        return id
    }

    public func retrieve(_ hash: String) async throws -> Data? {
        try? Data(contentsOf: try await fileURL(forHash: hash))
    }

    public func allIdentifiers() async throws -> [String] {
        try await dir.asyncList()
    }

    private func fileURL(forHash hash: String) async throws -> URL {
        let (a, bc) = hash[...].split2()
        let (b, c) = bc.split2()
        return dir.appending(a, true).appending(b, true).appending(c, false)
    }
}