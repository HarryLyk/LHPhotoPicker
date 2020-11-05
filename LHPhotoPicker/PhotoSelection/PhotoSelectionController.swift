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
    
    var viewModel: PhotoSelectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("PhotoSelectionController viewDidLoad function")
        viewModel = PhotoSelectionViewModel()
        
        viewModel.isLoading
            .subscribe(onNext: { flag in print("new flag value :", flag) } )
            .disposed(by: disposeBag)

        viewModel.isLoading.accept(true)
    }
    
}
