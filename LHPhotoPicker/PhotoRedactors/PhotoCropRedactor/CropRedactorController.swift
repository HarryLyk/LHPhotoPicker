//
//  CropRedactorController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 26.12.2020.
//

import UIKit

class CropRedactorController: UIViewController {

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
    
    let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBlue
        return scrollView
    }()
    
    var viewModel: CropRedactorViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupConstraints()
    }
    
    func setupConstraints() {
        
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        btnCancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        btnApply.translatesAutoresizingMaskIntoConstraints = false
        btnApply.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        btnApply.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        btnApply.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnApply.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageScrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageScrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: btnCancel.topAnchor, constant: -20).isActive = true
    }
    
    func addSubviews() {
        view.addSubview(btnApply)
        view.addSubview(btnCancel)
        view.addSubview(imageScrollView)
    }
}
