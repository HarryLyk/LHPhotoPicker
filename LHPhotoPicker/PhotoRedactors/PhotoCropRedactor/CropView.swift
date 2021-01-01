//
//  CropRedactorView.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 31.12.2020.
//

import UIKit

class CropView: UIView {
    
    var cropImageView: UIView = {
        let uiView = UIView()
        uiView.layer.borderWidth = 2
        uiView.layer.borderColor = UIColor.white.cgColor
        return uiView
    }()
    
    var cropLeftView: UIView = {
        let uiView = UIView()
        return uiView
    }()
    
    var cropRightView: UIView = {
        let uiView = UIView()
        return uiView
    }()
    
    var cropBottomView: UIView = {
        let uiView = UIView()
        return uiView
    }()
    
    var cropTopView: UIView = {
        let uiView = UIView()
        return uiView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCropImageView(image: UIImage) {
        
        ///remove previous data if we set new crop views after old
        removeCropViews()
        
        addCropViews()
        
        configureCropViews(imageSize: image.size)
        
//        self.layer.borderWidth = 2
//        self.layer.borderColor = UIColor.blue.cgColor
    }
    
    func removeCropViews() {
        cropImageView.removeFromSuperview()
//        cropTopView.removeFromSuperview()
//        cropRightView.removeFromSuperview()
//        cropLeftView.removeFromSuperview()
//        cropBottomView.removeFromSuperview()
    }
    
    func addCropViews() {
        self.addSubview(cropImageView)
//        self.addSubview(cropTopView)
//        self.addSubview(cropRightView)
//        self.addSubview(cropBottomView)
//        self.addSubview(cropLeftView)
    }
    
    func configureCropViews(imageSize: CGSize){
        var scale: CGFloat = 1

        ///get scale factor witch describes how the image was changed to fit the UIViewImage borders
        let widthScale = self.bounds.width / (imageSize.width )
        let heightscale = self.bounds.height / (imageSize.height)
        if widthScale > heightscale {
            scale = heightscale
        } else {
            scale = widthScale
        }
        
        let cropSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let positionX = (self.bounds.width - cropSize.width) / 2.0
        let positionY = (self.bounds.height - cropSize.height) / 2.0
        
        cropImageView.frame = CGRect(x: positionX, y: positionY, width: cropSize.width, height: cropSize.height)
        cropImageView.layer.borderWidth = 2
        cropImageView.layer.borderColor = UIColor.white.cgColor
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.green.cgColor
    }
}
