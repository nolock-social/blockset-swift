import Foundation

public struct ReceiptModel: Codable, Hashable {
    // Check or reciept image(hash)
    public var image: String?
    /** Check number or identifier */
    public var date: Double?
    /** Dollar amount of the check - converted from string to decimal for C# type safety */
    public var price: Double?
    /** Title for model that user can write down to the model*/
    public var title: String?
    /** Description that user can write down to the model*/
    public var description: String?
    /** Memo or note on the check */
    public var notes: String?
    /** Location from the check */
    public var location: String?

    public var processingStatus: ReceiptProcessingStatus?

    public init() {}
}

public struct ReceiptItem: Codable {
    public var name: String
    public var quantity: Double
    public var unitPrice: Double
    public var totalPrice: Double
}

public struct CheckMetadata: Codable, Hashable {
    /** Confidence score of the extraction */
    public var confidenceScore: Double?
    /** Identifier of the source image */
    public var sourceImageId: String?
    /** Provider used for OCR */
    public var ocrProvider: String?
    /** List of warnings from the extraction process */
    public var warnings: [String]?
}

public enum ReceiptProcessingStatus: Codable {
    case draft
    case processing
    case processed
    case applied
    case failed
}

extension Cas {
    public func report(receiptArray: [ReceiptModel], to: URL) throws {
        // let html = receiptArray.toHtml()
        // _ = FileManager.default.createFile(
        //     atPath: to.path + "/index.html",
        //     contents: html.data(using: .utf8),
        //     attributes: nil
        // )
        // let content = to.appendingPathComponent("/content")
        // try FileManager.default.createDirectory(at: content, withIntermediateDirectories: false)
        // for i in receiptArray {

        //     let imageId = i.image.image
        //     if let data = try? get(imageId) {
        //         let imagePath = content.appendingPathComponent("\(imageId).jpg")
        //         _ = FileManager.default.createFile(
        //             atPath: imagePath.path,
        //             contents: data,
        //             attributes: nil
        //         )
        //     }
        // }
    }
}
