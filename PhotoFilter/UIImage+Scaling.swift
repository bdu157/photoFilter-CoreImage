//
//  UIImage+Scaling.swift
//  PhotoFilter
//
//  Created by Dongwoo Pae on 9/18/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

//make the image scale down to have better performance
extension UIImage {
    func imageByScaling(toSize size: CGSize) -> UIImage? {
        guard let data = pngData(),
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) / 2.0,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        
        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary).flatMap { UIImage(cgImage: $0) }
    }
}

