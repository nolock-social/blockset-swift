public struct Location: Codable, Hashable {
    var latitude: Double
    var longitude: Double
}

public struct Image: Codable, Hashable {
    var image: String
    var date: Double
    var location: Location
}

public struct Receipt: Codable, Hashable {
    var image: Image
    var price: String
    var title: String
    var description: String
    var imageList: [String]?

    var date: Double
    var location: Location
}
