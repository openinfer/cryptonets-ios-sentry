import UIKit
import privid_fhe_tech

enum CryptonetError: Error {
    case noJSON
    case failed
}

public class CryptonetPackage {
    
    public init() {}
    
    private var sessionPointer: UnsafeMutableRawPointer?
    
    public var version: String {
        let version = String(cString: privid_get_version(), encoding: .utf8)
        return version ?? ""
    }
    
    public func initializeSession(settings: NSString) -> Bool {
        let settingsPointer = UnsafeMutablePointer<CChar>(mutating: settings.utf8String)
        let sessionPointer = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: 1)
        
        let isDone = privid_initialize_session(settingsPointer,
                                               UInt32(settings.length),
                                               sessionPointer)
        
        self.sessionPointer = sessionPointer.pointee
        return isDone
    }
    
    public func deinitializeSession() -> Result<Bool, Error> {
        guard let sessionPointer = self.sessionPointer else {
            return .failure(CryptonetError.failed)
        }
        
        privid_deinitialize_session(sessionPointer)
        return .success(true)
    }
    
    public func enroll(image: UIImage, config: EnrollConfig) -> Result<String, Error> {
        guard let sessionPointer = self.sessionPointer,
              let resized = image.resizeImage(targetSize: CGSize(width: 1000, height: 1000)),
              let cgImage = resized.cgImage else {
            return .failure(CryptonetError.failed)
        }
        
        do {
            let configData = try JSONEncoder().encode(config)
            let userConfig = NSString(string: String(data: configData, encoding: .utf8)!)
            let byteImageArray = convertImageToRgbaRawBitmap(image: cgImage)
            let imageWidth = Int32(resized.size.width)
            let imageHeight = Int32(resized.size.height)
            
            let userConfigPointer = UnsafeMutablePointer<CChar>(mutating: userConfig.utf8String)
            let bufferOut = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
            let lengthOut = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            
            let _ = privid_user_enroll(sessionPointer,
                                       userConfigPointer,
                                       Int32(userConfig.length),
                                       byteImageArray,
                                       imageWidth,
                                       imageHeight,
                                       bufferOut,
                                       lengthOut)
            
            let outputString = convertToNSString(pointer: bufferOut)
            
            privid_free_char_buffer(bufferOut.pointee)
            
            bufferOut.deallocate()
            lengthOut.deallocate()
            
            guard let outputString = outputString else { return .failure(CryptonetError.noJSON) }
            return .success(outputString)
        } catch {
            return .failure(CryptonetError.failed)
        }
    }
    
    public func predict(image: UIImage, config: PredictConfig) -> Result<String, Error> {
        guard let sessionPointer = self.sessionPointer,
              let resized = image.resizeImage(targetSize: CGSize(width: 1000, height: 1000)),
              let cgImage = resized.cgImage else {
            return .failure(CryptonetError.failed)
        }
        
        do {
            let configData = try JSONEncoder().encode(config)
            let userConfig = NSString(string: String(data: configData, encoding: .utf8)!)
            let byteImageArray = convertImageToRgbaRawBitmap(image: cgImage)
            let imageWidth = Int32(resized.size.width)
            let imageHeight = Int32(resized.size.height)
            
            let userConfigPointer = UnsafeMutablePointer<CChar>(mutating: userConfig.utf8String)
            
            let bufferOut = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
            let lengthOut = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            
            let _ = privid_user_predict(sessionPointer,
                                        userConfigPointer,
                                        Int32(userConfig.length),
                                        byteImageArray,
                                        imageWidth,
                                        imageHeight,
                                        bufferOut,
                                        lengthOut)
            
            let outputString = convertToNSString(pointer: bufferOut)
            
            privid_free_char_buffer(bufferOut.pointee)
            
            bufferOut.deallocate()
            lengthOut.deallocate()
            
            guard let outputString = outputString else { return .failure(CryptonetError.noJSON) }
            return .success(outputString)
        } catch {
            return .failure(CryptonetError.failed)
        }
    }
    
    public func delete(puid: NSString) -> String? {
        let puidPointer = UnsafeMutablePointer<CChar>(mutating: puid.utf8String)
        
        let bufferOut = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
        let lengthOut = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        
        let userConfig = NSString(string: "{}")
        let userConfigPointer = UnsafeMutablePointer<CChar>(mutating: userConfig.utf8String)
        
        let _ = privid_user_delete(sessionPointer,
                                   userConfigPointer,
                                   Int32(userConfig.length),
                                   puidPointer,
                                   Int32(puid.length),
                                   bufferOut,
                                   lengthOut)
        
        let outputString = convertToNSString(pointer: bufferOut)
        
        privid_free_char_buffer(bufferOut.pointee)
        
        bufferOut.deallocate()
        lengthOut.deallocate()
        
        return outputString
    }
    
    public func validate(image: UIImage, config: ValidConfig) -> Result<String, Error> {
        guard   let sessionPointer = self.sessionPointer,
                let resized = image.resizeImage(targetSize: CGSize(width: 1000, height: 1000)),
                let cgImage = resized.cgImage else {
            return .failure(CryptonetError.failed)
        }
        
        do {
            let configData = try JSONEncoder().encode(config)
            let userConfig = NSString(string: String(data: configData, encoding: .utf8)!)
            
            let imageWidth = Int32(resized.size.width)
            let imageHeight = Int32(resized.size.height)
            let byteImageArray = convertImageToRgbaRawBitmap(image: cgImage)
            
            let userConfigPointer = UnsafeMutablePointer<CChar>(mutating: userConfig.utf8String)
            
            let bufferOut = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
            let lengthOut = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            
            let _ = privid_validate_face(sessionPointer,
                                         userConfigPointer,
                                         Int32(userConfig.length),
                                         byteImageArray,
                                         imageWidth,
                                         imageHeight,
                                         bufferOut,
                                         lengthOut)
            
            let outputString = convertToNSString(pointer: bufferOut)
            
            privid_free_char_buffer(bufferOut.pointee)
            
            bufferOut.deallocate()
            lengthOut.deallocate()
            
            guard let outputString = outputString else { return .failure(CryptonetError.noJSON) }
            return .success(outputString)
        } catch {
            return .failure(CryptonetError.failed)
        }
    }
    
    public func compareFaceAndEmbedding(selfieImage: UIImage, embeddings: [UInt8], config: FaceAndEmbeddingConfig) -> Result<String, Error> {
        guard let sessionPointer = self.sessionPointer else {
            return .failure(CryptonetError.failed)
        }
        
        guard let resizedSelfieImage = selfieImage.resizeImage(targetSize: CGSize(width: 1000, height: 1000)),
              let cgSelfieImage = resizedSelfieImage.cgImage
        else {
            return .failure(CryptonetError.failed)
        }
        
        do {
            let configData = try JSONEncoder().encode(config)
            let userConfig = NSString(string: String(data: configData, encoding: .utf8)!)
            
            let userConfigPointer = UnsafeMutablePointer<CChar>(mutating: userConfig.utf8String)
            
            let byteSelfieImageArray = convertImageToRgbaRawBitmap(image: cgSelfieImage)
            
            let selfieImageWidth = Int32(resizedSelfieImage.size.width)
            let selfieImageHeight = Int32(resizedSelfieImage.size.height)
            
            let embeddingsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: embeddings.count)
            embeddingsBuffer.initialize(from: embeddings, count: embeddings.count)
            
            let bufferOut = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
            let lengthOut = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            
            let _ = privid_compare_face_and_embedding(sessionPointer,
                                                      userConfigPointer,
                                                      Int32(userConfig.length),
                                                      byteSelfieImageArray,
                                                      selfieImageWidth,
                                                      selfieImageHeight,
                                                      embeddingsBuffer,
                                                      Int32(embeddings.count),
                                                      bufferOut,
                                                      lengthOut)
            
            guard let outputString = convertToNSString(pointer: bufferOut) else {
                privid_free_char_buffer(bufferOut.pointee)
                bufferOut.deallocate()
                lengthOut.deallocate()
                return .failure(CryptonetError.failed)
            }
            
            privid_free_char_buffer(bufferOut.pointee)
            bufferOut.deallocate()
            lengthOut.deallocate()
            
            return .success(String(outputString))
        } catch {
            return .failure(CryptonetError.failed)
        }
    }
    
    public func compareDocumentAndFace(documentImage: UIImage, selfieImage: UIImage, config: DocumentAndFaceConfig) -> Result<String, Error> {
        guard let sessionPointer = self.sessionPointer else {
            return .failure(CryptonetError.failed)
        }
        
        guard let resizedDocumentImage = documentImage.resizeImage(targetSize: CGSize(width: 1000, height: 1000)),
              let resizedSelfieImage = selfieImage.resizeImage(targetSize: CGSize(width: 1000, height: 1000)),
              let cgDocumentImage = resizedDocumentImage.cgImage,
              let cgSelfieImage = resizedSelfieImage.cgImage
        else {
            return .failure(CryptonetError.failed)
        }
        
        do {
            let configData = try JSONEncoder().encode(config)
            let userConfig = NSString(string: String(data: configData, encoding: .utf8)!)
            
            let userConfigPointer = UnsafeMutablePointer<CChar>(mutating: userConfig.utf8String)
            
            let byteDocumentImageArray = convertImageToRgbaRawBitmap(image: cgDocumentImage)
            
            let documentImageWidth = Int32(resizedDocumentImage.size.width)
            let documentImageHeight = Int32(resizedDocumentImage.size.height)
            
            let byteSelfieImageArray = convertImageToRgbaRawBitmap(image: cgSelfieImage)
            
            let selfieImageWidth = Int32(resizedSelfieImage.size.width)
            let selfieImageHeight = Int32(resizedSelfieImage.size.height)
            
            let bufferOut = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
            let lengthOut = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
            
            let _ = privid_compare_mugshot_and_face(sessionPointer,
                                                    userConfigPointer,
                                                    Int32(userConfig.length),
                                                    byteDocumentImageArray,
                                                    documentImageWidth,
                                                    documentImageHeight,
                                                    byteSelfieImageArray,
                                                    selfieImageWidth,
                                                    selfieImageHeight,
                                                    bufferOut,
                                                    lengthOut)
            
            guard let outputString = convertToNSString(pointer: bufferOut) else {
                privid_free_char_buffer(bufferOut.pointee)
                bufferOut.deallocate()
                lengthOut.deallocate()
                return .failure(CryptonetError.failed)
            }
            
            privid_free_char_buffer(bufferOut.pointee)
            bufferOut.deallocate()
            lengthOut.deallocate()
            
            return .success(String(outputString))
        } catch {
            return .failure(CryptonetError.failed)
        }
    }
    
    public func compareEmbeddings(embeddingsOne: [UInt8], embeddingsTwo: [UInt8]) -> Result<String, Error> {
        guard let sessionPointer = self.sessionPointer else {
            return .failure(CryptonetError.failed)
        }
        
        let userConfig = NSString(string: "{}")
        let userConfigPointer = UnsafeMutablePointer<CChar>(mutating: userConfig.utf8String)
        
        let bufferOne = UnsafeMutablePointer<UInt8>.allocate(capacity: embeddingsOne.count)
        bufferOne.initialize(from: embeddingsOne, count: embeddingsOne.count)
        
        let bufferTwo = UnsafeMutablePointer<UInt8>.allocate(capacity: embeddingsTwo.count)
        bufferTwo.initialize(from: embeddingsTwo, count: embeddingsTwo.count)
        
        let bufferOut = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
        let lengthOut = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        
        let _ = privid_compare_embeddings(sessionPointer,
                                          userConfigPointer,
                                          Int32(userConfig.length),
                                          bufferOne,
                                          Int32(embeddingsOne.count),
                                          bufferTwo,
                                          Int32(embeddingsTwo.count),
                                          bufferOut,
                                          lengthOut)
        
        let outputString = convertToNSString(pointer: bufferOut)
        
        privid_free_char_buffer(bufferOut.pointee)
        
        bufferOut.deallocate()
        lengthOut.deallocate()
        
        guard let outputString = outputString else { return .failure(CryptonetError.noJSON) }
        return .success(outputString)
    }
}

private extension CryptonetPackage {
    func convertImageToRgbaRawBitmap(image: CGImage) -> [UInt8] {
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        
        var rawData = [UInt8](repeating: 0, count: image.width * image.height * bytesPerPixel)
        
        let context = CGContext(
            data: &rawData, width: image.width, height: image.height,
            bitsPerComponent: bitsPerComponent, bytesPerRow: image.width * bytesPerPixel,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        
        return rawData
    }
    
    func createImageFromRawData(rawData: UnsafeMutableRawPointer?, width: Double?, height: Double?) -> UIImage? {
        let bitsPerComponent = 8
        _ = 32
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let width = Int(width ?? 0)
        let height = Int(height ?? 0)
        
        guard let context = CGContext(data: rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    func convertToNSString(pointer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) -> String? {
        guard let cStringPointer = pointer.pointee else { return nil }
        return String(NSString(utf8String: cStringPointer) ?? "")
    }
    
    func convertToNSStringForBarcode(pointer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) -> String? {  // TEMP SOLUTION
        guard let cStringPointer = pointer.pointee else { return nil }
        var string = String(NSString(utf8String: cStringPointer) ?? "")
        if let dotRange = string.range(of: "),") {
            string.removeSubrange(dotRange.lowerBound..<string.endIndex)
        }
        
        return string
    }
}
