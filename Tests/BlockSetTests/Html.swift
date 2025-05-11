import Foundation
import Testing
import BlockSet

@Test func html() {
    let element = e("div", ["class": "container"],
        e("h1", .t("Hello, World!")),
        e("p", .t("This is a test.")),
        e("ul",
            e("li", .t("Item 1")),
            e("li", .t("Item 2")),
            e("li", .t("Item 3"))
        )
    )
}
