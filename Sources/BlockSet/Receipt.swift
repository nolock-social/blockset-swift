public struct Location: Codable, Hashable {
    public var latitude: Double
    public var longitude: Double
}

public struct Image: Codable, Hashable {
    public var image: String
    public var date: Double
    public var location: Location
}

public struct Receipt: Codable, Hashable {
    public var image: Image
    public var price: String
    public var title: String
    public var description: String
    public var imageList: [String]?

    public var date: Double
    public var location: Location
}
