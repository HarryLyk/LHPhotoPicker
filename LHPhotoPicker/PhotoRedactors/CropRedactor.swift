//
//  CropRedactor.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 07.12.2020.
//

import UIKit

class CropRedactor: UIView {
    
    var sourceController: UICollectionViewController!
    var baseImage: UIImageView!
    var editedImage: UIImageView?
    
    var cropRectTapRecognizer: UITapGestureRecognizer!
    
    var cropRect: UIView = {
        let cropView = UIView()
        return cropView
    }()
    
    
    //var cropPan: UIPanGestureRecognizer?
    
//    var cropHeight = NSLayoutConstraint()
//    var cropWidth = NSLayoutConstraint()
//    @IBOutlet weak var height: NSLayoutConstraint!
    
    deinit {
        print("CropRedactor deinit was called")
    }
    
    init(sourceController: UICollectionViewController, baseImage: UIImageView) {
        super.init(frame: baseImage.frame)
        
        self.sourceController = sourceController
        self.baseImage = baseImage
        self.cropRect.isUserInteractionEnabled = true
        
        drawCropRect()
        
        //add gesture recognizer to crop rect
        addCropGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///draw a rectangle sized by basePhoto
    private func drawCropRect(){
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
        
        cropRect = UIView(frame: CGRect(x: positionX, y: positionY, width: imageSize.width, height: imageSize.height))
        cropRect.layer.borderWidth = 1
        cropRect.layer.borderColor = UIColor.red.cgColor
        
        baseImage.addSubview(cropRect)
    }
    
    @objc func tapHandler(_ sender: UITapGestureRecognizer? = nil) {
        print("tap was called")
    }
    
    @objc func resizeCropRect(pan: UIPanGestureRecognizer) {
        print("pan was called")
        print("pan recognizer work : ", pan.translation(in: self.baseImage))
    }
    
    private func addCropGestureRecognizer() {
//        let cropPan = UIPanGestureRecognizer(target: sourceController, action: #selector(resizeCropRect(pan:)))
        cropRectTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        self.cropRect.addGestureRecognizer(cropRectTapRecognizer)
//        self.cropRect.addGestureRecognizer(tapRec)
    }
    
    func applyEdit() -> UIImageView? {
        print("CropRedactor apply edit")
        cropRect.removeFromSuperview()
        return editedImage
    }
    
    func cancelEdit() {
        cropRect.removeFromSuperview()
        print("CropRedactor cancel edit")
    }
}

