//
//  PhotoSelectionController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 05.11.2020.
//

import UIKit
import Photos
import RxCocoa
import RxSwift

class PhotoSelectionController: UIViewController {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    
    static var identificator: String {
        return String(describing: self)
    }
    
    var activityIndicator: UIActivityIndicatorView!
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
                DispatchQueue.main.async {
                    self?.hideActivityIndicator(view: self!.photoCollectionView)
                    self?.photoCollectionView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        fetchPhotoIfPermited()
    }
    
    
    private func fetchPhotoIfPermited() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                ///start activity indicator
                DispatchQueue.main.async {
                    self.showActivityIndicator(view: self.view)
                }
                self.viewModel.loadMediaData(fetchMediaType: .image)
                return
            default:
                self.showAccessRequest()
            }
        }
    }
        
    private func showAccessRequest() {
        let alert = UIAlertController(title: "No photo access", message: "Please allow LHPhotoPicker to access photo library", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
            print("access not granted")
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:])
            } else {
                print("Can't open Settings")
            }
        }))
    }
    
    
    /// If cancell was pressed show, no photo access view
    private func cancelPressed() {
        //let noPhotoesView = UIView()
        //noPhotoesView.layer.frame.width =
        
    }
    
    private func showActivityIndicator(view: UIView) {
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator(style: .large)
        }
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func createActivityIndicator(style: UIActivityIndicatorView.Style) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }
    
    private func hideActivityIndicator(view: UIView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    
    ///configure collection view according to set viewModel data
    private func setupCollectionView() {
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(UINib(nibName: PhotoSelectionCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoSelectionCell.reuseIdentifier)
        
        ///setup cell size data
        let collectionViewWidth = photoCollectionView.bounds.width
        let cellInRow = getCurrentOrientationCellCount()
        let cellSize = (collectionViewWidth - (viewModel.minimumInteritemSpacing * CGFloat(cellInRow - 1))) / CGFloat(cellInRow)
        
        ///set scale factor, which align space between cells according to set minimumInteritemSpacing and additional scale factor
        //cellSize = cellSize - ((cellSize/100)*3.2) + getOrientationScaleFactor()
        
        ///apply viewModel data to collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = viewModel.minimumInteritemSpacing
        layout.minimumLineSpacing = viewModel.minimumLineSpacing
        layout.itemSize = CGSize(width: cellSize, height: cellSize)

        photoCollectionView.collectionViewLayout = layout
    }
    
    
    ///get cell count for different screen orientation if set
    ///the default values are 3 cells in a row for portriant and 5 for landscape
    private func getCurrentOrientationCellCount() -> Int {
        
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
    private func getOrientationScaleFactor() -> CGFloat {
        
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
        
        cell.isPhotoSelected
            .subscribe(onNext: { [weak self] (isSelected) in
                if isSelected == true {
                    guard let addImage = cell.imageView.image else {
                        return
                    }
                    self?.viewModel.addSelectedItems(indexPath: indexPath, addItem: addImage)
                } else {
                    self?.viewModel.deleteDeselectedPhoto(indexPath: indexPath)
                }
            })
            .disposed(by: disposeBag)
        
        cell.imageView.image = viewModel.fetchedItems[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ///if we select cell show that image on new view controller
        print("selected: ", indexPath.row)
    }
}

