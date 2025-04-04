public struct LocationModel: Codable, Hashable {
    public var latitude: Double = 0
    public var longitude: Double = 0

    public init() {}
}

public struct ImageModel: Codable, Hashable {
    public var image: String = ""
    public var date: Double = 0
    public var location: LocationModel = LocationModel()

    public init() {}
}

public struct ReceiptModel: Codable, Hashable {
    public var image: ImageModel = ImageModel()
    public var price: String = ""
    public var title: String = ""
    public var description: String = ""
    public var imageList: [String]? = nil

    public var date: Double = 0
    public var location: LocationModel = LocationModel()

    public init() {}
}
