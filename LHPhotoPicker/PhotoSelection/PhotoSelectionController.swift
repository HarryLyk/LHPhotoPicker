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

        setupCollectionViewWithLayout()
        
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
    private func setupCollectionViewWithLayout() {
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(UINib(nibName: PhotoSelectionCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoSelectionCell.reuseIdentifier)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        ///setup cell size data
        let collectionViewWidth = photoCollectionView.frame.width
        let cellInRow = getCurrentOrientationCellCount()
        let cellSize = (collectionViewWidth - (viewModel.minimumInteritemSpacing * CGFloat(cellInRow - 1))) / CGFloat(cellInRow)
        
        ///apply viewModel data to collection view
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = viewModel.minimumInteritemSpacing
        layout.minimumLineSpacing = viewModel.minimumLineSpacing
        layout.itemSize = CGSize(width: cellSize, height: cellSize)

        photoCollectionView.collectionViewLayout = layout
    }
    
    
    ///get cell count for different screen orientation if set
    ///the default values are 3 cells in a row for portriant and 5 for landscape
    private func getCurrentOrientationCellCount() -> CGFloat {
        
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown, .unknown:
            return viewModel.cellInRowPortriant
        case .landscapeLeft, .landscapeRight:
            return viewModel.cellInRowLandscape
        @unknown default:
            return viewModel.cellInRowPortriant
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
                    self?.viewModel.addSelectedPhoto(indexPath: indexPath, addPhotoes: addImage)
                } else {
                    self?.viewModel.deleteDeselectedPhoto(indexPath: indexPath)
                }
            })
            .disposed(by: disposeBag)
        
        cell.imageView.image = viewModel.fetchedPhotoes[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = photoCollectionView.cellForItem(at: indexPath) as? PhotoSelectionCell else {
            return
        }
        
        let photoRedactorVC = PhotoRedactorController()
        photoRedactorVC.viewModel = PhotoRedactorViewModel(image: cell.imageView.image!)
        photoRedactorVC.modalPresentationStyle = .fullScreen
        photoRedactorVC.modalTransitionStyle = .crossDissolve
        self.present(photoRedactorVC, animated: true)
        
        //self.navigationController?.pushViewController(photoRedactorVC, animated: true)
    }
}

