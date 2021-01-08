//
//  ImageScrollView.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 27.12.2020.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    var imageZoomView: UIImageView!
    
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
        
        ///count start draw point of zoomRect
        print("center x : ", center.x)
        print("center y : ", center.y)
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        
        print("bounds width : ", bounds.size.width)
        print("bounds height: ", bounds.size.height)
        print("zoomRect.size.width : ", zoomRect.size.width)
        print("zoomRect.size.height: ", zoomRect.size.height)
        print("zoomRect origin x: ", zoomRect.origin.x)
        print("zoomRect origin y: ", zoomRect.origin.y)
        
        return zoomRect
    }
    
    func performCustomZoom(customZoomRect: CGRect, centerPoint: CGPoint) {

        //Надо сделать нормальлный перевод координат centerPoint в scroll view
        
        print("\n\n\nScroll View perform zoom")
        print("bounds width:", self.bounds.width)
        print("bounds height:", self.bounds.height)
        print("customZoomRect width : ", customZoomRect.width)
        print("customZoomRect height: ", customZoomRect.height)
        print("Center point: ", centerPoint)
        let zoomCenterPoint = CGPoint(x: centerPoint.x / self.zoomScale, y: centerPoint.y / self.zoomScale)
        print("Final center point: ", zoomCenterPoint)
        
        ///1) count zoom scale factor
        let widthScale: CGFloat = customZoomRect.width / self.bounds.width
        let heightScale: CGFloat = customZoomRect.height / self.bounds.height
        let zoomScale: CGFloat = self.zoomScale / min(widthScale, heightScale)
        
//        let realWidthScale = customZoomRect.width / (self.bounds.width / self.zoomScale)
//        let realHeightScale = customZoomRect.height / (self.bounds.height / self.zoomScale)
//        print("realWidthScale : ", realWidthScale)
//        print("readHeightScale: ", realHeightScale)
//        zoomScale = max(realWidthScale, realHeightScale)
        
        ///2) write function similar to performZoom(), but for current purpuse
        print("current scale: ", self.zoomScale)
        print("final zoom scale: ", zoomScale)
        
        ///translate center point
        
        ///3) call zoomRect(scale: CGFloat, center: CGPoint) to get zoom rectangle
        let finalZoomRect: CGRect = zoomRect(scale: zoomScale, center: zoomCenterPoint)
        
//        let originalZoomScale = self.zoomScale
//        self.zoomScale = zoomScale
        ///4) call zoom() function
        self.zoom(to: finalZoomRect, animated: true)
        //self.zoomScale = originalZoomScale
        ///5) call function to reconfigure CropView

        
    }
    
    ///set UIView which will be zoomed
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageZoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
}
