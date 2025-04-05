import Crypto
import Foundation

extension Substring {
    func split2() -> (Substring, Substring) {
        (self.prefix(2), self.dropFirst(2))
    }
}

struct Path {
    let dir: URL
    let file: String

    func url() -> URL {
        dir.appendingPathComponent(file, isDirectory: false)
    }
}

extension URL {
    func list() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(
            at: self, includingPropertiesForKeys: nil
        )
    }
    func appendDir(_ dir: Substring) -> URL {
        appendingPathComponent(String(dir), isDirectory: true)
    }
}

public class FileCas: Cas {

    // private:

    private let dir: URL

    private func path(_ id: String) -> Path {
        let (a, bc) = id[...].split2()
        let (b, c) = bc.split2()
        return Path(
            dir: dir.appendDir(a).appendDir(b),
            file: String(c)
        )
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
        try FileManager.default.createDirectory(at: p.dir, withIntermediateDirectories: true)
        try data.write(to: p.url())
        return id
    }

    public func get(_ id: String) -> Data? {
        // TODO: check errors. if the file doesn't exist, return nil
        // otherwise, throw the error
        return try? Data(contentsOf: path(id).url())
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
