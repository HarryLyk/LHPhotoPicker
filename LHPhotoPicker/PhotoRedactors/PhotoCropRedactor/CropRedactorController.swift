//
//  CropRedactorController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 26.12.2020.
//

import UIKit
import RxCocoa
import RxSwift

class CropRedactorController: UIViewController, CropViewDelegate {
    
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
    
    var imageScrollView: ImageScrollView = {
        let imageScrollView = ImageScrollView()
        return imageScrollView
    }()
    
    var cropView: CropView = {
        let view = CropView()
        return view
    }()
    
    
    let botBtnConstr: CGFloat = 30  //constraint between bottom button anchor and view anchor
    let btnHeight: CGFloat = 40     //button height
    let botScrollViewConstr: CGFloat = 60 //constraint between top button anchor and bottom view anchor
    let topScrollViewConstr: CGFloat = 60  //constraint between scroll view and top anchors
    let svHorisontalConstr: CGFloat = 30//constraint between scroll view and left, right anchors
    
    var viewModel: CropRedactorViewModel!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupConstraints()
        setupRx()
        
        cropView.delegate = self
    }
    
    func addSubviews() {
        view.addSubview(btnApply)
        view.addSubview(btnCancel)
        
        ///count frame size of view which will present image and crop redactor view
        let heightToView = btnHeight + botBtnConstr + botScrollViewConstr + topScrollViewConstr
        let viewFrame = CGRect(x: view.frame.origin.x + svHorisontalConstr,
                               y: view.frame.origin.y + topScrollViewConstr,
                               width: view.frame.width - svHorisontalConstr * 2,
                               height: view.frame.height - heightToView)
        
        imageScrollView.frame = viewFrame
        view.addSubview(imageScrollView)
        imageScrollView.setImageZoomView(image: self.viewModel.image)
        
        cropView.frame = viewFrame
        view.addSubview(cropView)
        cropView.setCropImageView(image: self.viewModel.image)
    }
    
    func setupConstraints() {
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
        
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: topScrollViewConstr).isActive = true
        imageScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: svHorisontalConstr).isActive = true
        imageScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -svHorisontalConstr).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: btnCancel.topAnchor, constant: -botScrollViewConstr).isActive = true
        
        cropView.translatesAutoresizingMaskIntoConstraints = false
        cropView.topAnchor.constraint(equalTo: view.topAnchor, constant: topScrollViewConstr).isActive = true
        cropView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: svHorisontalConstr).isActive = true
        cropView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -svHorisontalConstr).isActive = true
        cropView.bottomAnchor.constraint(equalTo: btnCancel.topAnchor, constant: -botScrollViewConstr).isActive = true
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
    
    func sendCustomZoom(zoomRect: CGRect, centerPoint: CGPoint) {
        //print("CropRedacotrController: perform zoom to rect delegate fucntion")
        self.imageScrollView.performCustomZoom(customZoomRect: zoomRect, centerPoint: centerPoint)
    }
}


