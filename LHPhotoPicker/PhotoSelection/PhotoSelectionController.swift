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
    
    private var disposeBag = DisposeBag()
    
    var viewModel: PhotoSelectionViewModel! {
        didSet {
            configure(viewModel: viewModel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(PhotoSelectionCell.self, forCellWithReuseIdentifier: "PhotoSelectionCell")

        viewModel.isLoading
            .subscribe(onNext: { flag in print("new flag value :", flag) } )
            .disposed(by: disposeBag)

        viewModel.isLoading.accept(true)
    }
    
    
    ///configure nunmber of photoes in a row, and other
    func configure(viewModel: PhotoSelectionViewModel) {
        print("configure photo view model")
    }
    
}

extension PhotoSelectionController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSelectionCell", for: indexPath) as? PhotoSelectionCell else {
            return UICollectionViewCell()
        }
        
        cell.backgroundColor = .systemGreen
        return cell
    }
    
    
}
