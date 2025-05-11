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
}

let css = try! String(
    contentsOf: Bundle.module.url(forResource: "style", withExtension: "css")!,
    encoding: .utf8
)

extension [ReceiptModel] {
    public func toHtml() -> String {
        let node = Node.document(
            .html(
                .head(
                    .title("Receipt List")
                    // custom(.style, [.raw(css)]) as ChildOf<Tag.Head>
                ),
                .body(
                    .fragment(self.map { $0.toHtml() })
                )
            )
        )
        return render(node)
    }
}

extension ReceiptModel {
    public func toHtml() -> Node {
        return .table(
            .tr(
                .td(attributes: [.colspan(2)], .text(title))
            ),
            .tr(
                .td(attributes: [.colspan(2)], .text(description))
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
                .td(attributes: [.colspan(2)], .img(src: "content/\(image.image).jpg", alt: ""))
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
