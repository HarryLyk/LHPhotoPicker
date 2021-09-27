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
//        imageView.layer.borderWidth = 2
//        imageView.layer.borderColor = UIColor.systemRed.cgColor
        return imageView
    }()
    
    var cropView: CropView = {
        let view = CropView(frame: CGRect())
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGreen.cgColor
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
    
    
    let botBtnConstr: CGFloat = 30              //constraint between bottom button anchor and view anchor
    let btnHeight: CGFloat = 40                 //button height
    let topBtnConstr: CGFloat = 50              //constraint between top button anchor and bottom cropImageView anchor
    let topCropImageViewConsraint: CGFloat = 50 //constraint between cropImageView and top anchors
    let svHorisontalConstr: CGFloat = 20        //constraint between cropView and left, right anchors
    var botCropImageViewConstraint: CGFloat = 0 //constraint between imageCropView and bottom view border.
    
    var panStartCropFrame: CGRect = CGRect()
    var panEndCropFrame: CGRect = CGRect()
    var cropMaxFrame: CGRect = CGRect()
    
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
    }
    
    func setupSubviews() {
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        btnCancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -botBtnConstr).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: btnHeight).isActive = true
        
        btnApply.translatesAutoresizingMaskIntoConstraints = false
        btnApply.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        btnApply.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -botBtnConstr).isActive = true
        btnApply.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnApply.heightAnchor.constraint(equalToConstant: btnHeight).isActive = true
        
        ///set maximum area, available for image
        let heightToView = btnHeight + botBtnConstr + topBtnConstr + topCropImageViewConsraint
        cropMaxFrame = CGRect(x: view.frame.origin.x + svHorisontalConstr,
                               y: view.frame.origin.y + topCropImageViewConsraint,
                               width: view.frame.width - svHorisontalConstr * 2,
                               height: view.frame.height - heightToView)
        
        ///
        ///  Setup cropImageView frame, so cropImageView could count image XY and size
        ///  parameters according to superview (this controller) XY coordinates
        ///
        if cropImageView.setupCropImageView(maxCropImageViewFrame: cropMaxFrame, image: viewModel.image, maxScale: 3.5) == false {
            self.dismiss(animated: true, completion: nil)
        }
        if cropView.setupCropView(maxCropViewFrame: cropMaxFrame, frame: cropImageView.frame) == false {
            self.dismiss(animated: true, completion: nil)
        }
        
        ///Set max bottom constraint for cropImageView
        botCropImageViewConstraint = botBtnConstr + btnHeight + topBtnConstr
        
        ///Setup pan handler function for cropView buttons
        cropView.setCropBtnPan(target: self, action: #selector(handleCropBtnPan(_:)))
        cropView.addPangestureRecognizers()
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
            
            cropView.updateCropFrame(finalCropFrame: cropFrame)
            panEndCropFrame = cropFrame
        }
        
        if gestureRecognizer.state == .ended {
            if panEndCropFrame == self.panStartCropFrame { return }
            let finalZoomFrame = countFinalZoomFrame(fromFrame: panEndCropFrame)
            
            if cropImageView.updateToZoomFrame(panStartCropFrame: panStartCropFrame,
                                               panEndCropFrame: panEndCropFrame,
                                               finalZoomFrame: finalZoomFrame) == false {
                cropView.updateCropFrame(finalCropFrame: panStartCropFrame)
            } else {
                cropView.updateCropFrame(finalCropFrame: finalZoomFrame)
            }
        }
    }
    
    
    ///
    /// Count new crop frame after pan has ended
    /// Max frame available - cropViewFrame was set at init function
    ///
    private func countFinalZoomFrame(fromFrame: CGRect) -> CGRect {
        
        let scale = min(cropMaxFrame.width / fromFrame.width, cropMaxFrame.height / fromFrame.height)
        let size = CGSize(width: fromFrame.width * scale, height: fromFrame.height * scale)
        let xPoint = cropMaxFrame.origin.x + (cropMaxFrame.width - size.width) / 2
        let yPoint = cropMaxFrame.origin.y + (cropMaxFrame.height - size.height) / 2
        
        let rect = CGRect(x: xPoint, y: yPoint, width: size.width, height: size.height)
        return rect
    }
}
