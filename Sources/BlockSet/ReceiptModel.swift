import Html
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

    public func toHtml() -> Node {
        return .table(
            .tr(
                .td(.text(title))
            ),
            .tr(
                .td(.text(description))
            ),
            .tr(
                .td(.text("Total:")),
                .td(.text(price))
            ),
            .tr(
                .td(.text("Date:")),
                .td(.text("\(date)"))
            ),
            .tr(
                .td("Location:"),
                .td(.text("\(location.latitude), \(location.longitude)"))
            ),
            .tr(
                .td(.img(src: image.image, alt: ""))
            )
        )
    }
}

extension [ReceiptModel] {
    public func toHtml() -> String {
        let node = Node.document(
            .html(
                .head(
                    .title("Receipt List")
                ),
                .body(
                    .fragment(self.map { $0.toHtml() })
                )
            )
        )
        return render(node)
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
    }
}
