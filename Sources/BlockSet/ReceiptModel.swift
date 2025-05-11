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

extension [ReceiptModel] {
    public func toHtml() -> String {
        let node = e("html",
            e("head", ["title": "Receipt List"]),
            .e(("body", [:], self.map { $0.toHtml() }))
        )
        return html(node)
    }
}

extension ReceiptModel {
    public func toHtml() -> Child {
        return e("table",
            e("tr",
                e("td", ["colspan": "2"], .t(title))
            ),
            e("tr",
                e("td", ["colspan": "2"], .t(description))
            ),
            e("tr",
                e("td", .t("Total:")),
                e("td", .t(price))
            ),
            e("tr",
                e("td", .t("Date:")),
                e("td", .t("\(date)"))
            ),
            e("tr",
                e("td", .t("Location:")),
                e("td", .t("\(location.latitude), \(location.longitude)"))
            ),
            e("tr",
                e("td", ["colspan": "2"], e("img", ["src": "content/\(image.image).jpg", "alt": ""]))
            )
        )
    }
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
