//
//  CropRedactorView.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 31.12.2020.
//

import UIKit

protocol CropViewDelegate: AnyObject {
    
}

class CropView: UIView {
    
    weak var delegate: CropViewDelegate?
    
    let btnTopLeft: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemTeal.cgColor
        return button
    }()
    
    let btnTopRight: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemTeal.cgColor
        return button
    }()
    
    let btnBotRight: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemTeal.cgColor
        return button
    }()
    
    let btnBotLeft: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemTeal.cgColor
        return button
    }()
    
    let btnTopLine: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemTeal.cgColor
        return button
    }()
    
    let btnRightLine: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemTeal.cgColor
        return button
    }()
    
    let btnBotLine: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemTeal.cgColor
        return button
    }()
    
    let btnLeftLine: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemTeal.cgColor
        return button
    }()
    
    //
    //  Parent class can setup pan gsetures if required
    //
    var btnTopLeftPan: UIPanGestureRecognizer?
    var btnTopRightPan: UIPanGestureRecognizer?
    var btnBotRightPan: UIPanGestureRecognizer?
    var btnBotLeftPan: UIPanGestureRecognizer?
    var btnTopLinePan: UIPanGestureRecognizer?
    var btnBotLinePan: UIPanGestureRecognizer?
    var btnRightLinePan: UIPanGestureRecognizer?
    var btnLeftLinePan: UIPanGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let btnWidth: CGFloat = 40
    let btnHeight: CGFloat = 40
    let minLineWidth: CGFloat = 40  /// If btnTopLine or btnBotLine less then that value, it's button view will not be added
    let minLineHeight: CGFloat = 40 /// If btnRightLine or btnLeftLine less then that value, it's button view will not be added
    var minCropWidth: CGFloat = 10   /// minimum cropView width, when handle pan gesture
    var minCropHeight: CGFloat = 10  /// minimum cropView height, when handle pan gesture
    var maxFrame: CGRect = .init()
    
    func setupCropView(maxCropViewFrame: CGRect, frame: CGRect) -> Bool {

        if (frame.size.width < btnWidth * 2) || (frame.size.height < btnHeight * 2) { return false }
        
        self.frame = frame
        self.maxFrame = maxCropViewFrame
        removeCropViews()
        addCropViews()
        return configureCropViewButtons(size: frame.size)
    }
    
    
    private func removeCropViews() {
        
        btnTopLeft.removeFromSuperview()
        btnTopRight.removeFromSuperview()
        btnBotRight.removeFromSuperview()
        btnBotLeft.removeFromSuperview()
        
        btnTopLine.removeFromSuperview()
        btnRightLine.removeFromSuperview()
        btnBotLine.removeFromSuperview()
        btnLeftLine.removeFromSuperview()
    }
    
    
    private func addCropViews() {
        
        self.addSubview(btnTopLeft)
        self.addSubview(btnTopRight)
        self.addSubview(btnBotRight)
        self.addSubview(btnBotLeft)
        
        self.addSubview(btnTopLine)
        self.addSubview(btnRightLine)
        self.addSubview(btnBotLine)
        self.addSubview(btnLeftLine)
    }
    
    
    func updateCropView(newCropFrame: CGRect) {
        self.frame = newCropFrame
        configureCropViewButtons(size: newCropFrame.size)
    }
    
    func configureCropViewButtons(size: CGSize) -> Bool{

        let rightX = self.bounds.origin.x + (self.bounds.width - btnWidth)
        let botY = self.bounds.origin.y + (self.bounds.height - btnHeight)
        
        ///Setup buttons frame
        btnTopLeft.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: btnWidth, height: btnHeight)
        btnTopRight.frame = CGRect(x: rightX, y: self.bounds.origin.y, width: btnWidth, height: btnHeight)
        btnBotRight.frame = CGRect(x: rightX, y: botY, width: btnWidth, height: btnHeight)
        btnBotLeft.frame = CGRect(x: self.bounds.origin.x, y: botY, width: btnWidth, height: btnHeight)
        
        ///Setup horisontal buttons frame
        if size.width > btnWidth * 2 + minLineWidth {
            let lineWidth = self.bounds.width - btnWidth * 2
            btnTopLine.frame = CGRect(x: self.bounds.origin.x + btnWidth, y: self.bounds.origin.y, width: lineWidth, height: btnHeight)
            btnBotLine.frame = CGRect(x: self.bounds.origin.x + btnWidth, y: botY, width: lineWidth, height: btnHeight)
        }
        
        /// Setup vertical buttons frame
        if size.height > btnHeight * 2 + minLineHeight {
            let lineHeight = self.bounds.height - btnHeight * 2
            btnRightLine.frame = CGRect(x: rightX, y: self.bounds.origin.y + btnHeight, width: btnWidth, height: lineHeight)
            btnLeftLine.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + btnHeight, width: btnWidth, height: lineHeight)
        }
        
        ///Setup minimum crop border line size
        minCropWidth = btnWidth * 2
        minCropHeight = btnHeight * 2
        
        return true
    }
    
    /// Setup corner buttons pan gestures
    func setCropBtnPan(target: Any?, action: Selector) {
        
        btnTopLeftPan = UIPanGestureRecognizer(target: target, action: action)
        btnTopRightPan = UIPanGestureRecognizer(target: target, action: action)
        btnBotRightPan = UIPanGestureRecognizer(target: target, action: action)
        btnBotLeftPan = UIPanGestureRecognizer(target: target, action: action)
        btnTopLinePan = UIPanGestureRecognizer(target: target, action: action)
        btnBotLinePan = UIPanGestureRecognizer(target: target, action: action)
        btnRightLinePan = UIPanGestureRecognizer(target: target, action: action)
        btnLeftLinePan = UIPanGestureRecognizer(target: target, action: action)
    }
    
    /// Add pan gesture recognizer if exists
    func addPangestureRecognizers() {
        
        if btnTopLeftPan != nil {
            btnTopLeft.addGestureRecognizer(btnTopLeftPan!)
        }  else {
            print("btnTopLeftPan add gesture recognizer error")
        }
        
        if btnTopRightPan != nil {
            btnTopRight.addGestureRecognizer(btnTopRightPan!)
        } else {
            print("btnTopRightPan add gesture recognizer error")
        }
        
        if btnBotRightPan != nil {
            btnBotRight.addGestureRecognizer(btnBotRightPan!)
        } else {
            print("btnBotRightPan add gesture recognizer error")
        }
        
        if btnBotLeftPan != nil {
            btnBotLeft.addGestureRecognizer(btnBotLeftPan!)
        } else {
            print("btnBotLeftPan add gesture recognizer error")
        }
        
        if btnTopLinePan != nil {
            btnTopLine.addGestureRecognizer(btnTopLinePan!)
        } else {
            print("btnTopLinePan add gesture recognizer error")
        }
        
        if btnBotLinePan != nil{
            btnBotLine.addGestureRecognizer(btnBotLinePan!)
        } else {
            print("btnBotLinePan add gesture recognizer error")
        }
        
        if btnRightLinePan != nil{
            btnRightLine.addGestureRecognizer(btnRightLinePan!)
        } else {
            print("btnRightLinePan add gesture recognizer error")
        }
        
        if btnLeftLinePan != nil{
            btnLeftLine.addGestureRecognizer(btnLeftLinePan!)
        } else {
            print("btnLeftLinePan add gesture recognizer error")
        }
    }
}
