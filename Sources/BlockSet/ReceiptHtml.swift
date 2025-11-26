import Foundation

extension ReceiptModel {
    // Принимаем готовую Data изображения
    public func toHtml(imageData: Data?) -> Child {
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
            "html",
            e("head",
                e("meta", [("charset", "utf-8")]),
                e("style", .t("""
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                        background: #f9f9f9;
                        padding: 20px;
                    }
                    .check-table {
                        width: 100%;
                        max-width: 500px;
                        margin: auto;
                        border-collapse: collapse;
                        background: white;
                        box-shadow: 0 0 10px rgba(0,0,0,0.05);
                        border-radius: 8px;
                        overflow: hidden;
                    }
                    .check-table th, .check-table td {
                        text-align: left;
                        padding: 10px 14px;
                        border-bottom: 1px solid #eee;
                    }
                    .check-table th {
                        background: #fafafa;
                        font-weight: 600;
                    }
                    .check-table tr:last-child td {
                        border-bottom: none;
                    }
                    .check-table .img-wrap {
                        text-align: center;
                        padding: 16px;
                    }
                    .check-table img {
                        max-width: 100%;
                        border-radius: 6px;
                    }
                    .check-title {
                        font-size: 1.2em;
                        text-align: center;
                        padding: 12px;
                        background: #fafafa;
                        font-weight: 600;
                    }
                    .check-description {
                        text-align: center;
                        color: #555;
                        font-size: 0.95em;
                        padding-bottom: 10px;
                    }
                """))
            ),
            e("body",
                e("table", [("class", "check-table")],
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
                            imageDataUri.isEmpty ? .t("") : e("img", [
                                ("src", imageDataUri),
                                ("alt", "Receipt Image")
                            ])
                        )
                    )
                )
            )
        )
    }
}

let styleCss = try! String(
    contentsOf: Bundle.module.url(forResource: "style", withExtension: "css")!,
    encoding: .utf8
)

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