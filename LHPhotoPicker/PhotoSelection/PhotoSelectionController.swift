//
//  PhotoSelectionController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 05.11.2020.
//

import UIKit
import RxCocoa
import RxSwift

class PhotoSelectionController: UIViewController {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    
    static var identificator: String {
        return String(describing: self)
    }
    
    var viewModel: PhotoSelectionViewModel!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        
        viewModel.isLoading
            .subscribe(onNext: {
                flag in print("new flag value :", flag)
                ///start or stop loading animation view
            })
            .disposed(by: disposeBag)
        
        ///reload collection view if new cell count was set
        viewModel.newCellTotalCount
            .subscribe(onNext: {
                [weak self] totalCellCount in
                self?.viewModel.totalCellCount = totalCellCount
                self?.photoCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.loadPhotos()
    }
    
    
    ///configure collection view according to set viewModel data
    func setupCollectionView() {
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(UINib(nibName: PhotoSelectionCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoSelectionCell.reuseIdentifier)
        
        ///setup cell size data
        let collectionViewWidth = photoCollectionView.bounds.width
        let cellInRow = getCurrentOrientationCellCount()
        var cellSize = ((collectionViewWidth - (viewModel.minimumInteritemSpacing * CGFloat(cellInRow - 1))) / CGFloat(cellInRow))
        
        ///set scale factor, which align space between cells according to set minimumInteritemSpacing and additional scale factor
        cellSize = cellSize + ((cellSize/100)*2.95) + getOrientationScaleFactor()
        
        ///apply viewModel data to collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = viewModel.minimumInteritemSpacing
        layout.minimumLineSpacing = viewModel.minimumLineSpacing
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        photoCollectionView.collectionViewLayout = layout
        
        
        
        photoCollectionView.backgroundColor = .lightGray
    }
    
    
    ///get cell count for different screen orientation if set
    ///the default values are 3 cells in a row for portriant and 5 for landscape
    func getCurrentOrientationCellCount() -> Int {
        
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown, .unknown:
            return viewModel.cellInRowPortriant
        case .landscapeLeft, .landscapeRight:
            return viewModel.cellInRowLandscape
        @unknown default:
            return viewModel.cellInRowPortriant
        }
    }
    
    
    ///get additional scale factor if set to the cell size
    ///the default values are 0
    func getOrientationScaleFactor() -> CGFloat {
        
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown, .unknown:
            return viewModel.cellSizePortriantScaleFactor
        case .landscapeLeft, .landscapeRight:
            return viewModel.cellSizeLandscapeScaleFactor
        @unknown default:
            return viewModel.cellSizePortriantScaleFactor
        }
    }
}

extension PhotoSelectionController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalCellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: PhotoSelectionCell.reuseIdentifier, for: indexPath) as? PhotoSelectionCell else {
            return UICollectionViewCell()
        }
        
        cell.backgroundColor = .systemGreen
        return cell
    }
}
