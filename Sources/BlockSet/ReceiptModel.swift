import Foundation

public struct ReceiptModel: Codable {
    // Receipt or check image (hash)
    public var image: String?

    /** Date or timestamp of the receipt */
    public var date: Double?

    /** Total amount on the receipt, stored as a decimal-compatible Double for cross-platform safety */
    public var price: Double?

    /** Title that the user can assign to the receipt */
    public var title: String?

    /** Description that the user can add to the receipt */
    public var description: String?

    /** Additional notes or memos related to the receipt */
    public var notes: String?

    /** List of individual items extracted from the receipt */
    public var items: [ReceiptItem]?

    /** Location information associated with the receipt */
    public var location: Location?

    /** Current processing status of the receipt */
    public var processingStatus: ReceiptProcessingStatus?

    public init() {}
}

// MARK: - Location model
public struct Location: Codable {
    public var latitude: Double
    public var longitude: Double
    public var formattedAddress: String?
    public var source: LocationSource?

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Location source types
public enum LocationSource: String, Codable {
    /** Location extracted from image metadata (EXIF) */
    case exif
    /** Location extracted by AI analysis */
    case ai
    /** Location entered manually by the user */
    case manual
}

// MARK: - Receipt item model
public struct ReceiptItem: Codable {
    public var name: String?
    public var quantity: Double?
    public var unitPrice: Double?
    public var totalPrice: Double?

    public init() {}
}

// MARK: - OCR metadata
public struct CheckMetadata: Codable {
    /** Confidence score of the OCR extraction */
    public var confidenceScore: Double?
    /** Identifier of the source image */
    public var sourceImageId: String?
    /** OCR provider used for extraction */
    public var ocrProvider: String?
    /** List of warnings generated during the extraction process */
    public var warnings: [String]?
}

// MARK: - Receipt processing status
public enum ReceiptProcessingStatus: String, Codable {
    case draft
    case processing
    case processed
    case applied
    case failed
}

extension Cas {
    // public func report(receiptArray: [ReceiptModel], to: URL) throws {
    //     let html = receiptArray.toHtml()
    //     _ = FileManager.default.createFile(
    //         atPath: to.path + "/index.html",
    //         contents: html.data(using: .utf8),
    //         attributes: nil
    //     )
    //     let content = to.appendingPathComponent("/content")
    //     try FileManager.default.createDirectory(at: content, withIntermediateDirectories: false)
    //     for i in receiptArray {

    //     guard let imageId = i.image else { continue }
    //         if let data = try? get(imageId) {
    //             let imagePath = content.appendingPathComponent("\(imageId).jpg")
    //             _ = FileManager.default.createFile(
    //                 atPath: imagePath.path,
    //                 contents: data,
    //                 attributes: nil
    //             )
    //         }
    //     }
    // }
}
