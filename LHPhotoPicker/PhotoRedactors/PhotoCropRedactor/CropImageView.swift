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
    var maxScale: CGFloat = 3.5
    var maxFrame: CGRect = .init()
    var originVisablePoint: CGPoint = .init() //top left visable point of CropImageView
    var isAnimation: Bool = true
    var delay: Double = 0
    var duration: TimeInterval = 0.5
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupCropImageView(maxCropImageViewFrame: CGRect, image: UIImage, maxScale: CGFloat) -> Bool {
        self.maxScale = maxScale
        self.maxFrame = maxCropImageViewFrame
        
        let frame = setupFrame(imageSize: image.size)
        if frame == CGRect.zero {
            return false
        }
        self.frame = frame
        self.originVisablePoint = self.frame.origin
        self.image = image
        
        return true
    }
    
    //
    //  Count this CropImageView parameters
    //
    func setupFrame(imageSize: CGSize) -> CGRect{
        
        let scale = min(self.maxFrame.width / imageSize.width, self.maxFrame.height / imageSize.height)
        if scale > maxScale {
            return CGRect.zero
        }
        self.scale = scale
        
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let xPoint = self.maxFrame.origin.x + (self.maxFrame.width - size.width) / 2.0
        let yPoint = self.maxFrame.origin.y + (self.maxFrame.height - size.height) / 2.0
        
        let rect = CGRect(x: xPoint, y: yPoint, width: size.width, height: size.height)
        
        return rect
    }
    
    
    //
    //  update cropImageView to zoomFrame according to maxFrame
    //
    func updateToZoomFrame(panStartCropFrame: CGRect, panEndCropFrame: CGRect, finalZoomFrame: CGRect) -> Bool {
        let scale: CGFloat = min(self.maxFrame.width / panEndCropFrame.width, self.maxFrame.height / panEndCropFrame.height)
        if self.scale * scale > self.maxScale {
            return false
        } else {
            self.scale = self.scale * scale
        }

        /// Update origin
        ///Берем предыдущую верхнюю левую точку области, в которой отображается картинка из cropImageView
        let originVisableX = self.originVisablePoint.x
        let originVisableY = self.originVisablePoint.y
        
        ///Выравниваем origin finalCropFrame и originVisablePoint для cropImageView
        let xAlign = finalZoomFrame.origin.x - self.originVisablePoint.x
        let yAlign = finalZoomFrame.origin.y - self.originVisablePoint.y
        self.originVisablePoint = CGPoint(x: self.originVisablePoint.x + xAlign, y: self.originVisablePoint.y + yAlign)
        
        ///Высчитываем на сколько надо сдвинуть влево и вверх cropImageView для отображения увеличенной  выделенной области
        let xShift = ((panEndCropFrame.origin.x - panStartCropFrame.origin.x) * scale)
        let yShift = ((panEndCropFrame.origin.y - panStartCropFrame.origin.y) * scale)
        
        //подсчитаем все ранее сделанные сдвиги и вычислим длинну предыдущих сдвигов в соответствии с новым scale
        let curXShift = (originVisableX - self.frame.origin.x) * scale
        let curYShift = (originVisableY - self.frame.origin.y) * scale
        
        UIView.animate(withDuration: duration, animations: {
            self.isUserInteractionEnabled = false
            let finalX = self.originVisablePoint.x - (curXShift + xShift)
            let finalY = self.originVisablePoint.y - (curYShift + yShift)
            self.frame = CGRect(x: finalX, y: finalY, width: self.frame.width * scale, height: self.frame.height * scale)
        }, completion: { done in
            if done {
                self.isUserInteractionEnabled = true
            }
        })
        
        return true
    }
    
    private func createZoomAnimation(startFrame: CGRect, endFrame: CGRect) -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "zoom")
        
        animation.fromValue = startFrame
        animation.toValue = endFrame
        animation.duration = self.duration
        animation.beginTime = CACurrentMediaTime() + self.delay
        animation.isRemovedOnCompletion = false
        animation.fillMode = .both
        
        self.layer.add(animation, forKey: nil)
        
        return animation
    }
}
