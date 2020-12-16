//
//  CropRedactor.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 07.12.2020.
//

import UIKit

class CropRedactor {
    var baseImage: UIImageView!
    var editedImage: UIImageView?
    var panGestureRecognizer: UIPanGestureRecognizer!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var cropRect: UIView!
    
    deinit {
        print("CropRedactor deinit was called")
    }
    
    init(baseImage: UIImageView) {
        self.baseImage = baseImage
    }
    
    ///draw a rectangle sized by basePhoto
    func drawCropRect() -> UIView{
        var scale: CGFloat = 1

        ///get scale factor witch describes how the image was changed to fit the UIViewImage borders
        let widthScale = baseImage.bounds.width / (baseImage.image?.size.width ?? 1)
        let heightscale = baseImage.bounds.height / (baseImage.image?.size.height ?? 1)
        if widthScale > heightscale {
            scale = heightscale
        } else {
            scale = widthScale
        }
        
        ///calculate size of scaled image by using calculated scale factor
        let imageSize = CGSize(width: ((baseImage.image?.size.width) ?? 1) * scale, height: ((baseImage.image?.size.height) ?? 1) * scale)
        let positionX = (baseImage.bounds.width - imageSize.width) / 2.0
        let positionY = (baseImage.bounds.height - imageSize.height) / 2.0
        
        cropRect = UIView(frame: CGRect(x: positionX, y: positionY, width: imageSize.width, height: imageSize.height))
        cropRect.layer.borderWidth = 1
        cropRect.layer.borderColor = UIColor.white.cgColor
        cropRect.isUserInteractionEnabled = true
        
        return cropRect
        //baseImage.addSubview(cropRect)
    }
    
    func applyEdit() {
        cropRect.removeFromSuperview()
    }
    
    func cancelEdit() {
        cropRect.removeFromSuperview()
    }
}

