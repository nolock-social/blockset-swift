import Foundation

extension ReceiptModel {
    public func toHtml(imageData: Data? = nil) -> Child {
        let dateString: String = {
            guard let timestamp = date else { return "" }
            return Date(timeIntervalSince1970: timestamp).convertToString()
        }()

        let priceString: Decimal = {
            guard let priceValue = price else { return Decimal() }
            return priceValue
        }()

        let imageDataUri: String = {
            guard let data = imageData else { return "" }
            let base64String = data.base64EncodedString()
            return "data:image/jpeg;base64,\(base64String)"
        }()

        return e(
            "table",
            [("class", "check-table")],

            e("tr",
                e("th", [("colspan", "2"), ("class", "check-title")], .t(title ?? ""))
            ),

            e("tr",
                e("td", [("colspan", "2"), ("class", "check-description")], .t(description ?? ""))
            ),

            e("tr",
                e("th", .t("Total:")),
                e("td", .t("\(priceString)"))
            ),

            e("tr",
                e("th", .t("Date:")),
                e("td", .t(dateString))
            ),

            e("tr",
                e("th", .t("Location:")),
                e("td", .t(location?.formattedAddress ?? ""))
            ),

            e("tr",
                e("td", [("colspan", "2"), ("class", "img-wrap")],
                    imageDataUri.isEmpty
                        ? .t("")
                        : e("img", [
                            ("src", imageDataUri),
                            ("alt", "Receipt Image")
                        ])
                )
            )
        )
    }
}

let styleCss: String = {
    guard
        let url = Bundle.module.url(forResource: "style", withExtension: "css"),
        let css = try? String(contentsOf: url, encoding: .utf8)
    else {
        return ""
    }
    return css
}()

extension [(model: ReceiptModel, imageData: Data?)] {
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
                    self.map { $0.model.toHtml(imageData: $0.imageData) }
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