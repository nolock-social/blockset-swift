// Definitions of HTML types

public typealias Element = (
    name: String,
    attributes: [String: String],
    children: [Child]
)

public enum Child {
    case e(Element)
    case t(String)
}

public func e(_ name: String, _ attributes: [String: String], _ children: Child...) -> Child {
    return .e((name, attributes, children))
}

public func e(_ name: String, _ children: Child...) -> Child {
    return .e((name, [:], children))
}

typealias Attribute = (key: String, value: String)

// Rendering HTML

func str(_ s: String) -> String {
    return s
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}

func str(_ a: Attribute) -> String {
    " \(a.key)=\"\(str(a.value))\""
}

let voidTags: Set<String> = [
    "area",
    "base",
    "br",
    "col",
    "embed",
    "hr",
    "img",
    "input",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr",
]

func str(_ c: Child) -> String {
    switch c {
    case .e(let e):
        return str(e)
    case .t(let t):
        return str(t)
    }
}

func str(_ e: Element) -> String {
    "<\(e.name)" + e.attributes.map(str).joined() + ">" +
    (voidTags.contains(e.name) ? "" : (e.children.map(str).joined() + "</\(e.name)>"))
}

public func html(_ c: Child) -> String {
    "<!DOCTYPE html>" + str(c)
}
