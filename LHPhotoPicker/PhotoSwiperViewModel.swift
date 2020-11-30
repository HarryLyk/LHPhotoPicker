//
//  PhotoSwiperViewModel.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 21.11.2020.
//

import UIKit
import Photos

class PhotoSwiperViewModel {
    
    var assets: PHFetchResult<PHAsset>
    var selectedPhotoes: [Int : UIImage] = [:]
    
    init(assets: PHFetchResult<PHAsset>) {
        self.assets = assets
    }
    
}

