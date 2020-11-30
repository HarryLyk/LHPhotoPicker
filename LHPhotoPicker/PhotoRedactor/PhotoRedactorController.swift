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
    
    let imageRedactorView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let redactorControlsView: UIView = {
       return UIView()
    }()
    
    let btnEdit: UIButton = {
        let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let btnCancel: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    var viewModel: PhotoRedactorViewModel!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageRedactorView)
        view.addSubview(redactorControlsView)
        redactorControlsView.addSubview(btnEdit)
        redactorControlsView.addSubview(btnCancel)
        
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
        
        ///show only first image for now
        imageRedactorView.image = viewModel.selectedPhotoes.values.first
        
        imageRedactorView.translatesAutoresizingMaskIntoConstraints = false
        imageRedactorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        imageRedactorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imageRedactorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imageRedactorView.bottomAnchor.constraint(equalTo: redactorControlsView.topAnchor, constant: -20).isActive = true
        
        redactorControlsView.translatesAutoresizingMaskIntoConstraints = false
        redactorControlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        redactorControlsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        redactorControlsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        redactorControlsView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
//        redactorView.layer.borderWidth = 1
//        redactorView.layer.borderColor = UIColor.white.cgColor
        
        setupRedactorControlLayout()
    }
    
    private func setupRedactorControlLayout() {
        btnEdit.translatesAutoresizingMaskIntoConstraints = false
        btnEdit.topAnchor.constraint(equalTo: redactorControlsView.topAnchor, constant: 5).isActive = true
        btnEdit.rightAnchor.constraint(equalTo: redactorControlsView.rightAnchor, constant: -20).isActive = true
        btnEdit.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnEdit.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.topAnchor.constraint(equalTo: redactorControlsView.topAnchor, constant: 5).isActive = true
        btnCancel.leftAnchor.constraint(equalTo: redactorControlsView.leftAnchor, constant: 20).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
}

