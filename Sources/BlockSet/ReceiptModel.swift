import Foundation

public struct LocationModel: Codable, Hashable {
    public var latitude: Double = 0
    public var longitude: Double = 0

    public init() {}
}

public struct ImageModel: Codable, Hashable {
    public var image: String = ""
    public var date: Double = 0
    public var location: LocationModel = LocationModel()

    public init() {}
}

public struct ReceiptModel: Codable, Hashable {
    public var image: ImageModel = ImageModel()
    public var price: String = ""
    public var title: String = ""
    public var description: String = ""
    public var imageList: [String]? = nil

    public var date: Double = 0
    public var location: LocationModel = LocationModel()

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
