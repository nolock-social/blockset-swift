extension ReceiptModel {
    public func toHtml() -> Child {
        return e("table",
            e("tr",
                e("td", [("colspan", "2")], .t(title))
            ),
            e("tr",
                e("td", [("colspan", "2")], .t(description))
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
                e("td", [("colspan", "2")],
                    e("img", [("src", "content/\(image.image).jpg")])
                )
            )
        )
    }
}

extension [ReceiptModel] {
    public func toHtml() -> String {
        let node = e("html",
            e("head",
                e("title", .t("Receipt List")),
                e("style")
            ),
            .e(("body", [], self.map { $0.toHtml() }))
        )
        return html(node)
    }
}
