//
//  MainScreenController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 01.11.2020.
//

import UIKit
import RxCocoa
import RxSwift

class MainScreenController: UIViewController {
    
    weak var sourceViewController: UIWindow?
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.borderWidth = 5
            imageView.layer.borderColor = UIColor.systemPink.cgColor
        }
    }
    
    
    @IBOutlet weak var getImageButton: UIButton! {
        didSet {
            getImageButton.backgroundColor = LHColors.babyBlueEyes
            getImageButton.layer.shadowOffset = CGSize(width: 3, height: 3)
            getImageButton.layer.shadowColor = UIColor.systemGray.cgColor
            getImageButton.layer.cornerRadius = 25
            //getImageButton.setTitle("Get Image", for: .normal)
            getImageButton.tintColor = UIColor.black
            getImageButton.titleLabel?.font = .systemFont(ofSize: 18)
        }
    }
    
    static var identifier: String {
        return String(describing: self)
    }
        
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImageButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.showPhotoSelectioScreen()},
                       onError: { (_) in print("some error has occured") })
            .disposed(by: disposeBag)
        
    }
    
    
    func showPhotoSelectioScreen() {
        let storyboard = UIStoryboard(name: "PhotoSelectionController", bundle: nil)
        let photoSelectionVC = storyboard.instantiateViewController(identifier: PhotoSelectionController.identifier) as! PhotoSelectionController
        
        photoSelectionVC.viewModel = setPhotoSelectionViewModel()   //initialize viewModel with base parameters
        photoSelectionVC.viewModel.cellInRowPortriant = 3           //add new parameters to viewModels
        photoSelectionVC.viewModel.cellInRowLandscape = 5
        
        photoSelectionVC.title = "Select photo"
        self.navigationController?.pushViewController(photoSelectionVC, animated: true)
    }
    
    ///Set PhotoSelection screen parameters
    func setPhotoSelectionViewModel() -> PhotoSelectionViewModel {
        let viewModel = PhotoSelectionViewModel(cellInRowPortriant: 3, cellInRowLandscape: nil)
        return viewModel
    }
    
}
