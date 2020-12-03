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

    private let btnSelectPhoto: UIButton = {
        let button = UIButton()
        button.layer.backgroundColor = .none
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 12.5
        return button
    }()
    
    private let btnCancel: UIButton = {
       let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
    private let btnApply: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Apply", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
    private let btnEdit: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Select", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
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
        view.addSubview(btnApply)
        view.addSubview(btnCancel)
        view.addSubview(btnEdit)
        
        setupCollectionViewWithLayout()
        setupButtonConstrains()
        setupBtnRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let scrollToIndexPath = IndexPath(item: viewModel.scrollToIndex, section: 0)
        collectionView.scrollToItem(at: scrollToIndexPath, at: .left, animated: false)
    }

    private func setupButtonConstrains() {
        btnSelectPhoto.translatesAutoresizingMaskIntoConstraints = false
        btnSelectPhoto.heightAnchor.constraint(equalToConstant: 25).isActive = true
        btnSelectPhoto.widthAnchor.constraint(equalToConstant: 25).isActive = true
        btnSelectPhoto.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        btnSelectPhoto.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        
        btnApply.translatesAutoresizingMaskIntoConstraints = false
        btnApply.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        btnApply.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        btnApply.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnApply.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        btnCancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        btnEdit.translatesAutoresizingMaskIntoConstraints = false
        btnEdit.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        btnEdit.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnEdit.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnEdit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
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
        
        btnEdit.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                print("button edit was tapped")
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
