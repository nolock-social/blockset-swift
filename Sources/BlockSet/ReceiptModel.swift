import Foundation

public struct ImageModel: Codable, Hashable {
    public var image: String = String()
    public var date: Double = Double()
    public var location: String = String()

    public init() {}
}

public struct ReceiptModel: Codable, Hashable {
    public var image: ImageModel = ImageModel()
    public var price: Decimal = Decimal()
    public var currency: String = String()
    public var title: String = String()
    public var description: String = String()
    public var notes: String = String()

    public var imageList: [String]? = nil

    ///Source of data. ex AI, or human
    public var source: String? = nil

    public var date: String = ""
    public var location: String = ""

    public init() {}
}

extension Cas {
    public func report(receiptArray: [ReceiptModel], to: URL) throws {
        let html = receiptArray.toHtml()
        _ = FileManager.default.createFile(
            atPath: to.path + "/index.html",
            contents: html.data(using: .utf8),
            attributes: nil
        )
        let content = to.appendingPathComponent("/content")
        try FileManager.default.createDirectory(at: content, withIntermediateDirectories: false)
        for i in receiptArray {
            let imageId = i.image.image
            if let data = try? get(imageId) {
                let imagePath = content.appendingPathComponent("\(imageId).jpg")
                _ = FileManager.default.createFile(
                    atPath: imagePath.path,
                    contents: data,
                    attributes: nil
                )
            }
        }
    }
}
