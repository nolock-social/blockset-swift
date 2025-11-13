import Foundation

extension ReceiptModel {
    public func toHtml() -> Child {
        return e(
            "table", [("class", "check-table")],
            e(
                "tr",
                e("th", [("colspan", "2")], .t("\(title)"))
            ),
            e(
                "tr",
                e("td", [("colspan", "2")], .t("\(description)"))
            ),
            e(
                "tr",
                e("th", .t("Total:")),
                e("th", .t("\(price)"))
            ),
            e(
                "tr",
                e("td", .t("Date:")),
                e("td", .t("\(date)"))
            ),
            e(
                "tr",
                e("td", .t("Location:")),
                e("td", .t("\(location?.formattedAddress)"))
            ),
            e(
                "tr",
                e(
                    "td", [("colspan", "2"), ("class", "img-wrap")],
                    e("img", [
                        ("src", "content/\(image).jpg"),
                        ("alt", "")
                    ])
                )
            )
        )
    }
}

let styleCss = try! String(
    contentsOf: Bundle.module.url(forResource: "style", withExtension: "css")!,
    encoding: .utf8
)

extension [ReceiptModel] {
    public func toHtml() -> String {
        let node = e(
            "html",
            e(
                "head",
                e("meta", [("name", "viewport"), ("content", "width=device-width, initial-scale=1.0")]),
                e("title", .t("Receipt List")),
                e("style", [("type", "text/css")], .t(styleCss))
            ),
            e("body",
                .e(("div", [("class", "container")],
                    self.map { $0.toHtml() }
                ))
            )
        )
        return html(node)
    }
}
