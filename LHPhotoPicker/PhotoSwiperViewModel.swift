//
//  PhotoSwiperViewModel.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 21.11.2020.
//

import UIKit
import Photos

protocol PhotoSwiperDelegate: class {
    func obtainSeectedPhotoes(selectedPhotoes: [Int: UIImage])
}

class PhotoSwiperViewModel {
    
    var assets: PHFetchResult<PHAsset>
    var selectedPhotoes: [Int : UIImage] = [:]
    var scrollToIndex: Int
    weak var delegate: PhotoSwiperDelegate?
    
    init(assets: PHFetchResult<PHAsset>, scrollToIndex: Int) {
        self.assets = assets
        self.scrollToIndex = scrollToIndex
    }
    
    func addSelectedPhoto(index: Int, addPhotoes: UIImage) {
        selectedPhotoes.updateValue(addPhotoes, forKey: index)
    }
    
    func deleteDeselectedPhoto(index: Int) {
        selectedPhotoes.removeValue(forKey: index)
    }
    
    func setSelectedPhotoOnApply(selectedPhotoes: [Int: UIImage]) {
        self.delegate?.obtainSeectedPhotoes(selectedPhotoes: selectedPhotoes)
    }
}

