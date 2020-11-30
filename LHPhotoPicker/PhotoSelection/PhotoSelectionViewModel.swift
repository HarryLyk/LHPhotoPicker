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
    
    var isOrientationChanged: BehaviorRelay<Bool> = .init(value: true)
    var newCellTotalCount: PublishRelay<Int> = .init()
    
    var assets: PHFetchResult<PHAsset> = .init()
    var selectedPhotoes: [Int : UIImage] = [:]
    
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
    
    
    ///load assets from photo manager and tells collection controller to reload it's data
    func loadAssets(fetchMediaType: PHAssetMediaType) {
        let fetchOptions = PHFetchOptions()
        assets = PHAsset.fetchAssets(with: fetchMediaType, options: fetchOptions)

        self.setTotalSetCount(totalCellCount: assets.count)
    }
    
    func addSelectedPhoto(index: Int, addPhotoes: UIImage) {
        selectedPhotoes.updateValue(addPhotoes, forKey: index)
    }
    
    func deleteDeselectedPhoto(index: Int) {
        selectedPhotoes.removeValue(forKey: index)
    }
    
    func showSwiperController(sourceView: UIViewController) {
        
        let layout = UICollectionViewFlowLayout()
        let swipeCollectionController = PhotoSwiperController(collectionViewLayout: layout)
        let photoSwiperViewModel = PhotoSwiperViewModel(assets: self.assets)
        photoSwiperViewModel.selectedPhotoes = selectedPhotoes
        swipeCollectionController.viewModel = photoSwiperViewModel
        swipeCollectionController.modalPresentationStyle = .fullScreen
        sourceView.present(swipeCollectionController, animated: true)
    }
}
