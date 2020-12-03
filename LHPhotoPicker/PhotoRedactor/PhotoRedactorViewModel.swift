//
//  PhotoRedactorViewModel.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 17.11.2020.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

class PhotoRedactorViewModel {
    var selectedPhoto: UIImage
    
    init(selectedPhoto: UIImage) {
        self.selectedPhoto = selectedPhoto
    }
}
