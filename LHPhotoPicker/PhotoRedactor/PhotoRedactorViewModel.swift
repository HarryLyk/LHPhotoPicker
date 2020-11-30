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
    var selectedPhotoes: [IndexPath : UIImage]
    
    init(selectedPhotoes: [IndexPath : UIImage]) {
        self.selectedPhotoes = selectedPhotoes
    }
}
