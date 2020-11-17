//
//  PhotoSelectionViewModel.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 05.11.2020.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

class PhotoSelectionViewModel {
    
    ///collection controller default parameters
    var totalCellCount: Int = 0
    var backgroundColor: UIColor = .white
    var cellInRowPortriant: CGFloat = 3
    var cellInRowLandscape: CGFloat = 5
    var minimumInteritemSpacing: CGFloat = 1
    var minimumLineSpacing: CGFloat = 1
    
    var isLoading: BehaviorRelay<Bool> = .init(value: true)
    var isOrientationChanged: BehaviorRelay<Bool> = .init(value: true)
    var newCellTotalCount: PublishRelay<Int> = .init()
    
    var fetchedPhotoes: [UIImage] = []
    var selectedPhotoes: [IndexPath : UIImage] = [:]
    
    private var disposeBag = DisposeBag()
    
    ///set new cell count if changed (new photoes or whatever)
    func setTotalSetCount(totalCellCount: Int) {
        self.totalCellCount = totalCellCount
        newCellTotalCount.accept(totalCellCount)
    }
    
    init(cellInRowPortriant: CGFloat, cellInRowLandscape: CGFloat?) {
        self.cellInRowPortriant = cellInRowPortriant
        if cellInRowLandscape != nil {
            self.cellInRowLandscape = cellInRowLandscape!
        }
    }
    
    
    ///load photoes from local storage and add them to
    func loadMediaData(fetchMediaType: PHAssetMediaType) {
            
        let imageManager = PHImageManager.default()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: fetchMediaType, options: fetchOptions)
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.deliveryMode = .opportunistic
        
        if fetchResult.count > 0 {
            for i in 0..<fetchResult.count {
                imageManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width: 500, height: 500), contentMode: .default, options: imageRequestOptions, resultHandler: { (image, error) in
                    self.fetchedPhotoes.append(image!)
                })
            }
        }
        self.setTotalSetCount(totalCellCount: self.fetchedPhotoes.count)
        
    }
    
    
    func addSelectedPhoto(indexPath: IndexPath, addPhotoes: UIImage) {
        selectedPhotoes.updateValue(addPhotoes, forKey: indexPath)
    }
    
    
    func deleteDeselectedPhoto(indexPath: IndexPath) {
        selectedPhotoes.removeValue(forKey: indexPath)
    }
}
