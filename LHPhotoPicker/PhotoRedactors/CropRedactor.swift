//
//  CropRedactor.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 07.12.2020.
//

import UIKit

class CropRedactor {
    
    var baseImage: UIImageView
    
    init(baseImage: UIImageView) {
        self.baseImage = baseImage
        
    }
    
    ///draw a rectangle sized by basePhoto
    private func drawStartCropRect(){
        let cropLayer = CAShapeLayer()
        var rectBezierPath = UIBezierPath()
        let scale: CGFloat
        
        ///get scale factor witch describes how the image was changed to fit the UIViewImage borders
        if baseImage.image!.size.width > baseImage.image!.size.height {
            scale = baseImage.bounds.width / baseImage.image!.size.width
        } else {
            scale = baseImage.bounds.height / baseImage.image!.size.height
        }
        
        ///calculate size of scaled image by using calculated scale factor
        let imageSize = CGSize(width: baseImage.image!.size.width * scale, height: baseImage.image!.size.height * scale)
        let positionX = (baseImage.bounds.width - imageSize.width) / 2.0
        let positionY = (baseImage.bounds.height - imageSize.height) / 2.0
        
        rectBezierPath = UIBezierPath(rect: CGRect(x: positionX, y: positionY, width: imageSize.width, height: imageSize.height))
        cropLayer.path = rectBezierPath.cgPath
        cropLayer.fillColor = .none
        cropLayer.lineWidth = 1
        cropLayer.strokeColor = UIColor.white.cgColor
        baseImage.layer.addSublayer(cropLayer)
    }
    
    func initializeCropRedactor() {
        drawStartCropRect()
    }
}
