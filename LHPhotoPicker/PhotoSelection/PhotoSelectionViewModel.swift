//
//  PhotoSelectionViewModel.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 05.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

class PhotoSelectionViewModel {
    
    ///collection controller default parameters
    var totalCellCount: Int = 1
    var backgroundColor: UIColor = .white
    var cellInRowPortriant: Int = 3
    var cellInRowLandscape: Int = 5
    var minimumInteritemSpacing: CGFloat = 1
    var minimumLineSpacing: CGFloat = 1
    
    ///because minimumInteritemSpacing value is 'recomended', size of cell may be
    ///counted incorrect, so the additional scale factor is needed sometimes
    var cellSizePortriantScaleFactor: CGFloat = 0
    var cellSizeLandscapeScaleFactor: CGFloat = 0
    
    ///this flag is true, cause we are trying to load photoes by default
    var isLoading: BehaviorRelay<Bool> = .init(value: true)
    ///this flag means that orientation has changed
    var isOrientationChanged: BehaviorRelay<Bool> = .init(value: true)
    ///if cell count changed
    var newCellTotalCount: PublishRelay<Int> = .init()
    
    ///set new cell count if changed (new photoes or whatever)
    func setTotalSetCount(totalCellCount: Int) {
        self.totalCellCount = totalCellCount
        newCellTotalCount.accept(totalCellCount)
    }
    
    private var disposeBag = DisposeBag()
    
    init(cellInRowPortriant: Int, cellInRowLandscape: Int?) {
        self.cellInRowPortriant = cellInRowPortriant
        if cellInRowLandscape != nil {
            self.cellInRowLandscape = cellInRowLandscape!
        }
    }
    
    
    
    ///load photoes from local storage
    func loadPhotos() {
        self.setTotalSetCount(totalCellCount: 10)
        
        //don't forget to check if user give us acces to load photoes
        
        //load photoes with error checking
    }
}
