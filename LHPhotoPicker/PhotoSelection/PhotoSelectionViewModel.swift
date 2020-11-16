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
    var cellInRowPortriant: Int = 3
    var cellInRowLandscape: Int = 5
    var minimumInteritemSpacing: CGFloat = 1
    var minimumLineSpacing: CGFloat = 1
    
    ///because minimumInteritemSpacing value is 'recomended', size of cell may be
    ///counted incorrect, so the additional scale factor is needed sometimes
    var cellSizePortriantScaleFactor: CGFloat = 0
    var cellSizeLandscapeScaleFactor: CGFloat = 0
    
    var isLoading: BehaviorRelay<Bool> = .init(value: true)
    var isOrientationChanged: BehaviorRelay<Bool> = .init(value: true)
    var newCellTotalCount: PublishRelay<Int> = .init()
    
    var fetchedItems: [UIImage] = []
    var selectedItems: [IndexPath : UIImage] = [:]
    
    private var disposeBag = DisposeBag()
    
    ///set new cell count if changed (new photoes or whatever)
    func setTotalSetCount(totalCellCount: Int) {
        self.totalCellCount = totalCellCount
        newCellTotalCount.accept(totalCellCount)
    }
    
    init(cellInRowPortriant: Int, cellInRowLandscape: Int?) {
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
                    self.fetchedItems.append(image!)
                })
            }
        }
        
        setTotalSetCount(totalCellCount: fetchedItems.count)
    }
    
    
    func addSelectedItems(indexPath: IndexPath, addItem: UIImage) {
        selectedItems.updateValue(addItem, forKey: indexPath)
        print("total selected: ", selectedItems.count)
    }
    
    
    func deleteDeselectedPhoto(indexPath: IndexPath) {
        selectedItems.removeValue(forKey: indexPath)
        print("after deselect: ", selectedItems.count)
    }
}
