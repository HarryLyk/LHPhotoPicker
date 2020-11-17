//
//  PhotoRedactorController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 17.11.2020.
//

import UIKit
import RxCocoa
import RxSwift

class PhotoRedactorController: UIViewController {

    static var identificator: String {
        return String(describing: self)
    }
    
    let imageView: UIImageView = {
        return UIImageView()
    }()
    let redactorView: UIView = {
       return UIView()
    }()
    let btnEdit: UIButton = {
       return UIButton()
    }()
    let btnCancel: UIButton = {
        return UIButton()
    }()
    
    var viewModel: PhotoRedactorViewModel!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        view.addSubview(redactorView)
        redactorView.addSubview(btnEdit)
        redactorView.addSubview(btnCancel)
        
        setupLayout()
        setupRx()
    }
    
    private func setupRx() {
        btnEdit.rx.tap
            .subscribe(onNext: {
                _ in
                print("Edit was tapped")
            })
            .disposed(by: disposeBag)
        
        btnCancel.rx.tap.subscribe(onNext: {
            [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        imageView.image = viewModel.image
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: redactorView.topAnchor, constant: -20).isActive = true
        
        redactorView.translatesAutoresizingMaskIntoConstraints = false
        redactorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        redactorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        redactorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        redactorView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
//        redactorView.layer.borderWidth = 1
//        redactorView.layer.borderColor = UIColor.white.cgColor
        
        setupRedactorViewItems()
    }
    
    private func setupRedactorViewItems() {
        btnEdit.translatesAutoresizingMaskIntoConstraints = false
        btnEdit.topAnchor.constraint(equalTo: redactorView.topAnchor, constant: 5).isActive = true
        btnEdit.rightAnchor.constraint(equalTo: redactorView.rightAnchor, constant: -20).isActive = true
        btnEdit.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnEdit.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        btnEdit.setTitle("Edit", for: .normal)
        btnEdit.setTitleColor(.white, for: .normal)
        btnEdit.titleLabel?.font = .systemFont(ofSize: 20)
        btnEdit.titleLabel?.textAlignment = .center
        
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.topAnchor.constraint(equalTo: redactorView.topAnchor, constant: 5).isActive = true
        btnCancel.leftAnchor.constraint(equalTo: redactorView.leftAnchor, constant: 20).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(.white, for: .normal)
        btnCancel.titleLabel?.font = .systemFont(ofSize: 20)
        btnCancel.titleLabel?.textAlignment = .center
        
    }
}

