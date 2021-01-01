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
    
//    let photoImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
    
    let imageScrollView: ImageScrollView = {
        let scrollView = ImageScrollView()
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addScrollView(frame: frame)
        //addSubview(photoImageView)
        setupLayout()
    }
    
    func addScrollView(frame: CGRect) {
        imageScrollView.frame = frame
        addSubview(imageScrollView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout(){
        ///setup photo image view constraints
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80).isActive = true
        imageScrollView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        imageScrollView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
}
