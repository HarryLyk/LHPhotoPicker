//
//  CropImageView.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 17.03.2021.
//

//
// this class is responsible for scale factor and image resize
//
import UIKit

class CropImageView : UIImageView {
    
    var scale: CGFloat = .init()
    var maxFrame: CGRect = .init()
    var originVisablePoint: CGPoint = .init() //вкрзхняя правая точка виимой области картинки
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupCropImageView(maxCropImageViewFrame: CGRect, image: UIImage) {
        self.maxFrame = maxCropImageViewFrame
        self.frame = setupFrame(imageSize: image.size)
        self.originVisablePoint = self.frame.origin
        self.image = image
    }
    
    //
    //  Count this CropImageView parameters
    //
    func setupFrame(imageSize: CGSize) -> CGRect{
        
        let widthScale = self.maxFrame.width / imageSize.width
        let heightScale = self.maxFrame.height / imageSize.height
        if widthScale > heightScale {
            self.scale = heightScale
        } else {
            self.scale = widthScale
        }
        
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        
        ///
        ///make shift according to superview origin point position
        ///It is parent responsability to set frame origin x and y point (to setup cropImageFrame position on superview view)
        ///
        let xPoint = self.maxFrame.origin.x + (self.maxFrame.width - size.width) / 2.0
        let yPoint = self.maxFrame.origin.y + (self.maxFrame.height - size.height) / 2.0
        
        let rect = CGRect(x: xPoint, y: yPoint, width: size.width, height: size.height)
        
        return rect
    }
    
    
    //
    //  Count new size and scale according to maxFrame
    //
    func setupZoomFrameSize(zoomEndFrame: CGRect) {
        
        let widthScale = self.maxFrame.width / zoomEndFrame.width
        let heightScale = self.maxFrame.height / zoomEndFrame.height
        var scale: CGFloat = 0

        if (widthScale > heightScale) {
            scale = heightScale
        } else {
            scale = widthScale
        }
        
        ///Apply new scale
        self.frame.size = CGSize(width: self.frame.width * scale, height: self.frame.height * scale)
        
        ///Count new global scale factor
        self.scale = self.scale * scale
    }
}
