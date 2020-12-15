//
//  PhotoSwiperController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 21.11.2020.
//

import UIKit
import Photos
import RxCocoa
import RxSwift

class PhotoSwiperController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let btnSelectPhoto: UIButton = {
        let button = UIButton()
        button.layer.backgroundColor = .none
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 12.5
        return button
    }()
    
    let btnCancel: UIButton = {
       let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let btnCrop: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Crop", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let btnApply: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Apply", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    ///Set buttons for edit mode
    let btnCancelEdit: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.isUserInteractionEnabled = false //it's hide at the beginning
        return button
    }()
    
    let btnApplyEdit: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Ok", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.isUserInteractionEnabled = false
        return button
    }()

    
    var btnApplyBottomAnchor = NSLayoutConstraint()
    var btnCancelBottonAnchor = NSLayoutConstraint()
    var btnCropBottomAnchor = NSLayoutConstraint()
    
    var btnApplyEditBottomAnchor = NSLayoutConstraint()
    var btnCancelEditBottomAnchor = NSLayoutConstraint()
    
    static var identifier: String {
        return String(describing: self)
    }
    var viewModel: PhotoSwiperViewModel!
    private let disposeBag = DisposeBag()
    
    deinit {
        print("PhotoSwiperController deinit was called")
    }
    
    //crop redactor data
    var cropRedactor: CropRedactor?
    var cropInitialPoint = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(btnSelectPhoto)
        addMainButtonsSubviews()
        addCropButtonSubviews()
        
        setupSelectPhotoButtonConstraints()
        setupMainButtonConstrains()
        setupEditButtonConstrains()
        
        setupCollectionViewWithLayout()
        
        setupBtnRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let scrollToIndexPath = IndexPath(item: viewModel.scrollToIndex, section: 0)
        collectionView.scrollToItem(at: scrollToIndexPath, at: .left, animated: false)
    }

    private func addMainButtonsSubviews() {
        view.addSubview(btnApply)
        view.addSubview(btnCancel)
        view.addSubview(btnCrop)
    }
    
    private func addCropButtonSubviews() {
        view.addSubview(btnApplyEdit)
        view.addSubview(btnCancelEdit)
    }
    
    private func setupCollectionViewWithLayout(){
        collectionView?.register(PhotoSwiperCell.self, forCellWithReuseIdentifier: PhotoSwiperCell.reuseIdentifier)
        collectionView?.isPagingEnabled = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
    }
    

    private func setupBtnRx(){
        btnSelectPhoto.rx.tap
            .subscribe(onNext:{
                [weak self] _ in
                ///if cell exists with photo - add photo to selectdPhoto and change select indicator
                if let currentCell = self?.collectionView.visibleCells.first as? PhotoSwiperCell {
                    if let index = self?.collectionView.indexPath(for: currentCell)?.row {
                        if self?.viewModel.selectedPhotoes[index] != nil {
                            self?.viewModel.deleteDeselectedPhoto(index: index)
                            self?.btnSelectPhoto.backgroundColor = .none
                        } else {
                            if let image = currentCell.photoImageView.image {
                                self?.viewModel.addSelectedPhoto(index: index, addPhotoes: image)
                                self?.btnSelectPhoto.backgroundColor = .systemBlue
                            }
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        btnCancel.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                print("button cancel was tapped")
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        btnApply.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                self?.viewModel.setSelectedPhotoOnApply(selectedPhotoes: self?.viewModel.selectedPhotoes ?? [:])
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        btnCancelEdit.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                if self?.cropRedactor != nil {
                    self?.cropRedactor?.cancelEdit()
                }
                self?.collectionView.isUserInteractionEnabled = true
                self?.btnSelectPhoto.isUserInteractionEnabled = true
                self?.showMainButtonsWithAnimation()
            })
            .disposed(by: disposeBag)
        
        btnApplyEdit.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                if self?.cropRedactor != nil {
                    self?.cropRedactor?.applyEdit()
                }
                self?.collectionView.isUserInteractionEnabled = true
                self?.btnSelectPhoto.isUserInteractionEnabled = true
                self?.showMainButtonsWithAnimation()
            })
            .disposed(by: disposeBag)
        
        btnCrop.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                
                ///show crop buttons
                self?.collectionView.isUserInteractionEnabled = false
                self?.btnSelectPhoto.isUserInteractionEnabled = false
                self?.showEditButtonsWithAnimation()
                
                ///draw crop rectangle
                let currentCell = self?.collectionView.visibleCells.first as! PhotoSwiperCell
                self?.cropRedactor = CropRedactor(baseImage: currentCell.photoImageView)
                let cropRect = self?.cropRedactor?.drawCropRect()
                self?.view.addSubview(cropRect!)
                
                ///add tap recognizer for crop rectangle
                self?.cropRedactor?.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self?.cropPanHandler(_:)))
                cropRect?.addGestureRecognizer((self?.cropRedactor?.panGestureRecognizer)!)
            })
            .disposed(by: disposeBag)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.assets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoSwiperCell.reuseIdentifier, for: indexPath) as! PhotoSwiperCell
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        let cellWidth = cell.frame.width
        let cellHeight = cell.frame.height
        
        PHImageManager.default().requestImage(for: viewModel.assets.object(at: indexPath.row), targetSize: CGSize(width: cellWidth, height: cellHeight), contentMode: .aspectFit, options: nil) { (image, error) in
            if image != nil {
                cell.photoImageView.image = image
            }   
        }
        
        ///if any image with that key in dictionary - consider this photo is selected
        if viewModel.selectedPhotoes[indexPath.item] != nil {
            btnSelectPhoto.backgroundColor = .systemBlue
        } else {
            btnSelectPhoto.backgroundColor = .none
        }
        
        return cell
    }
}

extension PhotoSwiperController {
    
    @objc func cropPanHandler(_ gestureRecognizer: UIPanGestureRecognizer){
        
        print("cropPanHandler event")

        guard gestureRecognizer.view != nil else { return }
        let cropView = gestureRecognizer.view
        ///get coordinates relative to superview
        let translation = gestureRecognizer.translation(in: cropView?.superview)
        
        if gestureRecognizer.state == .began {
            self.cropInitialPoint = cropView!.center
            print("begun touch X position: ", cropView?.center.x)
            print("begun touch Y position: ", cropView?.center.y)
        }
        
        
        ///end of touch
        if gestureRecognizer.state == .ended {
            let endXpoint = self.cropInitialPoint.x + translation.x
            let endYpoint = self.cropInitialPoint.y + translation.y
            print("endXpoint", endXpoint)
            print("endYpoint", endYpoint)
        }
        
    }
}
    
