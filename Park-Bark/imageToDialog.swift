//
//  imageToDialog.swift
//  Park-Bark
//
//  Created by Yael on 03/11/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit

extension UIAlertController{
    func addImage(image: UIImage){
        let maxSize = CGSize(width: 250, height: 250)
        let imageSize = image.size
        
        var ratio: CGFloat!
        if(imageSize.width > imageSize.height){
            ratio = maxSize.width / imageSize.width
        }
        else{
            ratio = maxSize.height / imageSize.height
        }
        
        let scaleSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
        var resizedImage =  image.imageWithSize(scaleSize)
        
        let left = (maxSize.width - resizedImage.size.width) / 2.0
        resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsetsMake(0, -left, 0, 0))
        
        
        let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
        imageAction.isEnabled = false
        imageAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imageAction)
    }
}

extension UIImage{
    func imageWithSize(_ size:CGSize) -> UIImage{
        var scaledImageRect = CGRect.zero
        
        let aspectWidth: CGFloat = size.width / self.size.width
        let aspectHeight: CGFloat = size.height / self.size.height
        let aspectRatio: CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
