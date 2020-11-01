//
//  MainScreenController.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 01.11.2020.
//

import UIKit

class MainScreenController: UIViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet{
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
            getImageButton.setTitle("Get Image", for: .normal)
            getImageButton.tintColor = UIColor.black
            getImageButton.titleLabel?.font = .systemFont(ofSize: 18)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
