//
//  CropRedactorViewModel.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 26.12.2020.
//

import UIKit

protocol CropRedactorDelegate: class {
    func obtainEditedImageView(editedImage: UIImage)
}

class CropRedactorViewModel {
    
    var image: UIImage
    weak var delegate: CropRedactorDelegate?
    
    init(image: UIImage) {
        self.image = image
    }
    
    func setEditedImageView(editedImage: UIImage){
        self.delegate?.obtainEditedImageView(editedImage: editedImage)
    }
}
