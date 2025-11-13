import Foundation

extension ReceiptModel {
public func toHtml() -> Child {
    let dateString: String = {
        guard let timestamp = date else { return "" }
        return Date(timeIntervalSince1970: timestamp).convertToString()
    }()

    let priceString: String = {
        guard let priceValue = price else { return "" }
        return String(format: "%.2f", priceValue)
    }()

    return e(
        "table", [("class", "check-table")],
        e(
            "tr",
            e("th", [("colspan", "2")], .t(title ?? ""))
        ),
        e(
            "tr",
            e("td", [("colspan", "2")], .t(description ?? ""))
        ),
        e(
            "tr",
            e("th", .t("Total:")),
            e("th", .t(priceString))
        ),
        e(
            "tr",
            e("td", .t("Date:")),
            e("td", .t(dateString))
        ),
        e(
            "tr",
            e("td", .t("Location:")),
            e("td", .t(location?.formattedAddress ?? ""))
        ),
        e(
            "tr",
            e(
                "td", [("colspan", "2"), ("class", "img-wrap")],
                e("img", [
                    ("src", "content/\(image ?? "").jpg"),
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

extension Date {
    func convertToString() -> String {
        let f = DateFormatter()
        f.dateFormat = "M/dd/yy, h:mma, EEEE"
        f.amSymbol = "am"
        f.pmSymbol = "pm"
        f.locale = Locale.current
        f.timeZone = .current

        return f.string(from: self)
    }
}