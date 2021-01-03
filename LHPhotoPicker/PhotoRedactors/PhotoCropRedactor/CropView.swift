//
//  CropRedactorView.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 31.12.2020.
//

import UIKit

protocol CropViewDelegate: class {
    func sendZoomRect(zoomRect: CGRect)
}

class CropView: UIView {
    
    weak var delegate: CropViewDelegate?
    
    ///This is UIView of rectangle that contains visable part of image
    var imageCropView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    ///Declare views which will show black spaces between border of screen and image border
    ///when image is too small to fill all available CropView space
    var cropLeftView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemBlue.cgColor
        return view
    }()
    
    var cropRightView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemBlue.cgColor
        return view
    }()
    
    var cropBottomView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemBlue.cgColor
        return view
    }()
    
    var cropTopView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemBlue.cgColor
        return view
    }()
    
    ///Declare all buttons for crop moves
    var btnTopLeft: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemPink.cgColor
        return button
    }()
    
    var btnTopRight: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemPink.cgColor
        return button
    }()
    
    var btnBottomRight: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemPink.cgColor
        return button
    }()
    
    var btnBottomLeft: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemPink.cgColor
        return button
    }()
    
    var btnTopLine: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemOrange.cgColor
        return button
    }()
    
    var btnRightLine: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemOrange.cgColor
        return button
    }()
    
    var btnLeftLine: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemOrange.cgColor
        return button
    }()
    
    var btnBottomLine: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemOrange.cgColor
        return button
    }()
    
    ///
    /// Pan gesture recognizers for all buttons and parameters definition
    ///
    var baseImageCropRect = CGRect()
    var imageCropInitialPoint = CGPoint()
    var imageCropInitialRect = CGRect()

    
    lazy var topLeftButtonPan: UIPanGestureRecognizer = {
        let buttonTap = UIPanGestureRecognizer(target: self, action: #selector(handleCornerButtonPan))
        return buttonTap
    }()
    
    lazy var topRightButtonPan: UIPanGestureRecognizer = {
        let buttonTap = UIPanGestureRecognizer(target: self, action: #selector(handleCornerButtonPan))
        return buttonTap
    }()
    
    lazy var bottomRightButtonPan: UIPanGestureRecognizer = {
        let buttonTap = UIPanGestureRecognizer(target: self, action: #selector(handleCornerButtonPan))
        return buttonTap
    }()
    
    lazy var bottomLeftButtonPan: UIPanGestureRecognizer = {
        let buttonTap = UIPanGestureRecognizer(target: self, action: #selector(handleCornerButtonPan))
        return buttonTap
    }()
    
    lazy var topLineButtonPan: UIPanGestureRecognizer = {
        let buttonPan = UIPanGestureRecognizer(target: self, action: #selector(handleLineButtonPan))
        return buttonPan
    }()
    
    lazy var rightLineButtonPan: UIPanGestureRecognizer = {
        let buttonPan = UIPanGestureRecognizer(target: self, action: #selector(handleLineButtonPan))
        return buttonPan
    }()
    
    lazy var bottomLineButtonPan: UIPanGestureRecognizer = {
        let buttonPan = UIPanGestureRecognizer(target: self, action: #selector(handleLineButtonPan))
        return buttonPan
    }()
    
    lazy var leftLineButtonPan: UIPanGestureRecognizer = {
        let buttonPan = UIPanGestureRecognizer(target: self, action: #selector(handleLineButtonPan))
        return buttonPan
    }()
    
    ///
    ///Crop rectangle parameters
    ///
    ///minimum length of crop rectangle side available
    var minCropSize: CGFloat = 90
    ///standart size of crop buttons
    ///line length is counting dynamicly
    let btnWidth: CGFloat = 40
    let btnHeight: CGFloat = 40
    
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
        
        if image.size.width >= minCropSize && image.size.height >= minCropSize {
            configureCropViews(imageSize: image.size)
        } else {
            print("image size is too small")
        }
        
//        print("Frame origin X : ", self.frame.origin.x)
//        print("Frame origin Y : ", self.frame.origin.y)
//        print("imageCropView X : ", self.imageCropView.frame.origin.x)
//        print("imageCropView Y : ", self.imageCropView.frame.origin.y)
    }
    
    func removeCropViews() {
        imageCropView.removeFromSuperview()
        
        btnTopLeft.removeFromSuperview()
        btnTopRight.removeFromSuperview()
        btnBottomRight.removeFromSuperview()
        btnBottomLeft.removeFromSuperview()
        
        btnTopLine.removeFromSuperview()
        btnRightLine.removeFromSuperview()
        btnBottomLine.removeFromSuperview()
        btnLeftLine.removeFromSuperview()
        
        cropTopView.removeFromSuperview()
        cropRightView.removeFromSuperview()
        cropLeftView.removeFromSuperview()
        cropBottomView.removeFromSuperview()
    }
    
    func addCropViews() {
        self.addSubview(imageCropView)
        
        self.addSubview(btnTopLeft)
        self.addSubview(btnTopRight)
        self.addSubview(btnBottomRight)
        self.addSubview(btnBottomLeft)
        
        self.addSubview(btnTopLine)
        self.addSubview(btnRightLine)
        self.addSubview(btnBottomLine)
        self.addSubview(btnLeftLine)
        
        self.addSubview(cropTopView)
        self.addSubview(cropRightView)
        self.addSubview(cropBottomView)
        self.addSubview(cropLeftView)
        
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
        let cropFrame = CGRect(x: positionX, y: positionY, width: cropSize.width, height: cropSize.height)
        
        configureCropViewFrames(cropFrame: cropFrame)
        
//        imageCropView.frame = cropFrame
//        self.layer.borderWidth = 1
//        self.layer.borderColor = UIColor.green.cgColor
//
//        configureCropEmptyViews(cropFrame: cropFrame)
//        configureCropButtons(cropFrame: cropFrame)
        
        ///Add all crop buttons gesture recognizers
        addCropButtonsGestureRecongizers()
    }
    
    func configureCropViewFrames(cropFrame: CGRect) {
        imageCropView.frame = cropFrame
        
        configureCropEmptyViews(cropFrame: cropFrame)
        configureCropButtons(cropFrame: cropFrame)
    }
    
    func configureCropEmptyViews(cropFrame: CGRect) {
        var xPosition: CGFloat
        var yPosition: CGFloat
        let emptyHeight: CGFloat = (self.frame.height - cropFrame.height) / 2
        let emptyWidth: CGFloat = (self.frame.width - cropFrame.width) / 2
        
        xPosition = self.frame.origin.x
        yPosition = self.frame.origin.y
        cropTopView.frame = CGRect(x: xPosition, y: yPosition, width: self.frame.width, height: emptyHeight)
        
        yPosition = self.frame.origin.y + cropFrame.height + emptyHeight
        cropBottomView.frame = CGRect(x: xPosition, y: yPosition, width: self.frame.width, height: emptyHeight)
        
        yPosition = self.frame.origin.y + emptyHeight
        cropLeftView.frame = CGRect(x: xPosition, y: yPosition, width: emptyWidth, height: cropFrame.height)
        
        xPosition = self.frame.width - emptyWidth
        cropRightView.frame = CGRect(x: xPosition, y: yPosition, width: emptyWidth, height: cropFrame.height)
        
    }
    
    func configureCropButtons(cropFrame: CGRect){
        ///width and height values was checked befor to
        ///satisfy the condition: (button height + button height + line length) >= minCropSize
        ///on each side of crop rectangle
        let btnWidth: CGFloat = self.btnWidth
        let btnHeight: CGFloat = self.btnHeight
        let lineTopLen: CGFloat = cropFrame.width - (btnWidth * 2)
        let lineBorderLen: CGFloat = cropFrame.height - (btnHeight * 2)
        var xPosition: CGFloat
        var yPosition: CGFloat
        
        ///configure corner buttons
        xPosition = cropFrame.origin.x
        yPosition = cropFrame.origin.y
        btnTopLeft.frame = CGRect(x: xPosition, y: yPosition, width: btnWidth, height: btnHeight)
        
        xPosition = cropFrame.origin.x + (cropFrame.size.width - btnWidth)
        yPosition = cropFrame.origin.y
        btnTopRight.frame = CGRect(x: xPosition, y: yPosition, width: btnWidth, height: btnHeight)
        
        xPosition = cropFrame.origin.x + (cropFrame.size.width - btnWidth)
        yPosition = cropFrame.origin.y + (cropFrame.size.height - btnHeight)
        btnBottomRight.frame = CGRect(x: xPosition, y: yPosition, width: btnWidth, height: btnHeight)
        
        xPosition = cropFrame.origin.x
        yPosition = cropFrame.origin.y + (cropFrame.size.height - btnHeight)
        btnBottomLeft.frame = CGRect(x: xPosition, y: yPosition, width: btnHeight, height: btnWidth)
        
        ///Configure crop border buttons
        ///All lines has the same thickness as corner buttons
        xPosition = cropFrame.origin.x + btnWidth
        yPosition = cropFrame.origin.y
        btnTopLine.frame = CGRect(x: xPosition, y: yPosition, width: lineTopLen, height: btnHeight)
        
        xPosition = cropFrame.origin.x + (cropFrame.size.width - btnWidth)
        yPosition = cropFrame.origin.y + btnHeight
        btnRightLine.frame = CGRect(x: xPosition, y: yPosition, width: btnWidth, height: lineBorderLen)
        
        xPosition = cropFrame.origin.x + btnWidth
        yPosition = cropFrame.origin.y + (cropFrame.size.height - btnHeight)
        btnBottomLine.frame = CGRect(x: xPosition, y: yPosition, width: lineTopLen, height: btnHeight)
        
        xPosition = cropFrame.origin.x
        yPosition = cropFrame.origin.y + btnHeight
        btnLeftLine.frame = CGRect(x: xPosition, y: yPosition, width: btnWidth, height: lineBorderLen)
    }
    
    func addCropButtonsGestureRecongizers() {
        btnTopLeft.addGestureRecognizer(topLeftButtonPan)
        btnTopRight.addGestureRecognizer(topRightButtonPan)
        btnBottomRight.addGestureRecognizer(bottomRightButtonPan)
        btnBottomLeft.addGestureRecognizer(bottomLeftButtonPan)
        
        btnTopLine.addGestureRecognizer(topLineButtonPan)
        btnRightLine.addGestureRecognizer(rightLineButtonPan)
        btnBottomLine.addGestureRecognizer(bottomLineButtonPan)
        btnLeftLine.addGestureRecognizer(leftLineButtonPan)
    }
    
    @objc func handleCornerButtonPan(_ gestureRecognizer: UIPanGestureRecognizer){
        print("handle corner button tap")
        
        guard gestureRecognizer.view != nil else { return }
        let btnView = gestureRecognizer.view
        
        ///get coordinates relative to superview
        let translation = gestureRecognizer.translation(in: btnView?.superview)
        
        if gestureRecognizer.state == .began {
            ///get start point position relative to cropView, not superview
            let touchPoint = gestureRecognizer.location(in: btnView)
            print("touchPoint: ", touchPoint)
            
            ///get initial point of cropView to draw crop rectangle when it changes
            self.imageCropInitialPoint = imageCropView.frame.origin
            print("imageCropInitialPoint: ", self.imageCropInitialPoint)
            
            ///get initial frame of cropRect frame to count it's changes from it
            self.imageCropInitialRect = self.imageCropView.frame
        }
        
        
        if gestureRecognizer.state == .changed {
            let width = self.imageCropInitialRect.width
            let heigh = self.imageCropInitialRect.height
            let minX = self.imageCropInitialPoint.x
            let minY = self.imageCropInitialPoint.y
            let maxX = minX + width
            let maxY = minY + heigh
            
//            print("originX: ", originX)
//            print("originY: ", originY)
//            print("minX: ", minX)
//            print("minY: ", minY)
//            print("maxX: ", maxX)
//            print("maxY: ", maxY)
//            print("cropWidth: ", curWidth)
//            print("cropHeigh: ", curHeigh)
//            print("translation.x : ", translation.x)
//            print("translation.y : ", translation.y)
            
            let newCropFrame = CGRect(x: minX + translation.x, y: minY + translation.y, width: width - translation.x, height: heigh - translation.y)
            configureCropViewFrames(cropFrame: newCropFrame)
        }
        
        
        if gestureRecognizer.state == .ended {
            let endXpoint = self.imageCropInitialPoint.x + translation.x
            let endYpoint = self.imageCropInitialPoint.y + translation.y
            print("endXpoint", endXpoint)
            print("endYpoint", endYpoint)

            
//            var scale: CGFloat = 1
//            ///get scale factor witch describes how the image was changed to fit the UIViewImage borders
//            let widthScale = self.bounds.width / (imageCropView.frame.width)
//            let heightscale = self.bounds.height / (imageCropView.frame.height)
//            if widthScale > heightscale {
//                scale = heightscale
//            } else {
//                scale = widthScale
//            }
//
//            print("new scale : ", scale)
            self.delegate?.sendZoomRect(zoomRect: self.imageCropView.frame)
        }
        
    }
    
    @objc func handleLineButtonPan(_ gestureRecognizer: UIPanGestureRecognizer){
        print("handle line button tap")
    }

}
