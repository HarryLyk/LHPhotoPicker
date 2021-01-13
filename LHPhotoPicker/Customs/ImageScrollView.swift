//
//  ImageScrollView.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 27.12.2020.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    var imageZoomView: UIImageView!
    var baseZoom: CGFloat!
    
    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = .fast
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///creaate imageView with recieved image and add it to ImageScrollView subview
    func setImageZoomView(image: UIImage) {
        imageZoomView?.removeFromSuperview()
        imageZoomView = nil
        
        imageZoomView = UIImageView(image: image)
        self.addSubview(imageZoomView)
        
        configureScrollView(imageSize: image.size)
    }
    
    func getImage() -> UIImage {
        return imageZoomView.image ?? UIImage()
    }
    
    func configureScrollView(imageSize: CGSize) {
        ///set scroll view size according to original image size so we can scroll image
        self.contentSize = imageSize
        
        setZoomMinMaxScale()
        self.zoomScale = self.minimumZoomScale
        self.baseZoom = zoomScale
        
        self.imageZoomView.addGestureRecognizer(self.zoomingTap)
        self.imageZoomView.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.centerImage()
    }
    
    func setZoomMinMaxScale() {
        let boundSize = self.bounds.size
        let imageSize = imageZoomView.bounds.size
        
        let widthScale = boundSize.width / imageSize.width
        let heightScale = boundSize.height / imageSize.height
        
        let minScale = min(widthScale, heightScale)
        var maxScale: CGFloat = 1.0
        
        if minScale < 0.1 {
            maxScale = 0.5
        } else if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 1.0
        } else if minScale >= 0.5 {
            maxScale = max(2.0, minScale)
        }
        
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    
    
    func centerImage() {
        let boundSize = self.bounds.size
        var frameToCenter = imageZoomView.frame
        
//        print("bound origin X: ", self.bounds.origin.x)
//        print("bound origin Y: ", self.bounds.origin.y)
//        print("bound width: ", self.bounds.width)
//        print("bound height: ", self.bounds.height)
//        print("frameTocenter originX: ", frameToCenter.origin.x)
//        print("frameTocenter originY: ", frameToCenter.origin.y)
//        print("frameTocenter width: ", frameToCenter.width)
//        print("frameTocenter height: ", frameToCenter.height)
//
        ///count center coordinates for image
        if frameToCenter.size.width < boundSize.width {
            frameToCenter.origin.x = (boundSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < self.bounds.height {
            frameToCenter.origin.y = (boundSize.height - frameToCenter.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageZoomView.frame = frameToCenter
    }
    
    ///
    /// Handle tap zoom gesture recognizer
    ///
    @objc func handleZoomingTap(sender: UIGestureRecognizer){
        let location = sender.location(in: sender.view)
        
        self.performZoom(point: location, animated: true)
    }
    
    func performZoom(point: CGPoint, animated: Bool){
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale
        
        ///check if it's no reason to zoom
        if (minScale == maxScale && minScale > 1){
            return
        }
        
        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let zoomRect = self.zoomRect(scale: finalScale, center: point)
        self.zoom(to: zoomRect, animated: animated)
    }
    
    func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        print("touch point: ", center)
        
        ///count start draw point of zoomRect
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        
        return zoomRect
    }
    
    func performCustomZoom(customZoomRect: CGRect, centerPoint: CGPoint) {
        
        print("\n\nScroll View perform zoom data : ")
        
        
        ///translate center point to scroll view
        let zoomRect = countCustomZoomRect(customZoomRect: customZoomRect, centerPoint: centerPoint)
       
        self.zoom(to: zoomRect, animated: true)
        
        //self.zoomScale = originalZoomScale
        ///5) call function to reconfigure CropView

        
    }
    
    func countCustomZoomRect(customZoomRect: CGRect, centerPoint: CGPoint) -> CGRect {
        
        
        var zoomRect = CGRect()
        
        print("current zoom scale: ", self.zoomScale)
        
        ///true width:
        let customWidth = customZoomRect.width / self.zoomScale
        let customHeight = customZoomRect.height / self.zoomScale
        print("true custom width: ", customZoomRect.width / self.zoomScale)
        print("true custom zoom height: ", customZoomRect.height / self.zoomScale)
                
        /// Get scroll view point
        zoomRect.origin.x = (customZoomRect.origin.x - ((self.bounds.width - self.imageZoomView.frame.width) / 2)) / self.baseZoom
        zoomRect.origin.y = (customZoomRect.origin.y - ((self.bounds.height - self.imageZoomView.frame.height) / 2)) / self.baseZoom
        
        let customWidthScale = self.imageZoomView.frame.width / customWidth
        let customHeightScale = self.imageZoomView.frame.height / customHeight
        let customScale = min(customWidthScale, customHeightScale)
        
        ///setup zoom rect width and height:
        zoomRect.size.width = self.imageZoomView.frame.width / customScale
        zoomRect.size.height = self.imageZoomView.frame.height / customScale
        
        
        print("customZoomRect origin: ", customZoomRect.origin)
        
        zoomRect.origin.x = (self.contentSize.width / self.zoomScale) - zoomRect.width
        zoomRect.origin.y = (self.contentSize.height / self.zoomScale) - zoomRect.height
        let zoomRectCenter = CGPoint(x: zoomRect.origin.x + (zoomRect.width / 2), y: zoomRect.origin.y + (zoomRect.width / 2))
        print("current center point:", zoomRectCenter )
        
        if (customWidthScale >= customHeightScale) {
            let width = self.imageZoomView.frame.width / customWidthScale
            let centerX = zoomRect.origin.x + (zoomRect.width - width) + width / 2
            let centerOffset = (centerX - zoomRectCenter.x) * self.zoomScale
            print("could be width: ", width)
            print("could be center X:", centerX)
            print("offset : ", centerOffset)
            self.frame.origin.x -= centerOffset
        } else {
            
        }
        
        
        print("zoomRect origin:", zoomRect.origin)
        print("zoomSize :", zoomRect.size)
//        print("frame size:", self.frame.size)
//        print("bound size : ", self.bounds.size)
        
        return zoomRect
    }
    
    func drawCircle(center: CGPoint, color: CGColor) -> CALayer {
        let circlePath = UIBezierPath(arcCenter: center, radius: CGFloat(10), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = color
        
        return shapeLayer
    }
    
    ///set UIView which will be zoomed
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageZoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
}
