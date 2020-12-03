//
//  PhotoSelectionCell.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 09.11.2020.
//

import UIKit
import RxCocoa
import RxSwift

//protocol PhotoSelectionCellDelegate {
//    func getSelectedImage(selectedImage: UIImage)
//}

class PhotoSelectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnSelector: UIButton!
    
    private var btnIsSelected: Bool = .init(false)
    var isPhotoSelected: PublishRelay<Bool> = .init()
    
    private var disposeBag = DisposeBag()
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    deinit {
        print("deinit cell was called")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellView()
        setupRx()
    }
    
    private func setupCellView() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        btnSelector.layer.backgroundColor = .none
        btnSelector.layer.borderWidth = 1
        btnSelector.layer.borderColor = UIColor.white.cgColor
        btnSelector.layer.cornerRadius = 12.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //disposeBag = DisposeBag()
    }
    
    private func setupRx() {
        btnSelector.rx.tap
            .subscribe(onNext: {
                [weak self] _ in
                if self?.btnIsSelected == false {
                    self?.btnIsSelected = true
                    //self?.btnSelector.backgroundColor = .systemBlue
                    self?.isPhotoSelected.accept(true)
                } else {
                    self?.btnIsSelected = false
                    //self?.btnSelector.backgroundColor = .none
                    self?.isPhotoSelected.accept(false)
                }
            })
            .disposed(by: disposeBag)
    }
}

