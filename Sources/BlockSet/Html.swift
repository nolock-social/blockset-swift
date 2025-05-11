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

//

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
    "source",
    "track",
    "wbr",
]

public func toString(_ e: Element) -> String {
    ""
}
