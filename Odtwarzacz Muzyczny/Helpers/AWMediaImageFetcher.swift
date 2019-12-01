//
//  ImageCreator.swift
//  Musico
//
//  Created by adam.wienconek on 24.09.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit

class AWMediaImageFetcher {
    
    class func combineImages(images: [UIImage]) -> UIImage? {
        var result: UIImage?
        if images.count < 1 {
            // return nil
            result = nil
        } else if images.count < 2 {
            // return 1 image
            result = images.first
        } else if images.count < 3 {
            // return 2 images
            let imgWidth = images[0].size.width/2
            let imgHeight = images[1].size.height
            let leftImgFrame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            let rightImgFrame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            let left = images[0].cgImage?.cropping(to: leftImgFrame)
            let right = images[1].cgImage?.cropping(to: rightImgFrame)
            let leftImg = UIImage(cgImage: left!)
            let rightImg = UIImage(cgImage: right!)
            UIGraphicsBeginImageContext(CGSize(width: 1000, height: 1000))
            leftImg.draw(in: CGRect(x: 0, y: 0, width: 500, height: 1000))
            rightImg.draw(in: CGRect(x: 500, y: 0, width: 500, height: 1000))
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else if images.count < 4 {
            // return 3 images
            let imgWidth = images[0].size.width/3
            let imgHeight = images[0].size.height
            let leftImgFrame = CGRect(x: images[0].size.width/3, y: 0, width: imgWidth, height: imgHeight)
            let midImgFrame = CGRect(x: images[1].size.width/3, y: 0, width: imgWidth, height: imgHeight)
            let rightImgFrame = CGRect(x: images[2].size.width/3, y: 0, width: imgWidth, height: imgHeight)
            let left = images[0].cgImage?.cropping(to: leftImgFrame)
            let mid = images[1].cgImage?.cropping(to: midImgFrame)
            let right = images[2].cgImage?.cropping(to: rightImgFrame)
            let leftImg = UIImage(cgImage: left!)
            let midImg = UIImage(cgImage: mid!)
            let rightImg = UIImage(cgImage: right!)
            UIGraphicsBeginImageContext(CGSize(width: 600, height: 600))
            leftImg.draw(in: CGRect(x: 0, y: 0, width: 200, height: 600))
            midImg.draw(in: CGRect(x: 200, y: 0, width: 200, height: 600))
            rightImg.draw(in: CGRect(x: 400, y: 0, width: 200, height: 600))
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else if images.count < 9 {
            // return 4 images
            UIGraphicsBeginImageContext(CGSize(width: 800, height: 800))
            images[0].draw(in: CGRect(x: 0, y: 0, width: 400, height: 400))
            images[1].draw(in: CGRect(x: 400, y: 0, width: 400, height: 400))
            images[2].draw(in: CGRect(x: 0, y: 400, width: 400, height: 400))
            images[3].draw(in: CGRect(x: 400, y: 400, width: 400, height: 400))
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else {
            // return 9 images
            UIGraphicsBeginImageContext(CGSize(width: 900, height: 900))
            images[0].draw(in: CGRect(x: 0, y: 0, width: 300, height: 300))
            images[1].draw(in: CGRect(x: 300, y: 0, width: 300, height: 300))
            images[2].draw(in: CGRect(x: 600, y: 0, width: 300, height: 300))
            images[3].draw(in: CGRect(x: 0, y: 300, width: 300, height: 300))
            images[4].draw(in: CGRect(x: 300, y: 300, width: 300, height: 300))
            images[5].draw(in: CGRect(x: 600, y: 300, width: 300, height: 300))
            images[6].draw(in: CGRect(x: 0, y: 600, width: 300, height: 300))
            images[7].draw(in: CGRect(x: 300, y: 600, width: 300, height: 300))
            images[8].draw(in: CGRect(x: 600, y: 600, width: 300, height: 300))
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return result
    }
    
    class func combineImages2(images: [UIImage], outputSize: CGSize) -> UIImage? {
        var result: UIImage?
        if images.count < 1 {
            // return nil
            result = nil
        } else if images.count < 2 {
            // return 1 image
            result = images.first
        } else if images.count < 3 {
            // return 2 images
            let imgWidth = images[0].size.width/2
            let imgHeight = images[1].size.height
            let leftImgFrame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            let rightImgFrame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            let left = images[0].cgImage?.cropping(to: leftImgFrame)
            let right = images[1].cgImage?.cropping(to: rightImgFrame)
            let leftImg = UIImage(cgImage: left!)
            let rightImg = UIImage(cgImage: right!)
            UIGraphicsBeginImageContext(outputSize)
            leftImg.draw(in: CGRect(x: 0, y: 0, width: outputSize.width/2, height: outputSize.height))
            rightImg.draw(in: CGRect(x: outputSize.width/2, y: 0, width: outputSize.width/2, height: outputSize.height))
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else if images.count < 4 {
            // return 3 images
            let imgWidth = images[0].size.width/3
            let imgHeight = images[0].size.height
            let leftImgFrame = CGRect(x: images[0].size.width/3, y: 0, width: imgWidth, height: imgHeight)
            let midImgFrame = CGRect(x: images[1].size.width/3, y: 0, width: imgWidth, height: imgHeight)
            let rightImgFrame = CGRect(x: images[2].size.width/3, y: 0, width: imgWidth, height: imgHeight)
            let left = images[0].cgImage?.cropping(to: leftImgFrame)
            let mid = images[1].cgImage?.cropping(to: midImgFrame)
            let right = images[2].cgImage?.cropping(to: rightImgFrame)
            let leftImg = UIImage(cgImage: left!)
            let midImg = UIImage(cgImage: mid!)
            let rightImg = UIImage(cgImage: right!)
            UIGraphicsBeginImageContext(outputSize)
            leftImg.draw(in: CGRect(x: 0, y: 0, width: outputSize.width*(1/3), height: outputSize.height))
            midImg.draw(in: CGRect(x: outputSize.width*(1/3), y: 0, width: outputSize.width/3, height: outputSize.height))
            rightImg.draw(in: CGRect(x: outputSize.width*(2/3), y: 0, width: outputSize.width/3, height: outputSize.height))
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else if images.count < 9 {
            // return 4 images
            UIGraphicsBeginImageContext(outputSize)
            images[0].draw(in: CGRect(x: 0, y: 0, width: outputSize.width/2, height: outputSize.width/2))
            images[1].draw(in: CGRect(x: outputSize.width/2, y: 0, width: outputSize.width/2, height: outputSize.height/2))
            images[2].draw(in: CGRect(x: 0, y: outputSize.height/2, width: outputSize.width/2, height: outputSize.height/2))
            images[3].draw(in: CGRect(x: outputSize.width/2, y: outputSize.height/2, width: outputSize.width/2, height: outputSize.height/2))
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else {
            // return 9 images
            UIGraphicsBeginImageContext(CGSize(width: 900, height: 900))
            images[0].draw(in: CGRect(x: 0, y: 0, width: 300, height: 300))
            images[1].draw(in: CGRect(x: 300, y: 0, width: 300, height: 300))
            images[2].draw(in: CGRect(x: 600, y: 0, width: 300, height: 300))
            images[3].draw(in: CGRect(x: 0, y: 300, width: 300, height: 300))
            images[4].draw(in: CGRect(x: 300, y: 300, width: 300, height: 300))
            images[5].draw(in: CGRect(x: 600, y: 300, width: 300, height: 300))
            images[6].draw(in: CGRect(x: 0, y: 600, width: 300, height: 300))
            images[7].draw(in: CGRect(x: 300, y: 600, width: 300, height: 300))
            images[8].draw(in: CGRect(x: 600, y: 600, width: 300, height: 300))
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return result
    }
    
}
