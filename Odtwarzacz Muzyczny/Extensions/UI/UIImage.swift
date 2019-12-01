//
//  UIImage.swift
//  Plum
//
//  Created by adam.wienconek on 09.01.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import UIKit
import Alamofire

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
      let rect = CGRect(origin: .zero, size: size)
      UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
      color.setFill()
      UIRectFill(rect)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      guard let cgImage = image?.cgImage else { return nil }
      self.init(cgImage: cgImage)
    }
    
    func blurred2(radius: CGFloat) -> UIImage {
        let ciContext = CIContext(options: nil)
        guard let cgImage = cgImage else { return self }
        let inputImage = CIImage(cgImage: cgImage)
        guard let ciFilter = CIFilter(name: "CIGaussianBlur") else { return self }
        ciFilter.setValue(inputImage, forKey: kCIInputImageKey)
        ciFilter.setValue(radius, forKey: "inputRadius")
        guard let resultImage = ciFilter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let cgImage2 = ciContext.createCGImage(resultImage, from: inputImage.extent) else { return self }
        return UIImage(cgImage: cgImage2)
    }
    
    func blurred(radius: Float, tint: UIColor? = nil) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        let inputImage = CIImage(cgImage: cgImage)
        let transform = CGAffineTransform.identity
        guard let clampFilter = CIFilter(name: "CIAffineClamp") else { return nil }
        clampFilter.setValue(inputImage, forKey: "inputImage")
        clampFilter.setValue(transform, forKey: "inputTransform")
        
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
        blurFilter.setValue(clampFilter.outputImage, forKey: "inputImage")
        blurFilter.setValue(radius, forKey: "inputRadius")
        
        let context = CIContext(options: nil)
        guard let blurOutput = blurFilter.outputImage, let blurredCGImage = context.createCGImage(blurOutput, from: inputImage.extent) else { return nil }
        
        UIGraphicsBeginImageContext(inputImage.extent.size)
        let outputContext = UIGraphicsGetCurrentContext()
        
        outputContext?.scaleBy(x: 1, y: -1)
        outputContext?.translateBy(x: 0, y: -inputImage.extent.height)
        
        outputContext?.draw(blurredCGImage, in: inputImage.extent)
        
        if let color = tint {
            outputContext?.saveGState()
            outputContext?.setFillColor(color.cgColor)
            outputContext?.fill(inputImage.extent)
            outputContext?.restoreGState()
        }
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
    
    /// Downloads image from given URL
    class func getImage(from url: URL, timeoutInterval: TimeInterval = 3, completion: ((UIImage?) -> Void)?) {
        
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.httpMethod = "GET"
        Alamofire.request(request).responseData { response in
            if let data = response.result.value {
                if let image = UIImage(data: data) {
                    completion?(image)
                } else {
                    print("Could not create the image")
                    completion?(nil)
                }
            } else if let error = response.error {
                print("Could not download the image, error: \(error)")
                completion?(nil)
            } else {
                completion?(nil)
            }
        }
    }
    
    var fixedOrientation: UIImage {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}
