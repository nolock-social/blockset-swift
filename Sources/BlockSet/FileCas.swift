import Crypto
import Foundation

extension Substring {
    func split2() -> (Substring, Substring) {
        (self.prefix(2), self.dropFirst(2))
    }
}

extension URL {
    func appending(_ p: Substring, _ isDir: Bool) -> URL {
        appendingPathComponent(String(p), isDirectory: isDir)
    }
    func isDirectory() throws -> Bool {
        (try resourceValues(forKeys: [.isDirectoryKey])).isDirectory ?? false
    }
    func list(_ p: String = "") throws -> [String] {
        try FileManager.default.contentsOfDirectory(
            at: self, includingPropertiesForKeys: nil
        ).flatMap {
            let x = p + $0.lastPathComponent
            return try $0.isDirectory() ? try $0.list(x) : [x]
        }
    }
}

public class FileCas: Cas {

    // private:

    private let dir: URL

    public func path(_ id: String) -> URL {
        let (a, bc) = id[...].split2()
        let (b, c) = bc.split2()
        return dir.appending(a, true).appending(b, true).appending(c, false)
    }

    // public:

    public init(_ dir: URL) {
        self.dir = dir
    }

    public func id(_ data: Data) -> String {
        data.sha256Id()
    }

    public func add(_ data: Data) throws -> String {
        let id = id(data)
        let p = path(id)
        try FileManager.default.createDirectory(
            at: p.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: p)
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
}
