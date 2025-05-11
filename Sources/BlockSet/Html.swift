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

// Rendering HTML

func str(_ s: String) -> String {
    return s
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}

typealias Attribute = (key: String, value: String)

func str(_ a: Attribute) -> String {
    return " \(a.key)=\"\(str(a.value))\""
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

func str(_ c: [Child]) -> String {
    return c.map(str).joined()
}

func str(_ e: Element) -> String {
    let body = voidTags.contains(e.name) ? "" : str(e.children) + "</\(e.name)>"
    return "<\(e.name)" + e.attributes.map(str).joined() + ">" + body
}

public func html(_ c: Child) -> String {
    return "<!DOCTYPE html>" + str(c)
}
