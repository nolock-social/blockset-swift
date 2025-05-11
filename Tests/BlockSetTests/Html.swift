import BlockSet
import Foundation
import Testing

@Test func html() {
    let page = e(
        "html",
        e(
            "head",
            e("title", .t("My Page"))
        ),
        e(
            "body", ["class": "main"],
            e("img", ["src": "logo.png", "alt": "Logo"]),
            e("p", .t("Welcome & enjoy <Swift>!"))
        )
    )
    let x = html(page)
    #expect(
        x == """
            <!DOCTYPE html><html><head><title>My Page</title></head><body class="main"><img src="logo.png" alt="Logo"><p>Welcome &amp; enjoy &lt;Swift&gt;!</p></body></html>
            """)
}
