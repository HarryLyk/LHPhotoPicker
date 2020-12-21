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
    var cropInitialRect = CGRect()
    var touchPositionType: TouchPosition = .badPosition
    
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
                    ///save cropped picture
                    let currentCell = self?.collectionView.visibleCells.first as! PhotoSwiperCell
                    currentCell.photoImageView.image = self?.cropRedactor?.editedImage
                    //let updIndexPath:[IndexPath] = [(self?.collectionView.indexPath(for: currentCell))!]
                    //self?.collectionView.reloadItems(at: updIndexPath)
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
        guard gestureRecognizer.view != nil else { return }
        let cropView = gestureRecognizer.view
        
        ///get coordinates relative to superview
        let translation = gestureRecognizer.translation(in: cropView?.superview)
        
        if gestureRecognizer.state == .began {
            ///get start point position relative to cropView, not superview
            let touchPoint = gestureRecognizer.location(in: cropView)
            
            ///get initial point of cropView to draw crop rectangle when it changes
            if cropView?.frame.origin != nil {
                self.cropInitialPoint = (cropView?.frame.origin)!
            }
            ///get initial frame of cropRect frame to count it's changes from it
            if self.cropRedactor != nil {
                self.cropInitialRect = (self.cropRedactor?.cropRect.frame)!
            }
            
            ///get part of cropRect according to touch position
            ///minLen - minimum distance from touch point to handle
            let touchScaleFactor:CGFloat = 0.15 //this value shouldn't be greather then 0.25
            let minLen = { () -> CGFloat in
                if self.cropInitialRect.width < self.cropInitialRect.height {
                    return self.cropInitialRect.width * touchScaleFactor
                } else {
                    return self.cropInitialRect.height * touchScaleFactor
                }
            }()
            
            ///center points of X and Y of crop rectangle
            let centerX = self.cropInitialRect.width / 2
            let centerY = self.cropInitialRect.height / 2
            let maxX = self.cropInitialRect.width
            let maxY = self.cropInitialRect.height
            
            ///count touch point type (TouchPosition)
            if (touchPoint.x < minLen) {
                ///handle left side
                if (touchPoint.y < minLen) {
                    self.touchPositionType = .topLeft
                } else if ((touchPoint.y > (centerY - minLen)) && (touchPoint.y < (centerY + minLen))) {
                    self.touchPositionType = .leftBorder
                } else if ( (maxY - minLen) < touchPoint.y) {
                    self.touchPositionType = .bottomLeft
                }
            } else if ((maxX - minLen) < touchPoint.x) {
                ///handle right side
                if (touchPoint.y < minLen) {
                    self.touchPositionType = .topRight
                } else if (((centerY - minLen) < touchPoint.y) && (touchPoint.y < (centerY + minLen))) {
                    self.touchPositionType = .rightBorder
                } else if ((maxY - minLen) < touchPoint.y) {
                    self.touchPositionType = .bottomRight
                }
            } else if ( ((centerX - minLen) < touchPoint.x) && (touchPoint.x < (centerX + minLen))) {
                ///handle top and bottom borders
                if (touchPoint.y < minLen) {
                    self.touchPositionType = .topBorder
                } else if ( touchPoint.y > (maxY - minLen)) {
                    self.touchPositionType = .bottomBorder
                } else if (((centerY - minLen) < touchPoint.y) && (touchPoint.y < (centerY + minLen))) {
                    ///handle center touch
                    self.touchPositionType = .centerPosition
                }
            } else {
                self.touchPositionType = .badPosition
            }
        }
        
        if gestureRecognizer.state == .changed {
            
            ///get data about very first crop rectangle frame
            guard let originFrame = self.cropRedactor?.baseCropRect else { return }
            let originX = originFrame.origin.x
            let originY = originFrame.origin.y
            let originWidth = originFrame.width
            let originHeight = originFrame.height
            
            ///Set data when current pan recognizer works
            ///Note: when touches crop rectangle after changes, cropInitialRect will become diferent from previous pan gesture
            let curWidth = self.cropInitialRect.width
            let curHeigh = self.cropInitialRect.height
            let minX = self.cropInitialPoint.x
            let minY = self.cropInitialPoint.y
            let maxX = minX + curWidth
            let maxY = minY + curHeigh
                
            print("originX: ", originX)
            print("originY: ", originY)
            print("minX: ", minX)
            print("minY: ", minY)
            print("maxX: ", maxX)
            print("maxY: ", maxY)
            print("cropWidth: ", curWidth)
            print("cropHeigh: ", curHeigh)
            print("translation.x : ", translation.x)
            print("translation.y : ", translation.y)
            
            ///count crop rectangle border movement
            ///Note: make separate functions for border check?
            switch self.touchPositionType {
            case .topLeft:
                if ((minX + translation.x) < originX) && ((minY + translation.y) < originY) {
                    cropView?.frame = CGRect(x: originX, y: originY, width: minX + maxX, height: (minY - originY) + curHeigh)
                } else if (minX + translation.x) < originX {
                    cropView?.frame = CGRect(x: originX, y: minY + translation.y, width: curWidth + minX, height: curHeigh - translation.y)
                } else if (minY + translation.y) < originY {
                    cropView?.frame = CGRect(x: minX + translation.x, y: originY, width: curWidth - translation.x, height: (minY - originY) + curHeigh)
                } else {
                    cropView?.frame = CGRect(x: minX + translation.x, y: minY + translation.y, width: curWidth - translation.x, height: curHeigh - translation.y)
                }
            case .topBorder:
                if (minY + translation.y) < originY {
                    cropView?.frame = CGRect(x: minX, y: originY, width: curWidth, height: (minY - originY) + curHeigh)
                } else {
                    cropView?.frame = CGRect(x: minX, y: minY + translation.y, width: curWidth, height: curHeigh - translation.y)
                }
            case .topRight:
                if ((minY + translation.y) < originY) && ((maxX + translation.x) > originWidth) {
                    cropView?.frame = CGRect(x: minX, y: originY, width: originWidth - minX, height: (minY - originY) + curHeigh)
                } else if (maxX + translation.x) > originWidth {
                    cropView?.frame = CGRect(x: originX, y: minY + translation.y, width: originWidth, height: curHeigh - translation.y)
                } else if (minY + translation.y) < originY {
                    cropView?.frame = CGRect(x: minX, y: originY, width: curWidth + translation.x, height: originHeight)
                } else {
                    cropView?.frame = CGRect(x: minX, y: minY + translation.y, width: curWidth + translation.x, height: curHeigh - translation.y)
                }
            case .rightBorder:
                if maxX + translation.x > originWidth {
                    cropView?.frame = CGRect(x: minX, y: minY, width: originWidth - minX, height: curHeigh)
                } else {
                    cropView?.frame = CGRect(x: minX, y: minY, width: curWidth + translation.x, height: curHeigh)
                }
            case .bottomRight:
                if (maxX + translation.x > originWidth) && (maxY + translation.y > originY + originHeight) {
                    cropView?.frame = CGRect(x: minX, y: minY, width: originWidth - minX, height: (originY + originHeight) - minY)
                } else if (maxX + translation.x > originWidth) {
                    cropView?.frame = CGRect(x: minX, y: minY, width: originWidth - minX, height: curHeigh + translation.y)
                } else if (maxY + translation.y > originY + originHeight) {
                    cropView?.frame = CGRect(x: minX, y: minY, width: curWidth + translation.x, height: (originY + originHeight) - minY)
                } else {
                    cropView?.frame = CGRect(x: minX, y: minY, width: curWidth + translation.x, height: curHeigh + translation.y)
                }
            case .bottomBorder:
                if maxY + translation.y > originY + originHeight {
                    cropView?.frame = CGRect(x: minX, y: minY, width: curWidth, height: (originY + originHeight) - minY)
                } else {
                    cropView?.frame = CGRect(x: minX, y: minY, width: curWidth, height: curHeigh + translation.y)
                }
            case .bottomLeft:
                if (minX + translation.x < originX) && (maxY + translation.y > originY + originHeight) {
                    cropView?.frame = CGRect(x: originX, y: minY, width: curWidth + minX, height: (originY + originHeight) - minY)
                } else if (minX + translation.x < originX) {
                    cropView?.frame = CGRect(x: originX, y: minY, width: curWidth + minX, height: curHeigh + translation.y)
                } else if (maxY + translation.y > originY + originHeight) {
                    cropView?.frame = CGRect(x: minX + translation.x, y: minY, width: curWidth - translation.x, height: (originY + originHeight) - minY)
                } else {
                    cropView?.frame = CGRect(x: minX + translation.x, y: minY, width: curWidth - translation.x, height: curHeigh + translation.y)
                }
            case .leftBorder:
                if minX + translation.x < originX {
                    cropView?.frame = CGRect(x: originX, y: minY, width: curWidth + minX, height: curHeigh)
                } else {
                    cropView?.frame = CGRect(x: minX + translation.x, y: minY, width: curWidth - translation.x, height: curHeigh)
                }
            case .centerPosition:
                print("Center position")
                
            case .badPosition:
                print("badPosition")
            }

        }
        
        ///end of touch
        if gestureRecognizer.state == .ended {
            let endXpoint = self.cropInitialPoint.x + translation.x
            let endYpoint = self.cropInitialPoint.y + translation.y
            print("endXpoint", endXpoint)
            print("endYpoint", endYpoint)
            
            if cropView == nil { return }
            guard let cutImageRef: CGImage = cropRedactor?.baseImage.image?.cgImage?.cropping(to: cropView!.frame)
            else {
                print("error crop image")
                return
            }
            cropRedactor?.editedImage = UIImage(cgImage: cutImageRef)
        }
    }
}
    
