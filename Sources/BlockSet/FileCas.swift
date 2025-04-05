import Crypto
import Foundation

extension Substring {
    func split2() -> (Substring, Substring) {
        (self.prefix(2), self.dropFirst(2))
    }
}

extension URL {
    func list() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(
            at: self, includingPropertiesForKeys: nil
        )
    }
    func appending(_ p: Substring, _ isDir: Bool) -> URL {
        appendingPathComponent(String(p), isDirectory: isDir)
    }
}

public class FileCas: Cas {

    // private:

    private let dir: URL

    private func path(_ id: String) -> URL {
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
        return try? Data(contentsOf: path(id))
    }

    public func list() throws -> [String] {
        try dir
            .list()
            .flatMap {
                let a = $0.lastPathComponent
                return try $0.list()
                    .flatMap {
                        let b = $0.lastPathComponent
                        return try $0.list().map { "\(a)\(b)\($0.lastPathComponent)" }
                    }
            }
    }
}
