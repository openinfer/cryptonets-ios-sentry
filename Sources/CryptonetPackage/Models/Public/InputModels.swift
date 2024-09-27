import UIKit

public struct ValidConfig: Codable {
    public let imageFormat: String
    public let skipAntispoof: Bool
    
    public init(imageFormat: String = "rgba",
         skipAntispoof: Bool = true) {
        self.imageFormat = imageFormat
        self.skipAntispoof = skipAntispoof
    }
    
    enum CodingKeys: String, CodingKey {
        case imageFormat = "input_image_format"
        case skipAntispoof = "skip_antispoof"
    }
}

public struct PredictConfig: Codable {
    public let imageFormat: String
    public let skipAntispoof: Bool
    
    public init(imageFormat: String = "rgba",
         skipAntispoof: Bool = true) {
        self.imageFormat = imageFormat
        self.skipAntispoof = skipAntispoof
    }
    
    enum CodingKeys: String, CodingKey {
        case imageFormat = "input_image_format"
        case skipAntispoof = "skip_antispoof"
    }
}

public struct EnrollConfig: Codable {
    public let imageFormat: String
    public let mfToken: String?
    public let skipAntispoof: Bool
    
    public init(imageFormat: String = "rgba",
         mfToken: String? = nil,
         skipAntispoof: Bool = true) {
        self.imageFormat = imageFormat
        self.mfToken = mfToken
        self.skipAntispoof = skipAntispoof
    }
    
    enum CodingKeys: String, CodingKey {
        case imageFormat = "input_image_format"
        case skipAntispoof = "skip_antispoof"
        case mfToken = "mf_token"
    }
}

public struct FaceAndEmbeddingConfig: Codable {
    public let imageFormat: String
    public let skipAntispoof: Bool
    
    public init(imageFormat: String = "rgba",
         skipAntispoof: Bool = true) {
        self.imageFormat = imageFormat
        self.skipAntispoof = skipAntispoof
    }
    
    enum CodingKeys: String, CodingKey {
        case imageFormat = "input_image_format"
        case skipAntispoof = "skip_antispoof"
    }
}

public struct DocumentAndFaceConfig: Codable {
    public let imageFormat: String
    public let skipAntispoof: Bool
    
    public init(imageFormat: String = "rgba",
         skipAntispoof: Bool = true) {
        self.imageFormat = imageFormat
        self.skipAntispoof = skipAntispoof
    }
    
    enum CodingKeys: String, CodingKey {
        case imageFormat = "input_image_format"
        case skipAntispoof = "skip_antispoof"
    }
}
