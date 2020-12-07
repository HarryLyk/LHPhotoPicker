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
                            print("deselect number:", index)
                        } else {
                            if let image = currentCell.photoImageView.image {
                                self?.viewModel.addSelectedPhoto(index: index, addPhotoes: image)
                                self?.btnSelectPhoto.backgroundColor = .systemBlue
                                print("select number:", index)
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
                print("button apply tapped")
                self?.viewModel.setSelectedPhotoOnApply(selectedPhotoes: self?.viewModel.selectedPhotoes ?? [:])
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        btnCancelEdit.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                print("button cancel edit was tapped")
                self?.showMainButtonsWithAnimation()
            })
            .disposed(by: disposeBag)
        
        btnApplyEdit.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                print("apply edit was tapped")
                self?.showMainButtonsWithAnimation()
            })
            .disposed(by: disposeBag)
        
        btnCrop.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                print("button crop was tapped")
                self?.showEditButtonsWithAnimation()
                let currentCell = self?.collectionView.visibleCells.first as! PhotoSwiperCell
                let cropRedactor = CropRedactor(baseImage: currentCell.photoImageView)
                cropRedactor.initializeCropRedactor()
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

