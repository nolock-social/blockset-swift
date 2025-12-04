import Crypto
import Foundation

import Foundation

public class FileCas: Cas {
    // private:
    private let dir: URL

    // public:
    public init(_ dir: URL) {
        self.dir = dir
    }

    //MARK: - Non Asyncable Cas
    public func id(_ data: Data) -> String {
        data.sha256Id()
    }

    public func add(_ data: Data) throws -> String {
        let id = id(data)
        let path = path(id)

        try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: path)

        return id
    }

    public func get(_ id: String) -> Data? {
        // TODO: check errors. if the file doesn't exist, return nil
        // otherwise, throw the error
        try? Data(contentsOf: path(id))
    }

    public func list() throws -> [String] {
        try dir.list()
    }

    private func path(_ hash: String) -> URL {
        let (a, bc) = hash[...].split2()
        let (b, c) = bc.split2()
        return dir.appending(a, true).appending(b, true).appending(c, false)
    }
}
