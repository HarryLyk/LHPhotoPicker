//
//  PhotoSwiperCell.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 21.11.2020.
//

import UIKit

class PhotoSwiperCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        addSubview(photoImageView)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout(){
        ///setup photo image view constraints
        photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        photoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        photoImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
}
