//
//  CropRedactorViewModel.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 26.12.2020.
//

import UIKit

protocol CropRedactorDelegate: class {
    func obtainEditedImageView(editedImageView: UIImageView)
}

class CropRedactorViewModel {
    
    var imageView: UIImageView
    weak var delegate: CropRedactorDelegate?
    
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
    func setEditedImageView(editedImageView: UIImageView){
        self.delegate?.obtainEditedImageView(editedImageView: editedImageView)
    }
}
