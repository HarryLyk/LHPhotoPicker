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
    
    deinit {
        print("PhotoSelectionController deinit was called")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel.updateSelectedCell == true {
            print("viewWillApera update")
            DispatchQueue.main.async {
                self.photoCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionViewWithLayout()
        setupRx()
        
        fetchPhotoIfPermited()
    }
    
    
    ///configure collection view according to set viewModel data
    private func setupCollectionViewWithLayout() {
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(UINib(nibName: PhotoSelectionCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoSelectionCell.reuseIdentifier)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        ///get cell size data
        let collectionViewWidth = view.frame.width
        let cellInRow = getCurrentOrientationCellCount()
        let cellSize = (collectionViewWidth - (viewModel.minimumInteritemSpacing * CGFloat(cellInRow - 1))) / CGFloat(cellInRow)
        
        
        ///apply viewModel data to collection view
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = viewModel.minimumInteritemSpacing
        layout.minimumLineSpacing = viewModel.minimumLineSpacing
        layout.itemSize = CGSize(width: cellSize, height: cellSize)

        photoCollectionView.isPagingEnabled = false
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
    
    
    private func setupRx() {
        ///reload collection view if new cell count was set
        viewModel.newCellTotalCount
            .subscribe(onNext: {
                [weak self] totalCellCount in
                DispatchQueue.main.async {
                    self?.hideActivityIndicator(view: self!.photoCollectionView)
                    self?.photoCollectionView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    private func fetchPhotoIfPermited() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                ///start activity indicator
                DispatchQueue.main.async {
                    self.showActivityIndicator(view: self.view)
                }
                DispatchQueue.global(qos: .background).async {
                    self.viewModel.loadAssets(fetchMediaType: .image)
                }
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
    
}

extension PhotoSelectionController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalCellCount
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        photoCollectionView.collectionViewLayout.invalidateLayout()
        
        ///perform action when rotate happends
//        guard let firstVisableCell = photoCollectionView.visibleCells.first else { return }
//        guard let firstVisableItem =  photoCollectionView.indexPath(for: firstVisableCell)?.row else { return }
//        let indexPath = IndexPath(item: firstVisableItem, section: 0)
//
//        DispatchQueue.main.async {
//            self.photoCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: PhotoSelectionCell.reuseIdentifier, for: indexPath) as? PhotoSelectionCell else {
            return UICollectionViewCell()
        }

        let cellSize = cell.frame.size.width
        
        PHImageManager.default().requestImage(for: viewModel.assets.object(at: indexPath.row), targetSize: CGSize(width: cellSize, height: cellSize), contentMode: .aspectFill, options: nil, resultHandler: { (image, error) in
            if image != nil {
                cell.imageView.image = image
            }
        })
        
        cell.isPhotoSelected
            .subscribe(onNext: { [weak self] (isSelected) in
                if isSelected == true {
                    guard let addImage = cell.imageView.image else {
                        return
                    }
                    self?.viewModel.addSelectedPhoto(index: indexPath.row, addPhotoes: addImage)
                    cell.btnSelector.backgroundColor = .systemBlue
                    print("add selected photo with index: ", indexPath.row)
                } else {
                    self?.viewModel.deleteDeselectedPhoto(index: indexPath.row)
                    cell.btnSelector.backgroundColor = .none
                }
            })
            .disposed(by: disposeBag)
        
        ///check selectedPhoto array when returned from swipe screen
        if self.viewModel.selectedPhotoes[indexPath.row] != nil {
            cell.btnSelector.backgroundColor = .systemBlue
        } else {
            cell.btnSelector.backgroundColor = .none
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize: CGFloat
        
        let collectionViewWidth = photoCollectionView.frame.width
        let cellInRow = getCurrentOrientationCellCount()
        cellSize = (collectionViewWidth - (viewModel.minimumInteritemSpacing * CGFloat(cellInRow - 1))) / CGFloat(cellInRow)
                
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = photoCollectionView.cellForItem(at: indexPath) as? PhotoSelectionCell else { return }
        guard let addImage = cell.imageView.image else { return }
        self.viewModel.addSelectedPhoto(index: indexPath.row, addPhotoes: addImage)
        print("add from select number: ", indexPath.row)
        self.viewModel.showSwiperController(sourceView: self, scrollToIndex: indexPath.row)
    }
}

//extension PhotoSelectionController: PhotoSwiperDelegate {
//    func obtainSeectedPhotoes(selectedPhotoes: [Int : UIImage]) {
//        print("obtainSeectedPhotoes from delegate was called: ", selectedPhotoes.count)
//        DispatchQueue.main.async {
//            self.photoCollectionView.reloadData()
//        }
//    }
//}
