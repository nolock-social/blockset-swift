import Foundation

extension Substring {
    func split2() -> (Substring, Substring) {
        (self.prefix(2), self.dropFirst(2))
    }
}