import Foundation

extension URL {
    func appending(_ p: Substring, _ isDir: Bool) -> URL {
        appendingPathComponent(String(p), isDirectory: isDir)
    }

    func isDirectory() throws -> Bool {
        (try resourceValues(forKeys: [.isDirectoryKey])).isDirectory ?? false
    }

    func list(_ p: String = "") throws -> [String] {
        try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).flatMap {
            let x = p + $0.lastPathComponent
            return try $0.isDirectory() ? try $0.list(x) : [x]
        }
    }

    func asyncList(_ prefix: String = "") async throws -> [String] {
        try await withThrowingTaskGroup(of: [String].self) { group in
            let items = try FileManager.default.contentsOfDirectory(
                at: self,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )

            for item in items {
                let name = prefix + item.lastPathComponent

                group.addTask {
                    if try item.isDirectory() {
                        return try await item.asyncList(name)
                    } else {
                        return [name]
                    }
                }
            }

            var list: [String] = []
            for try await result in group {
                list.append(contentsOf: result)
            }

            return list
        }
    }
}
