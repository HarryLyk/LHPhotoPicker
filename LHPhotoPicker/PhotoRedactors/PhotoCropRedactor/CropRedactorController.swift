//
//  CropRedactorController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 26.12.2020.
//

import UIKit
import RxCocoa
import RxSwift

class CropRedactorController: UIViewController/*, CropViewDelegate */{
    
    let cropImageView: CropImageView = {
        let imageView = CropImageView(frame: CGRect())
        return imageView
    }()
    
    var cropView: CropView = {
        let view = CropView(frame: CGRect())
        return view
    }()
    
    let btnCancel: UIButton = {
       let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let btnApply: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Apply", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let btnZoneView: UIView = {
        let btnZoneView = UIView()
        btnZoneView.backgroundColor = .black
        btnZoneView.isUserInteractionEnabled = false
        return btnZoneView
    }()
    
    var hideView: UIView = {
       let hideView = UIView()
        hideView.isUserInteractionEnabled = false
        hideView.backgroundColor = .black
        hideView.layer.opacity = 1
        return hideView
    }()
    
    let botBtnConstr: CGFloat = 30              //constraint between bottom button anchor and view anchor
    let btnHeight: CGFloat = 40                 //button height
    let topBtnConstr: CGFloat = 50              //constraint between top button anchor and bottom cropImageView anchor
    let topCropImageViewConsraint: CGFloat = 50 //constraint between cropImageView and top anchors
    let svHorisontalConstr: CGFloat = 20        //constraint between cropView and left, right anchors
    var botCropImageViewConstraint: CGFloat = 0 //constraint between imageCropView and bottom view border.
    
    var panStartCropFrame: CGRect = CGRect()
    var panEndCropFrame: CGRect = CGRect()
    var maxCropFrame: CGRect = CGRect()
    
    var viewModel: CropRedactorViewModel!
    var disposeBag = DisposeBag()
     
    deinit {
        print("CropRedactorController deinit was called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupSubviews()
        setupRx()
        
    }
    
    func addSubviews() {
        view.addSubview(btnApply)
        view.addSubview(btnCancel)
        view.addSubview(cropImageView)
        view.addSubview(cropView)
        view.addSubview(btnZoneView)
        view.addSubview(hideView)
    }
    
    func setupSubviews() {
        ///Set max bottom constraint for cropImageView
        botCropImageViewConstraint = botBtnConstr + btnHeight + topBtnConstr
        
        ///Set special space for button elements, so CropImageView will not cover up buttons during image move to bot positions
        btnZoneView.frame = CGRect(x: 0, y: self.view.frame.height - botCropImageViewConstraint, width: self.view.frame.width, height: botCropImageViewConstraint)
        
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        btnCancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -botBtnConstr).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: btnHeight).isActive = true
        btnCancel.superview?.bringSubviewToFront(btnCancel)
        
        btnApply.translatesAutoresizingMaskIntoConstraints = false
        btnApply.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        btnApply.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -botBtnConstr).isActive = true
        btnApply.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnApply.heightAnchor.constraint(equalToConstant: btnHeight).isActive = true
        btnApply.superview?.bringSubviewToFront(btnApply)
        
        ///Set maximum area, available for image
        let heightToView = btnHeight + botBtnConstr + topBtnConstr + topCropImageViewConsraint
        maxCropFrame = CGRect(x: view.frame.origin.x + svHorisontalConstr,
                               y: view.frame.origin.y + topCropImageViewConsraint,
                               width: view.frame.width - svHorisontalConstr * 2,
                               height: view.frame.height - heightToView)
        
        // Setup cropImageView
        if cropImageView.setupCropImageView(maxCropImageViewFrame: maxCropFrame, image: viewModel.image, maxScale: 3.5) == false {
            self.dismiss(animated: true, completion: nil)
        }
        setupCropImageView()
        
        // Setup CropView
        if cropView.setupCropView(frame: cropImageView.frame, maxFrame: maxCropFrame) == false {
            self.dismiss(animated: true, completion: nil)
        }
        setupCropView()
        
        let hideFrame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height - botCropImageViewConstraint)
        setupHideView(hideFrame: hideFrame, cropFrame: cropView.frame)
    }
    
    /// Setup CropImageView
    private func setupCropImageView(){
        cropImageView.duration = 0.5
    }
    
    /// Setup CropView
    private func setupCropView(){
        cropView.setCropBtnPan(target: self, action: #selector(handleCropBtnPan(_:)))
        cropView.addPangestureRecognizers()
        cropView.duration = 0.5
    }
    
    /// Setup HideView
    private func setupHideView(hideFrame: CGRect, cropFrame: CGRect){
        hideView.frame = hideFrame
        hideView.layer.mask = createCropMask(hideFrame: hideFrame, cropFrame: cropFrame)
    }
    
    private func updateHideView(cropFrame: CGRect){
        hideView.layer.mask = createCropMask(hideFrame: hideView.frame, cropFrame: cropFrame)
    }
    
    private func updateHideViewWithAnimation(startCropFrame: CGRect, endCropFrame: CGRect){
        hideView.layer.opacity = 0.5
        
        //
        // INCORRECT
        //
        
        let newMask = createCropMask(hideFrame: hideView.frame, cropFrame: endCropFrame)
        let newPath = UIBezierPath(rect: newMask.bounds)
        
        let oldMask = createCropMask(hideFrame: hideView.frame, cropFrame: startCropFrame)
        let oldPath = UIBezierPath(rect: oldMask.bounds)
        
        /// Layer animations
        let animation = createAnimation(fromValue: oldPath.cgPath, toValue: newPath.cgPath, duration: 3)
//        hideView.layer.mask?.add(animation, forKey: nil)
        hideView.layer.add(animation, forKey: nil)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        hideView.layer.mask = newMask
        CATransaction.commit()
        
        hideView.layer.opacity = 1
    }
    
    func createAnimation(fromValue: CGPath, toValue: CGPath, duration: TimeInterval) -> CABasicAnimation {
                        
        let animation = CABasicAnimation(keyPath: "path")
        
        animation.fromValue = fromValue
        animation.toValue = toValue
        
        animation.duration = 5
        animation.beginTime = CACurrentMediaTime()
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    private func createCropMask(hideFrame: CGRect, cropFrame: CGRect) -> CAShapeLayer {
        let mutablePath = CGMutablePath()
        mutablePath.addRect(hideFrame)
        mutablePath.addRect(cropFrame)
        
        let mask = CAShapeLayer()
        mask.path = mutablePath
        mask.fillRule = .evenOdd

        return mask
    }
    
    func setupRx() {
        btnApply.rx.tap
            .subscribe(onNext:{ [weak self] _ in
                print("apply button was tapped")
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        btnCancel.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("cancel button was tapped")
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    
    ///
    /// Handle cropView corner buttons pan
    ///
    @objc func handleCropBtnPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let btnView = gestureRecognizer.view
        let translation = gestureRecognizer.translation(in: btnView?.superview)
        
        if gestureRecognizer.state == .began {
            self.panStartCropFrame = cropView.frame
            self.hideView.layer.opacity = 0.5
        }
        
        if gestureRecognizer.state == .changed {
            cropView.layer.borderColor = .none
            cropView.layer.borderWidth = 0
            
            ///Get border values for new cropFrame
            var cropFrame: CGRect = CGRect()
            let width  = self.panStartCropFrame.width
            let height = self.panStartCropFrame.height
            let minX = self.panStartCropFrame.origin.x
            let minY = self.panStartCropFrame.origin.y
            let minWidth = cropView.minCropWidth
            let minHegith = cropView.minCropHeight
            
            switch btnView {
            case cropView.btnTopLeft:
                if width - translation.x < minWidth || height - translation.y < minHegith {
                    return
                } else if width - translation.x > width && height - translation.y > height {
                    cropFrame = self.panStartCropFrame
                } else if width - translation.x > width {
                    cropFrame = CGRect(x: minX, y: minY + translation.y, width: width, height: height - translation.y)
                } else if height - translation.y > height {
                    cropFrame = CGRect(x: minX + translation.x, y: minY, width: width - translation.x, height: height)
                } else {
                    cropFrame = CGRect(x: minX + translation.x, y: minY + translation.y, width: width - translation.x, height: height - translation.y)
                }
            case cropView.btnTopRight:
                if width + translation.x < minWidth || height - translation.y < minHegith {
                    return
                } else if width + translation.x > width && height - translation.y > height {
                    cropFrame = self.panStartCropFrame
                } else if width + translation.x > width {
                    cropFrame = CGRect(x: minX, y: minY + translation.y, width: width, height: height - translation.y)
                } else if height - translation.y > height {
                    cropFrame = CGRect(x: minX, y: minY, width: width + translation.x, height: height)
                } else {
                    cropFrame = CGRect(x: minX, y: minY + translation.y, width: width + translation.x, height: height - translation.y)
                }
            case cropView.btnBotRight:
                if width + translation.x < minWidth || height + translation.y < minHegith {
                    return
                } else if width + translation.x > width && height + translation.y > height {
                    cropFrame = self.panStartCropFrame
                } else if width + translation.x > width {
                    cropFrame = CGRect(x: minX, y: minY, width: width, height: height + translation.y)
                } else if height + translation.y > height {
                    cropFrame = CGRect(x: minX, y: minY, width: width + translation.x, height: height)
                } else {
                    cropFrame = CGRect(x: minX, y: minY, width: width + translation.x, height: height + translation.y)
                }
            case cropView.btnBotLeft:
                if width - translation.x < minWidth || height + translation.y < minHegith {
                    return
                } else if width - translation.x > width && height + translation.y > height {
                    cropFrame = self.panStartCropFrame
                } else if width - translation.x > width {
                    cropFrame = CGRect(x: minX, y: minY, width: width, height: height + translation.y)
                } else if height + translation.y > height {
                    cropFrame = CGRect(x: minX + translation.x, y: minY, width: width - translation.x, height: height)
                } else {
                    cropFrame = CGRect(x: minX + translation.x, y: minY, width: width - translation.x, height: height + translation.y)
                }
            case cropView.btnTopLine:
                if height - translation.y < minHegith {
                    return
                } else if height - translation.y > height {
                    cropFrame = self.panStartCropFrame
                } else {
                    cropFrame = CGRect(x: minX, y: minY + translation.y, width: width, height: height - translation.y)
                }
            case cropView.btnBotLine:
                if height + translation.y < minHegith {
                    return
                } else if height + translation.y > height {
                    cropFrame = self.panStartCropFrame
                } else {
                    cropFrame = CGRect(x: minX, y: minY, width: width, height: height + translation.y)
                }
            case cropView.btnLeftLine:
                if width - translation.x < minWidth {
                    return
                } else if width - translation.x > width {
                    cropFrame = self.panStartCropFrame
                } else {
                    cropFrame = CGRect(x: minX + translation.x, y: minY, width: width - translation.x, height: height)
                }
            case cropView.btnRightLine:
                if width + translation.x < minWidth {
                    return
                } else if width + translation.x > width {
                    cropFrame = self.panStartCropFrame
                } else {
                    cropFrame = CGRect(x: minX, y: minY, width: width + translation.x, height: height)
                }
            default:
                print("unknown button")
                return
            }
            
            ///update cropView frame during .changed state
            cropView.updateCropFrame(finalCropFrame: cropFrame)
            ///save current changed cropView frame for use in .end state
            panEndCropFrame = cropFrame
            ///update hide area
            updateHideView(cropFrame: cropFrame)
        }
        
        if gestureRecognizer.state == .ended {
            if panEndCropFrame == self.panStartCropFrame { return }
            let finalZoomFrame = countFinalZoomFrame(fromFrame: panEndCropFrame)
            
            if cropImageView.updateToZoomFrame(panStartCropFrame: panStartCropFrame,
                                               panEndCropFrame: panEndCropFrame,
                                               finalZoomFrame: finalZoomFrame) == false {
                cropView.updateCropFrame(finalCropFrame: panStartCropFrame)
                updateHideView(cropFrame: panStartCropFrame)
            } else {
                cropView.updateCropFrameWithAnimation(startCropFrame: panEndCropFrame, finalCropFrame: finalZoomFrame)
                updateHideViewWithAnimation(startCropFrame: panEndCropFrame, endCropFrame: finalZoomFrame)
            }
        }
    }
    
    
    ///
    /// Count new crop frame after pan has ended
    /// Max frame available for cropViewFrame was set in init function
    ///
    private func countFinalZoomFrame(fromFrame: CGRect) -> CGRect {
        
        let scale = min(maxCropFrame.width / fromFrame.width, maxCropFrame.height / fromFrame.height)
        let size = CGSize(width: fromFrame.width * scale, height: fromFrame.height * scale)
        let xPoint = maxCropFrame.origin.x + (maxCropFrame.width - size.width) / 2
        let yPoint = maxCropFrame.origin.y + (maxCropFrame.height - size.height) / 2
        
        let rect = CGRect(x: xPoint, y: yPoint, width: size.width, height: size.height)
        return rect
    }
}
