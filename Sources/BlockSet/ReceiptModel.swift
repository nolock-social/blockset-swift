public struct LocationModel: Codable, Hashable {
    public var latitude: Double
    public var longitude: Double

    public init() {
        latitude = 0
        longitude = 0
    }
}

public struct ImageModel: Codable, Hashable {
    public var image: String
    public var date: Double
    public var location: LocationModel

    public init() {
        image = ""
        date = 0
        location = LocationModel()
    }
}

public struct ReceiptModel: Codable, Hashable {
    public var image: ImageModel
    public var price: String
    public var title: String
    public var description: String
    public var imageList: [String]?

    public var date: Double
    public var location: LocationModel

    public init() {
        image = ImageModel()
        price = ""
        title = ""
        description = ""
        imageList = nil
        date = 0
        location = LocationModel()
    }
}
